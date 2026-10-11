import 'package:flutter/material.dart';

import '../models/meeting.dart';
import '../utils/format.dart';

class MeetingCard extends StatelessWidget {
  const MeetingCard({
    super.key,
    required this.meeting,
    required this.onOpen,
    required this.onFavourite,
  });

  final Meeting meeting;
  final VoidCallback onOpen;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = meeting.category.color(scheme);
    final (:taken, :free) = meeting.places;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: scheme.surfaceContainerHighest,
                      child: Icon(meeting.category.icon, color: color),
                    ),
                  ),
                  if (free <= 5)
                    Positioned(
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            meeting.isFull ? 'FULL' : '$free left',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(formatDateTime(meeting.when), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(meeting.place, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '$taken/${meeting.limit} joined${meeting.isPast ? ' · Past' : ''}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: meeting.favourite ? 'Remove favourite' : 'Add favourite',
                onPressed: onFavourite,
                icon: Icon(meeting.favourite ? Icons.favorite : Icons.favorite_border),
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
