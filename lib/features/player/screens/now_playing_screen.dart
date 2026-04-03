import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_controller_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/playback_mode.dart';
import '../../../data/models/track_model.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaControllerProvider>(
      builder: (context, provider, child) {
        final currentTrack = provider.currentTrack;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Now Playing',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  _showTrackOptions(context, currentTrack!);
                },
              ),
            ],
          ),
          body: currentTrack == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No track playing',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Album art
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            currentTrack.image,
                            width: 320,
                            height: 320,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 320,
                                height: 320,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Track info
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding),
                        child: Column(
                          children: [
                            Text(
                              currentTrack.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentTrack.artistNames,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Bitrate and file type badge (matching Android NowPlaying.kt)
                            _buildAudioInfoBadge(context, currentTrack),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8),
                                trackHeight: 4,
                                activeTrackColor:
                                    Theme.of(context).colorScheme.primary,
                                inactiveTrackColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                thumbColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              child: Slider(
                                value: provider.progress.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  final newPosition = Duration(
                                    milliseconds: (value *
                                            provider.duration.inMilliseconds)
                                        .round(),
                                  );
                                  provider.seekTo(newPosition);
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    provider.positionFormatted,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                        ),
                                  ),
                                  Text(
                                    provider.durationFormatted,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Playback controls
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Shuffle button
                            IconButton(
                              onPressed: provider.toggleShuffle,
                              icon: Icon(
                                Icons.shuffle,
                                color: provider.shuffleMode == ShuffleMode.on
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              ),
                            ),

                            // Previous button
                            IconButton(
                              onPressed: provider.canGoPrevious
                                  ? provider.playPrevious
                                  : null,
                              icon: Icon(
                                Icons.skip_previous,
                                size: 32,
                                color: provider.canGoPrevious
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              ),
                            ),

                            // Play/Pause button
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: provider.isPlaying
                                    ? provider.pause
                                    : provider.play,
                                icon: provider.isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        provider.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 32,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                              ),
                            ),

                            // Next button
                            IconButton(
                              onPressed:
                                  provider.canGoNext ? provider.playNext : null,
                              icon: Icon(
                                Icons.skip_next,
                                size: 32,
                                color: provider.canGoNext
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              ),
                            ),

                            // Repeat button
                            IconButton(
                              onPressed: provider.toggleRepeat,
                              icon: Icon(
                                _getRepeatIcon(provider.repeatMode),
                                color: provider.repeatMode != RepeatMode.off
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Volume control
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_down,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                  trackHeight: 3,
                                  activeTrackColor:
                                      Theme.of(context).colorScheme.primary,
                                  inactiveTrackColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  thumbColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                child: Slider(
                                  value: provider.volume,
                                  onChanged: provider.setVolume,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.volume_up,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.off:
        return Icons.repeat;
    }
  }

  void _showTrackOptions(BuildContext context, TrackModel track) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.displayTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    track.artistNames,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      track.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: track.isFavorite ? Colors.red : null,
                    ),
                    title: Text(track.isFavorite
                        ? 'Remove from Favorites'
                        : 'Add to Favorites'),
                    onTap: () {
                      Navigator.pop(context);
                      // Toggle favorite logic here
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_add),
                    title: const Text('Add to Playlist'),
                    onTap: () {
                      Navigator.pop(context);
                      // Add to playlist logic here
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: const Text('Add to Queue'),
                    onTap: () {
                      Navigator.pop(context);
                      // Add to queue logic here
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Track Info'),
                    onTap: () {
                      Navigator.pop(context);
                      // Show track info logic here
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build audio info badge showing bitrate and file type
  /// Matches Android: bitrate badge in NowPlaying.kt
  Widget _buildAudioInfoBadge(BuildContext context, TrackModel track) {
    final bitrate = track.bitrate;
    final filepath = track.filepath;
    final extension = filepath.split('.').last.toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$bitrate kbps',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            extension,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
