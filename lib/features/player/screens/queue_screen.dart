import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_controller_provider.dart';
import '../../../core/constants/app_constants.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<MediaControllerProvider>().clearQueue();
            },
          ),
        ],
      ),
      body: Consumer<MediaControllerProvider>(
        builder: (context, provider, child) {
          if (provider.queue.isEmpty) {
            return _buildEmptyQueue(context);
          }

          return Column(
            children: [
              // Currently playing section
              if (provider.currentTrack != null)
                _buildCurrentlyPlaying(context, provider),

              // Queue list
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: provider.queue.length,
                  onReorder: provider.reorderQueue,
                  itemBuilder: (context, index) {
                    final track = provider.queue[index];
                    final isCurrentTrack = index == provider.currentIndex;

                    return _buildQueueItem(
                      context,
                      track,
                      index,
                      isCurrentTrack,
                      provider,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyQueue(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Queue is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add tracks to your queue to see them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.surfaceTint,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentlyPlaying(
      BuildContext context, MediaControllerProvider provider) {
    final currentTrack = provider.currentTrack!;

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NOW PLAYING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.play_circle_filled),
                color: Theme.of(context).colorScheme.primary,
                onPressed: provider.isPlaying ? provider.pause : provider.play,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  currentTrack.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceTint
                            .withAlpha((0.6 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTrack.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTrack.artistNames,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(
    BuildContext context,
    track,
    int index,
    bool isCurrentTrack,
    MediaControllerProvider provider,
  ) {
    return Card(
      key: ValueKey(track.trackhash ?? index),
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrentTrack
          ? Theme.of(context)
              .colorScheme
              .primaryContainer
              .withOpacity(0.3)
          : null,
      child: ListTile(
        leading: isCurrentTrack
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  track.image,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          track.title,
          style: isCurrentTrack
              ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
              : null,
        ),
        subtitle: Text(
          '${track.artistNames} • ${track.album ?? 'Unknown Album'}',
          style: isCurrentTrack
              ? Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  )
              : null,
        ),
        onTap: () {
          provider.jumpToIndex(index);
        },
      ),
    );
  }
}
