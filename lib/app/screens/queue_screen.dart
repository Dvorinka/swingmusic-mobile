import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/player_controller.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, _) {
        final scheme = Theme.of(context).colorScheme;
        final queue = player.queue;

        return Scaffold(
          appBar: AppBar(
            title: Text('Queue (${queue.length})'),
            actions: [
              IconButton(
                tooltip: 'Clear upcoming',
                onPressed: queue.length > 1
                    ? () => _confirmAndRun(
                        context,
                        title: 'Clear upcoming tracks?',
                        message:
                            'This keeps the currently playing track and removes the rest.',
                        onConfirm: player.clearUpcomingQueue,
                      )
                    : null,
                icon: const Icon(Icons.queue_music),
              ),
              IconButton(
                tooltip: 'Clear all',
                onPressed: queue.isNotEmpty
                    ? () => _confirmAndRun(
                        context,
                        title: 'Clear full queue?',
                        message:
                            'Playback will stop and the queue will be emptied.',
                        onConfirm: player.clearQueue,
                      )
                    : null,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
          body: queue.isEmpty
              ? Center(
                  child: Text(
                    'Queue is empty.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap to play now. Drag handle to reorder.',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: queue.length,
                        onReorder: (oldIndex, newIndex) {
                          var adjusted = newIndex;
                          if (adjusted > oldIndex) {
                            adjusted -= 1;
                          }
                          if (adjusted == oldIndex) return;
                          player.moveQueueItem(oldIndex, adjusted);
                        },
                        itemBuilder: (context, index) {
                          final track = queue[index];
                          final isCurrent = index == player.currentIndex;

                          return Container(
                            key: ValueKey(
                              'queue-${track.id}-${identityHashCode(track)}',
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                              ),
                            ),
                            child: ListTile(
                              onTap: () => player.playAt(index, autoPlay: true),
                              leading: isCurrent
                                  ? Icon(
                                      player.isPlaying
                                          ? Icons.graphic_eq
                                          : Icons.pause_circle_outline,
                                      color: scheme.primary,
                                    )
                                  : CircleAvatar(
                                      radius: 14,
                                      backgroundColor: scheme.surface,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                              title: Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${track.artist} · ${track.durationLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Remove',
                                    onPressed: () =>
                                        player.removeQueueItemAt(index),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.drag_handle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onConfirm();
    }
  }
}
