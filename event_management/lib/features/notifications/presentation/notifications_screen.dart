import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection(AppConstants.notificationsCollection)
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList());
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return Icons.notifications_active;
      case NotificationType.eventUpdate:
        return Icons.update;
      case NotificationType.eventCancelled:
        return Icons.event_busy;
      case NotificationType.participantJoined:
        return Icons.person_add;
      case NotificationType.participantConfirmed:
        return Icons.check_circle;
      case NotificationType.participantDeclined:
        return Icons.cancel;
      case NotificationType.eventStarting:
        return Icons.schedule;
      case NotificationType.eventEnded:
        return Icons.event_available;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return Colors.blue;
      case NotificationType.eventUpdate:
        return Colors.orange;
      case NotificationType.eventCancelled:
        return Colors.red;
      case NotificationType.participantJoined:
        return Colors.green;
      case NotificationType.participantConfirmed:
        return Colors.green;
      case NotificationType.participantDeclined:
        return Colors.grey;
      case NotificationType.eventStarting:
        return Colors.purple;
      case NotificationType.eventEnded:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () async {
              // Mark all as read
              final user = ref.read(currentUserProvider);
              if (user != null) {
                final notifications = await FirebaseFirestore.instance
                    .collection(AppConstants.notificationsCollection)
                    .where('userId', isEqualTo: user.uid)
                    .where('isRead', isEqualTo: false)
                    .get();

                final batch = FirebaseFirestore.instance.batch();
                for (var doc in notifications.docs) {
                  batch.update(doc.reference, {'isRead': true});
                }
                await batch.commit();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                }
              }
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Group notifications by date
          final groupedNotifications = <String, List<NotificationModel>>{};
          for (var notification in notifications) {
            final dateKey = DateFormat('yyyy-MM-dd').format(notification.createdAt);
            if (!groupedNotifications.containsKey(dateKey)) {
              groupedNotifications[dateKey] = [];
            }
            groupedNotifications[dateKey]!.add(notification);
          }

          return ListView.builder(
            itemCount: groupedNotifications.length,
            itemBuilder: (context, index) {
              final dateKey = groupedNotifications.keys.elementAt(index);
              final notificationsForDate = groupedNotifications[dateKey]!;
              final date = DateTime.parse(dateKey);

              String dateLabel;
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final yesterday = today.subtract(const Duration(days: 1));

              if (date == today) {
                dateLabel = 'Today';
              } else if (date == yesterday) {
                dateLabel = 'Yesterday';
              } else {
                dateLabel = DateFormat('EEEE, MMMM d').format(date);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...notificationsForDate.map((notification) {
                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await FirebaseFirestore.instance
                            .collection(AppConstants.notificationsCollection)
                            .doc(notification.id)
                            .delete();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification deleted')),
                          );
                        }
                      },
                      child: _buildNotificationItem(context, notification, ref),
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    WidgetRef ref,
  ) {
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type).withValues(alpha: 0.2),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: !notification.isRead
            ? const Icon(Icons.circle, size: 12, color: Colors.blue)
            : null,
        onTap: () async {
          // Mark as read
          if (!notification.isRead) {
            await FirebaseFirestore.instance
                .collection(AppConstants.notificationsCollection)
                .doc(notification.id)
                .update({'isRead': true});
          }

          // Navigate to event if eventId exists
          if (notification.eventId != null && context.mounted) {
            // TODO: Navigate to event details
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event navigation coming soon')),
            );
          }
        },
      ),
    );
  }
}
