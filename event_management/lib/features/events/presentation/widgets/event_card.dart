import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../core/constants/app_constants.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isOwner;

  const EventCard({
    super.key,
    required this.event,
    this.isOwner = false,
  });

  String _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.conference:
        return '🎤';
      case EventCategory.workshop:
        return '🛠️';
      case EventCategory.meetup:
        return '👥';
      case EventCategory.seminar:
        return '📚';
      case EventCategory.party:
        return '🎉';
      case EventCategory.sports:
        return '⚽';
      case EventCategory.cultural:
        return '🎭';
      case EventCategory.business:
        return '💼';
      case EventCategory.educational:
        return '🎓';
      case EventCategory.other:
        return '📌';
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return Colors.grey;
      case EventStatus.published:
        return Colors.green;
      case EventStatus.completed:
        return Colors.blue;
      case EventStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.eventDetails,
            arguments: event,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (event.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  event.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.event,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryIcon(event.category),
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Category
                  Row(
                    children: [
                      if (isOwner)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(event.status).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(event.status),
                            ),
                          ),
                        ),
                      if (isOwner) const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          event.category.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Spacer(),
                      if (event.isFull)
                        const Chip(
                          label: Text(
                            'FULL',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateFormat.format(event.startDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Participants
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants} participants',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (event.currentParticipants > 0)
                        LinearProgressIndicator(
                          value: event.currentParticipants / event.maxParticipants,
                          minHeight: 4,
                          backgroundColor: Colors.grey[300],
                        ).constrainedBox(
                          constraints: const BoxConstraints(maxWidth: 60),
                        ),
                    ],
                  ),

                  // Organizer
                  if (!isOwner) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'by ${event.organizerName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension WidgetExtension on Widget {
  Widget constrainedBox({required BoxConstraints constraints}) {
    return ConstrainedBox(
      constraints: constraints,
      child: this,
    );
  }
}
