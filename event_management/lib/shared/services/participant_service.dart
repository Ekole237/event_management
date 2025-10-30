import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/participant_model.dart';
import '../../core/constants/app_constants.dart';

class ParticipantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Register participant for event
  Future<String> registerParticipant(ParticipantModel participant) async {
    try {
      final participantId = _uuid.v4();
      final newParticipant = ParticipantModel(
        id: participantId,
        eventId: participant.eventId,
        userId: participant.userId,
        userName: participant.userName,
        userEmail: participant.userEmail,
        userPhotoUrl: participant.userPhotoUrl,
        status: ParticipationStatus.pending,
        registeredAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.participantsCollection)
          .doc(participantId)
          .set(newParticipant.toFirestore());

      // Update event participant count
      await _updateEventParticipantCount(participant.eventId);

      return participantId;
    } catch (e) {
      rethrow;
    }
  }

  // Update participant status
  Future<void> updateParticipantStatus(
    String participantId,
    ParticipationStatus status,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.participantsCollection)
          .doc(participantId)
          .update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remove participant
  Future<void> removeParticipant(String participantId, String eventId) async {
    try {
      await _firestore
          .collection(AppConstants.participantsCollection)
          .doc(participantId)
          .delete();

      // Update event participant count
      await _updateEventParticipantCount(eventId);
    } catch (e) {
      rethrow;
    }
  }

  // Get participants for event
  Stream<List<ParticipantModel>> getEventParticipants(String eventId) {
    return _firestore
        .collection(AppConstants.participantsCollection)
        .where('eventId', isEqualTo: eventId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipantModel.fromFirestore(doc))
            .toList());
  }

  // Get participant by user and event
  Future<ParticipantModel?> getParticipantByUserAndEvent(
    String userId,
    String eventId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.participantsCollection)
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ParticipantModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's registered events
  Stream<List<ParticipantModel>> getUserParticipations(String userId) {
    return _firestore
        .collection(AppConstants.participantsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParticipantModel.fromFirestore(doc))
            .toList());
  }

  // Get participants by status
  Future<List<ParticipantModel>> getParticipantsByStatus(
    String eventId,
    ParticipationStatus status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.participantsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: status.name)
          .get();

      return snapshot.docs
          .map((doc) => ParticipantModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is registered for event
  Future<bool> isUserRegistered(String userId, String eventId) async {
    try {
      final participant = await getParticipantByUserAndEvent(userId, eventId);
      return participant != null;
    } catch (e) {
      return false;
    }
  }

  // Get participant count for event
  Future<int> getParticipantCount(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.participantsCollection)
          .where('eventId', isEqualTo: eventId)
          .where('status',
              whereIn: [ParticipationStatus.confirmed.name, ParticipationStatus.pending.name])
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Update event participant count
  Future<void> _updateEventParticipantCount(String eventId) async {
    try {
      final count = await getParticipantCount(eventId);

      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .update({
        'currentParticipants': count,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Bulk update participant status
  Future<void> bulkUpdateStatus(
    List<String> participantIds,
    ParticipationStatus status,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final participantId in participantIds) {
        final ref = _firestore
            .collection(AppConstants.participantsCollection)
            .doc(participantId);

        batch.update(ref, {
          'status': status.name,
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Get attendance statistics
  Future<Map<String, int>> getAttendanceStats(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.participantsCollection)
          .where('eventId', isEqualTo: eventId)
          .get();

      final stats = <String, int>{
        'total': 0,
        'confirmed': 0,
        'pending': 0,
        'declined': 0,
        'attended': 0,
        'absent': 0,
      };

      for (final doc in snapshot.docs) {
        final participant = ParticipantModel.fromFirestore(doc);
        stats['total'] = (stats['total'] ?? 0) + 1;
        stats[participant.status.name] = (stats[participant.status.name] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      rethrow;
    }
  }
}
