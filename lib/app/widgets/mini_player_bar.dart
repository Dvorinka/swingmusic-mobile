import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/player_controller.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key, required this.onOpenPlayer});

  final VoidCallback onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, _) {
        final track = player.currentTrack;
        if (track == null) {
          return const SizedBox.shrink();
        }

        final scheme = Theme.of(context).colorScheme;

        return Material(
          color: scheme.surfaceContainerHighest,
          child: InkWell(
            onTap: onOpenPlayer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 66,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child:
                              track.imageUrl == null || track.imageUrl!.isEmpty
                              ? Container(
                                  color: scheme.surface,
                                  child: Icon(
                                    Icons.music_note,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                )
                              : Image.network(
                                  track.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              track.artist,
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
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: player.playPrevious,
                        icon: const Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: player.togglePlayPause,
                        icon: Icon(
                          player.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: player.playNext,
                        icon: const Icon(Icons.skip_next),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                LinearProgressIndicator(minHeight: 2.2, value: player.progress),
              ],
            ),
          ),
        );
      },
    );
  }
}
