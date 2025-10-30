import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus {
  draft,
  published,
  completed,
  cancelled,
}

enum EventCategory {
  conference,
  workshop,
  meetup,
  seminar,
  party,
  sports,
  cultural,
  business,
  educational,
  other,
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? imageUrl;
  final EventCategory category;
  final EventStatus status;
  final String organizerId;
  final String organizerName;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final bool isPublic;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.imageUrl,
    required this.category,
    this.status = EventStatus.draft,
    required this.organizerId,
    required this.organizerName,
    this.maxParticipants = 100,
    this.currentParticipants = 0,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.isPublic = true,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      category: EventCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => EventCategory.other,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => EventStatus.draft,
      ),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 100,
      currentParticipants: data['currentParticipants'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      tags: List<String>.from(data['tags'] ?? []),
      isPublic: data['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'location': location,
      'imageUrl': imageUrl,
      'category': category.name,
      'status': status.name,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'tags': tags,
      'isPublic': isPublic,
    };
  }

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? imageUrl,
    EventCategory? category,
    EventStatus? status,
    int? maxParticipants,
    int? currentParticipants,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPublic,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      organizerId: organizerId,
      organizerName: organizerName,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  bool get isFull => currentParticipants >= maxParticipants;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPast => endDate.isBefore(DateTime.now());
}
