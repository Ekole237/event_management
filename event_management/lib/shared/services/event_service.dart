import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../../core/constants/app_constants.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create event
  Future<String> createEvent(EventModel event) async {
    try {
      final eventId = _uuid.v4();
      final eventWithId = event.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .set(eventWithId.toFirestore());

      return eventId;
    } catch (e) {
      rethrow;
    }
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    try {
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(event.id)
          .update(updatedEvent.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .delete();

      // Delete all participants for this event
      final participants = await _firestore
          .collection(AppConstants.participantsCollection)
          .where('eventId', isEqualTo: eventId)
          .get();

      for (var doc in participants.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .get();

      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get all events
  Stream<List<EventModel>> getAllEvents() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: EventStatus.published.name)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // Get user's events (as organizer)
  Stream<List<EventModel>> getUserEvents(String userId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('organizerId', isEqualTo: userId)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // Get events by status
  Stream<List<EventModel>> getEventsByStatus(EventStatus status) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('status', isEqualTo: status.name)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // Get events by category
  Stream<List<EventModel>> getEventsByCategory(EventCategory category) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('category', isEqualTo: category.name)
        .where('isPublic', isEqualTo: true)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // Search events
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      // Simple search by title (Firestore doesn't support full-text search)
      final snapshot = await _firestore
          .collection(AppConstants.eventsCollection)
          .where('isPublic', isEqualTo: true)
          .get();

      final results = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((event) =>
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              event.description.toLowerCase().contains(query.toLowerCase()) ||
              event.location.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return results;
    } catch (e) {
      rethrow;
    }
  }

  // Duplicate event
  Future<String> duplicateEvent(String eventId) async {
    try {
      final original = await getEventById(eventId);
      if (original == null) {
        throw Exception('Event not found');
      }

      final newEventId = _uuid.v4();
      final duplicated = EventModel(
        id: newEventId,
        title: '${original.title} (Copy)',
        description: original.description,
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 2)),
        location: original.location,
        imageUrl: original.imageUrl,
        category: original.category,
        status: EventStatus.draft,
        organizerId: original.organizerId,
        organizerName: original.organizerName,
        maxParticipants: original.maxParticipants,
        createdAt: DateTime.now(),
        tags: original.tags,
        isPublic: original.isPublic,
      );

      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(newEventId)
          .set(duplicated.toFirestore());

      return newEventId;
    } catch (e) {
      rethrow;
    }
  }

  // Get upcoming events
  Stream<List<EventModel>> getUpcomingEvents() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('isPublic', isEqualTo: true)
        .where('status', isEqualTo: EventStatus.published.name)
        .where('startDate', isGreaterThan: Timestamp.now())
        .orderBy('startDate', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // Get events by date range
  Future<List<EventModel>> getEventsByDateRange(
      DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventsCollection)
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update event status
  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
