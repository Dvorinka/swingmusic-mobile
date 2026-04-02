import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/offline_controller.dart';
import '../state/player_controller.dart';
import '../widgets/progress_waveform.dart';
import 'lyrics_screen.dart';
import 'queue_screen.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerController, OfflineController>(
      builder: (context, player, offline, _) {
        final track = player.currentTrack;
        if (track == null) {
          return const Scaffold(body: Center(child: Text('No track selected')));
        }

        final scheme = Theme.of(context).colorScheme;
        final lyrics = player.lyricsLines;
        final cues = player.lyricsCues;
        final lyricsHeight = MediaQuery.sizeOf(context).height * 0.46;

        final currentLine = lyrics.isEmpty
            ? -1
            : player.lyricsSynced
                ? _currentSyncedLine(cues, player.position.inMilliseconds)
                : ((lyrics.length - 1) * player.progress).round().clamp(
                      0,
                      lyrics.length - 1,
                    );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
            actions: [
              IconButton(
                tooltip: 'Queue',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QueueScreen()),
                  );
                },
                icon: const Icon(Icons.queue_music),
              ),
              IconButton(
                tooltip: 'Open lyrics',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LyricsScreen()),
                  );
                },
                icon: const Icon(Icons.lyrics_outlined),
              ),
              IconButton(
                tooltip: 'Reload lyrics',
                onPressed: player.reloadLyrics,
                icon: const Icon(Icons.lyrics),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withValues(alpha: 0.18),
                      scheme.surfaceContainerHighest,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 92,
                        height: 92,
                        child: track.imageUrl == null || track.imageUrl!.isEmpty
                            ? Container(
                                color: scheme.surface,
                                child: const Icon(Icons.album, size: 42),
                              )
                            : Image.network(track.imageUrl!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          if (lyrics.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                player.lyricsSynced ? 'synced' : 'unsynced',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ProgressWaveform(
                      seed: track.id,
                      progress: player.progress,
                      onSeekRatio: (ratio) {
                        final ms =
                            (player.duration.inMilliseconds * ratio).round();
                        player.seek(Duration(milliseconds: ms));
                      },
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: player.progress,
                      onChanged: (value) {
                        final ms =
                            (player.duration.inMilliseconds * value).round();
                        player.seek(Duration(milliseconds: ms));
                      },
                    ),
                    Row(
                      children: [
                        Text(player.positionLabel),
                        const Spacer(),
                        Text(player.durationLabel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 34,
                          onPressed: player.playPrevious,
                          icon: const Icon(Icons.skip_previous),
                        ),
                        IconButton(
                          iconSize: 52,
                          onPressed: player.togglePlayPause,
                          icon: Icon(
                            player.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                          ),
                        ),
                        IconButton(
                          iconSize: 34,
                          onPressed: player.playNext,
                          icon: const Icon(Icons.skip_next),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: offline.isDownloaded(track.trackhash)
                        ? null
                        : () => offline.downloadTrack(
                              track,
                              collectionLabel: 'album ${track.album}',
                            ),
                    icon: const Icon(Icons.download_for_offline),
                    label: Text(
                      offline.isDownloaded(track.trackhash)
                          ? 'Downloaded'
                          : 'Download Offline',
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: player.stop,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Lyrics', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Container(
                height: lyricsHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scheme.primary.withValues(alpha: 0.25),
                      scheme.surfaceContainerHighest,
                    ],
                  ),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: player.lyricsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : lyrics.isEmpty
                        ? Center(
                            child: Text(
                              'No lyrics found for this track.',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount: lyrics.length,
                            itemBuilder: (context, index) {
                              final distance = currentLine == -1
                                  ? 99
                                  : (index - currentLine).abs();

                              final isCurrent = index == currentLine;
                              final isSeen =
                                  currentLine != -1 && index < currentLine;

                              var opacity = 1.0;
                              if (!isCurrent && distance >= 3) {
                                opacity = 0.6;
                              } else if (!isCurrent && distance == 2) {
                                opacity = 0.75;
                              } else if (!isCurrent && distance == 1) {
                                opacity = 0.88;
                              }

                              final color = isCurrent
                                  ? Colors.white
                                  : isSeen
                                      ? Colors.white
                                          .withValues(alpha: 0.85 * opacity)
                                      : Colors.white
                                          .withValues(alpha: 0.72 * opacity);

                              return InkWell(
                                onTap: () {
                                  if (player.duration.inMilliseconds <= 0 ||
                                      lyrics.length <= 1) {
                                    return;
                                  }
                                  final ratio = index / (lyrics.length - 1);
                                  final ms =
                                      (player.duration.inMilliseconds * ratio)
                                          .round();
                                  player.seek(Duration(milliseconds: ms));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 220),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: isCurrent ? 32 : 26,
                                      fontWeight: FontWeight.w700,
                                      height: 1.16,
                                    ),
                                    child: Text(lyrics[index]),
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

  int _currentSyncedLine(List<LyricsCue> cues, int currentMs) {
    var found = -1;
    for (var i = 0; i < cues.length; i++) {
      final time = cues[i].timeMs;
      if (time == null) continue;
      if (time <= currentMs) {
        found = i;
      } else {
        break;
      }
    }
    return found;
  }
}
