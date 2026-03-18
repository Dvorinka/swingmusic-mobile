import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/enums/playback_mode.dart';

class EnhancedPlayerScreen extends StatefulWidget {
  const EnhancedPlayerScreen({super.key});

  @override
  State<EnhancedPlayerScreen> createState() => _EnhancedPlayerScreenState();
}

class _EnhancedPlayerScreenState extends State<EnhancedPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final currentTrack = audioProvider.currentTrack;
        
        if (currentTrack == null) {
          return _buildEmptyPlayer();
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: AppSpacing.horizontalMD,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Now Playing',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showMoreOptions(context),
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Album Artwork
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: AppSpacing.horizontalLG,
                      child: _buildAlbumArtwork(context, currentTrack),
                    ),
                  ),

                  // Track Info & Controls
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: AppSpacing.horizontalLG,
                      child: Column(
                        children: [
                          // Track Info
                          _buildTrackInfo(context, currentTrack),
                          
                          const SizedBox(height: 24),
                          
                          // Progress Bar
                          _buildProgressBar(context, audioProvider),
                          
                          const SizedBox(height: 24),
                          
                          // Playback Controls
                          _buildPlaybackControls(context, audioProvider),
                          
                          const SizedBox(height: 16),
                          
                          // Bottom Controls
                          _buildBottomControls(context, audioProvider),
                        ],
                      ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArtwork(BuildContext context, dynamic currentTrack) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildTrackInfo(BuildContext context, dynamic currentTrack) {
    return Column(
      children: [
        Text(
          currentTrack.displayTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          currentTrack.artistNames,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, AudioProvider audioProvider) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.surfaceVariant,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Text(
                audioProvider.durationFormatted,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(BuildContext context, AudioProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          onPressed: () => audioProvider.toggleShuffle(),
          icon: Icon(
            Icons.shuffle,
            color: audioProvider.shuffleMode == ShuffleMode.on
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),

        // Previous
        IconButton(
          onPressed: () => audioProvider.playPrevious(),
          icon: Icon(
            Icons.skip_previous,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          iconSize: 40,
        ),

        // Play/Pause with buffering indicator
        _buildPlayPauseButton(context, audioProvider),

        // Next
        IconButton(
          onPressed: () => audioProvider.playNext(),
          icon: Icon(
            Icons.skip_next,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          iconSize: 40,
        ),

        // Repeat
        IconButton(
          onPressed: () => audioProvider.toggleRepeat(),
          icon: _getRepeatIcon(audioProvider.repeatMode),
          color: audioProvider.repeatMode != RepeatMode.off
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, AudioProvider audioProvider) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (audioProvider.isPlaying) {
                audioProvider.pause();
              } else {
                audioProvider.play();
              }
            },
            icon: Icon(
              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 48,
            ),
          ),
          if (audioProvider.isBuffering)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, AudioProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Favorite
        IconButton(
          onPressed: () => _toggleFavorite(context, audioProvider),
          icon: Icon(
            audioProvider.currentTrack?.isFavorite == true
                ? Icons.favorite
                : Icons.favorite_border,
            color: audioProvider.currentTrack?.isFavorite == true
                ? Colors.red
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        
        // Queue
        IconButton(
          onPressed: () => _showQueue(context),
          icon: Icon(
            Icons.queue_music,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        
        // Volume
        IconButton(
          onPressed: () => _showVolumeSlider(context, audioProvider),
          icon: Icon(
            Icons.volume_up,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        
}

IconData _getRepeatIcon(RepeatMode mode) {
switch (mode) {
  case RepeatMode.one:
    return Icons.repeat_one;
  case RepeatMode.all:
    return Icons.repeat;
  case RepeatMode.off:
  default:
    return Icons.repeat;
}
}

void _toggleFavorite(BuildContext context, AudioProvider audioProvider) {
// Toggle favorite functionality
}

void _showQueue(BuildContext context) {
// Show queue functionality
}

void _showVolumeSlider(BuildContext context, AudioProvider audioProvider) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: AppSpacing.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Volume',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Slider(
            value: audioProvider.volume,
            onChanged: (value) => audioProvider.setVolume(value),
            min: 0.0,
            max: 1.0,
          ),
        ],
      ),
    ),
  );
}

void _showMoreOptions(BuildContext context) {
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: AppSpacing.large,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Add to Playlist'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Track Info'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
  ),
);
}
