import 'package:flutter/material.dart';

import '../models/music_models.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onPlay,
    this.onFavorite,
    this.onDownload,
    this.trailing,
  });

  final MusicTrack track;
  final VoidCallback onPlay;
  final VoidCallback? onFavorite;
  final VoidCallback? onDownload;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPlay,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: track.imageUrl == null || track.imageUrl!.isEmpty
                        ? Container(
                            color: scheme.surface,
                            child: Icon(
                              Icons.music_note,
                              color: scheme.onSurfaceVariant,
                              size: 21,
                            ),
                          )
                        : Image.network(track.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${track.artist} · ${track.durationLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onFavorite != null)
                        IconButton(
                          tooltip: 'Favorite',
                          visualDensity: VisualDensity.compact,
                          onPressed: onFavorite,
                          icon: Icon(
                            track.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: track.isFavorite ? Colors.red : null,
                          ),
                        ),
                      if (onDownload != null)
                        IconButton(
                          tooltip: 'Download',
                          visualDensity: VisualDensity.compact,
                          onPressed: onDownload,
                          icon: const Icon(Icons.download_for_offline_outlined),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
