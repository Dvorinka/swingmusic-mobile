import 'package:flutter/material.dart';
import '../../data/models/track_model.dart';

class TrackListTile extends StatelessWidget {
  final TrackModel track;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final bool isPlaying;
  final bool showAlbumArt;
  final Widget? trailing;

  const TrackListTile({
    super.key,
    required this.track,
    this.onTap,
    this.onPlay,
    this.isPlaying = false,
    this.showAlbumArt = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: showAlbumArt
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: track.image.isNotEmpty
                    ? Image.network(
                        track.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultArt(context);
                        },
                      )
                    : _buildDefaultArt(context),
              ),
            )
          : SizedBox(
              width: 24,
              child: Center(
                child: isPlaying
                    ? Icon(
                        Icons.equalizer,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Text(
                        '${track.track}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
      title: Text(
        track.displayTitle,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
          color: isPlaying
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.artistNames,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (track.displayAlbum.isNotEmpty)
            Text(
              track.displayAlbum,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track.durationFormatted,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              if (onPlay != null)
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onPlay,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
    );
  }

  Widget _buildDefaultArt(BuildContext context) {
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
        Icons.music_note,
        size: 24,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
