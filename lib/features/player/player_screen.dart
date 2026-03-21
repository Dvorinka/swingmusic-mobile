import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../core/constants/app_spacing.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize audio service if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          final currentTrack = audioProvider.currentTrack;
          
          if (currentTrack == null) {
            return _buildEmptyPlayer();
          }

          return Column(
            children: [
              // App Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                      ),
                      Text(
                        'Now Playing',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () {
                          // Show more options
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              ),

              // Album Art
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: currentTrack.image.isNotEmpty
                            ? Image.network(
                                currentTrack.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAlbumArt(context);
                                },
                              )
                            : _buildDefaultAlbumArt(context),
                      ),
                    ),
                  ),
                ),
              ),

              // Track Info
              Expanded(
                flex: 1,
                child: Padding(
                  padding: AppSpacing.horizontalXL,
                  child: Column(
                    children: [
                      Text(
                        currentTrack.displayTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentTrack.artistNames,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentTrack.displayAlbum.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          currentTrack.displayAlbum,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Progress Bar
              Padding(
                padding: AppSpacing.horizontalXL,
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: audioProvider.progress,
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds: (value * audioProvider.duration.inMilliseconds).round(),
                          );
                          audioProvider.seekTo(newPosition);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            audioProvider.positionFormatted,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            audioProvider.durationFormatted,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          // Volume Control
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.volume_up,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: audioProvider.volume,
                                    onChanged: (value) {
                                      audioProvider.setVolume(value);
                                    },
                                    min: 0.0,
                                    max: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Playback Controls
              Expanded(
                flex: 1,
                child: Padding(
                  padding: AppSpacing.horizontalXL,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle
                      IconButton(
                        onPressed: () => audioProvider.toggleShuffle(),
                        icon: Icon(
                          Icons.shuffle,
                          color: audioProvider.isShuffleMode
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      // Previous
                      IconButton(
                        onPressed: () => audioProvider.playPrevious(),
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 32,
                      ),

                      // Play/Pause
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (audioProvider.isPlaying) {
                              audioProvider.pause();
                            } else {
                              audioProvider.play();
                            }
                          },
                          icon: audioProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 32,
                                ),
                        ),
                      ),

                      // Next
                      IconButton(
                        onPressed: () => audioProvider.playNext(),
                        icon: const Icon(Icons.skip_next),
                        iconSize: 32,
                      ),

                      // Repeat
                      IconButton(
                        onPressed: () => audioProvider.toggleRepeat(),
                        icon: Icon(
                          audioProvider.isRepeatMode ? Icons.repeat_one : Icons.repeat,
                          color: audioProvider.isRepeatMode
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Add to favorites
                      },
                      icon: const Icon(Icons.favorite_border),
                    ),
                    IconButton(
                      onPressed: () {
                        // Show playlist
                      },
                      icon: const Icon(Icons.playlist_play),
                    ),
                    IconButton(
                      onPressed: () {
                        // Share
                      },
                      icon: const Icon(Icons.share),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyPlayer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No track playing',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a track from your library to start playing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAlbumArt(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Icon(
        Icons.album,
        size: 120,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
