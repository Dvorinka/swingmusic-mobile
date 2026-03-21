import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music_models.dart';
import '../state/offline_controller.dart';
import '../state/player_controller.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OfflineController, PlayerController>(
      builder: (context, offline, player, _) {
        final scheme = Theme.of(context).colorScheme;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  'Downloads',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Sync pending analytics',
                  onPressed: offline.syncPending,
                  icon: offline.syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: offline.load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (offline.error != null) ...[
              Text(offline.error!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 8),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Offline downloads are stored on this device and playback works without connection. Pending listening analytics sync automatically once you are online.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 12),
            if (offline.activeTasks.isNotEmpty) ...[
              Text(
                'Active Tasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...offline.activeTasks.map(
                (task) => ListTile(
                  leading: const Icon(Icons.downloading),
                  title: Text(task.title),
                  subtitle: LinearProgressIndicator(value: task.progress),
                  trailing: Text(
                    '${(task.progress * 100).toStringAsFixed(0)}%',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Offline Tracks (${offline.offlineTracks.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (offline.offlineTracks.isEmpty)
              const Text('No local downloads yet.')
            else
              ...offline.offlineTracks.map(
                (entry) => ListTile(
                  leading: const Icon(Icons.download_done),
                  title: Text(entry.title),
                  subtitle: Text(
                    '${entry.artist} · ${entry.quality}\n${entry.localPath}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    final track = MusicTrack(
                      trackhash: entry.trackhash,
                      title: entry.title,
                      artist: entry.artist,
                      album: entry.album,
                      filepath: entry.remoteFilepath,
                      durationSeconds: 0,
                      bitrate: 0,
                    );
                    player.playTrack(track, source: 'offline');
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => offline.removeDownload(entry.trackhash),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
