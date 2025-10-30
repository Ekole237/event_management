import 'package:cloud_firestore/cloud_firestore.dart';

enum ParticipationStatus {
  pending,
  confirmed,
  declined,
  attended,
  absent,
}

class ParticipantModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  final ParticipationStatus status;
  final DateTime registeredAt;
  final DateTime? updatedAt;
  final String? notes;

  ParticipantModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl,
    this.status = ParticipationStatus.pending,
    required this.registeredAt,
    this.updatedAt,
    this.notes,
  });

  factory ParticipantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParticipantModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      status: ParticipationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ParticipationStatus.pending,
      ),
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoUrl': userPhotoUrl,
      'status': status.name,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
    };
  }

  ParticipantModel copyWith({
    ParticipationStatus? status,
    DateTime? updatedAt,
    String? notes,
  }) {
    return ParticipantModel(
      id: id,
      eventId: eventId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhotoUrl: userPhotoUrl,
      status: status ?? this.status,
      registeredAt: registeredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
