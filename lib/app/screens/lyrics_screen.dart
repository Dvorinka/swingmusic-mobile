import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/player_controller.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final ScrollController _scroll = ScrollController();
  int _lastAutoScrolledIndex = -1;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, _) {
        final track = player.currentTrack;
        if (track == null) {
          return const Scaffold(body: Center(child: Text('No track selected')));
        }

        final scheme = Theme.of(context).colorScheme;
        final cues = player.lyricsCues;
        final activeIndex = _activeLineIndex(player);

        if (activeIndex >= 0 && activeIndex != _lastAutoScrolledIndex) {
          _lastAutoScrolledIndex = activeIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scroll.hasClients) return;
            final target = (activeIndex * 58.0) - 220.0;
            _scroll.animateTo(
              target < 0 ? 0 : target,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lyrics'),
            actions: [
              IconButton(
                tooltip: 'Reload lyrics',
                onPressed: player.reloadLyrics,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: player.lyricsSynced
                            ? scheme.primaryContainer
                            : scheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Text(
                        player.lyricsSynced ? 'Synced' : 'Unsynced',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: player.lyricsSynced
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: player.lyricsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : cues.isEmpty
                    ? Center(
                        child: Text(
                          'No lyrics found for this track.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        itemCount: cues.length,
                        itemBuilder: (context, index) {
                          final cue = cues[index];
                          final isCurrent = index == activeIndex;
                          final isPast =
                              activeIndex >= 0 && index < activeIndex;
                          final distance = activeIndex == -1
                              ? 99
                              : (index - activeIndex).abs();

                          var alpha = 0.82;
                          if (!isCurrent && distance >= 5) {
                            alpha = 0.45;
                          } else if (!isCurrent && distance >= 3) {
                            alpha = 0.60;
                          }

                          final color = isCurrent
                              ? scheme.onSurface
                              : isPast
                              ? scheme.onSurface.withOpacity(alpha)
                              : scheme.onSurfaceVariant.withOpacity(
                                  alpha,
                                );

                          return InkWell(
                            onTap: () {
                              final seek = _seekTargetForIndex(player, index);
                              if (seek != null) {
                                player.seek(Duration(milliseconds: seek));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  fontSize: isCurrent ? 29 : 24,
                                  fontWeight: FontWeight.w700,
                                  height: 1.16,
                                  color: color,
                                ),
                                child: Text(cue.text),
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

  int _activeLineIndex(PlayerController player) {
    final cues = player.lyricsCues;
    if (cues.isEmpty) return -1;

    if (player.lyricsSynced) {
      final currentMs = player.position.inMilliseconds;
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

    if (cues.length == 1) return 0;
    return ((cues.length - 1) * player.progress).round().clamp(
      0,
      cues.length - 1,
    );
  }

  int? _seekTargetForIndex(PlayerController player, int index) {
    final cues = player.lyricsCues;
    if (index < 0 || index >= cues.length) return null;

    final synced = cues[index].timeMs;
    if (synced != null && synced >= 0) {
      return synced;
    }

    if (player.duration.inMilliseconds <= 0 || cues.length <= 1) return null;
    final ratio = index / (cues.length - 1);
    return (player.duration.inMilliseconds * ratio).round();
  }
}
