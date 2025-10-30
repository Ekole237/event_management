import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/participant_model.dart';
import '../../../shared/services/participant_service.dart';
import '../../../shared/providers/auth_provider.dart';
import 'create_event_screen.dart';

final participantServiceProvider = Provider<ParticipantService>((ref) {
  return ParticipantService();
});

final eventParticipantsProvider = StreamProvider.family<List<ParticipantModel>, String>((ref, eventId) {
  return ref.watch(participantServiceProvider).getEventParticipants(eventId);
});

class EventDetailsScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isRegistering = false;

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

  Future<void> _registerForEvent() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to register for events')),
      );
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final participantService = ref.read(participantServiceProvider);

      // Check if already registered
      final existingParticipant = await participantService.getParticipantByUserAndEvent(
        user.uid,
        widget.event.id,
      );

      if (existingParticipant != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already registered for this event')),
          );
        }
        return;
      }

      // Register new participant
      final participant = ParticipantModel(
        id: '',
        eventId: widget.event.id,
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userEmail: user.email ?? '',
        userPhotoUrl: user.photoURL,
        registeredAt: DateTime.now(),
      );

      await participantService.registerParticipant(participant);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered for event!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.uid == widget.event.organizerId;
    final participants = ref.watch(eventParticipantsProvider(widget.event.id));
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy • hh:mm a');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.event.imageUrl != null
                  ? Image.network(
                      widget.event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                              _getCategoryIcon(widget.event.category),
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
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
                          _getCategoryIcon(widget.event.category),
                          style: const TextStyle(fontSize: 100),
                        ),
                      ),
                    ),
            ),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateEventScreen(event: widget.event),
                      ),
                    );
                  },
                ),
            ],
          ),

          // Event Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Status
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.event.category.name.toUpperCase()),
                      ),
                      if (widget.event.isFull) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('FULL', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),

                  // Organizer
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          widget.event.organizerName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Organized by', style: TextStyle(fontSize: 12)),
                          Text(
                            widget.event.organizerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date & Time
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date & Time',
                    '${dateFormat.format(widget.event.startDate)}\nto\n${dateFormat.format(widget.event.endDate)}',
                  ),
                  const SizedBox(height: 16),

                  // Location
                  _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    widget.event.location,
                  ),
                  const SizedBox(height: 16),

                  // Participants
                  _buildInfoRow(
                    Icons.people,
                    'Participants',
                    '${widget.event.currentParticipants} / ${widget.event.maxParticipants}',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: widget.event.currentParticipants / widget.event.maxParticipants,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About this event',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Participants List
                  if (isOwner) ...[
                    Text(
                      'Participants',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    participants.when(
                      data: (participantList) {
                        if (participantList.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No participants yet'),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: participantList.length,
                          itemBuilder: (context, index) {
                            final participant = participantList[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: participant.userPhotoUrl != null
                                    ? NetworkImage(participant.userPhotoUrl!)
                                    : null,
                                child: participant.userPhotoUrl == null
                                    ? Text(participant.userName[0].toUpperCase())
                                    : null,
                              ),
                              title: Text(participant.userName),
                              subtitle: Text(participant.userEmail),
                              trailing: Chip(
                                label: Text(participant.status.name.toUpperCase()),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isOwner
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: widget.event.isFull || _isRegistering
                      ? null
                      : _registerForEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.event.isFull ? 'Event Full' : 'Register for Event',
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
