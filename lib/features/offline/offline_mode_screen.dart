import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/track_model.dart';

class OfflineModeScreen extends StatefulWidget {
  const OfflineModeScreen({super.key});

  @override
  State<OfflineModeScreen> createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  final List<TrackModel> _downloadedTracks = [];
  int _totalDownloadSize = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Offline Mode',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSettings();
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Offline settings',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOfflineStatusCard(),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: _buildDownloadedTracksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineStatusCard() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(
                  Icons.cloud_download,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Mode Active',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_downloadedTracks.length} tracks downloaded',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(_totalDownloadSize / 1024 / 1024).toStringAsFixed(1)} MB used',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Switch(
            value: true,
            onChanged: (value) {
              // Toggle offline mode
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedTracksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Downloaded Tracks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _sortByTitle();
                  },
                  icon: const Icon(Icons.sort_by_alpha),
                  tooltip: 'Sort by title',
                ),
                IconButton(
                  onPressed: () {
                    _sortByArtist();
                  },
                  icon: const Icon(Icons.person),
                  tooltip: 'Sort by artist',
                ),
                IconButton(
                  onPressed: () {
                    _sortByDate();
                  },
                  icon: const Icon(Icons.calendar_today),
                  tooltip: 'Sort by date',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: _downloadedTracks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _downloadedTracks.length,
                  itemBuilder: (context, index) {
                    final track = _downloadedTracks[index];
                    return _buildTrackItem(track, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_download,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No downloaded tracks',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Download tracks to listen offline',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Browse Library'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(TrackModel track, int index) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          image: DecorationImage(
            image: NetworkImage(track.image),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        track.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        track.artists.isNotEmpty ? track.artists.first.name : 'Unknown Artist',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              _playTrack(track);
            },
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Play',
          ),
          IconButton(
            onPressed: () {
              _removeTrack(index);
            },
            icon: const Icon(Icons.delete),
            tooltip: 'Remove',
          ),
        ],
      ),
      onTap: () {
        // Navigate to track details
      },
    );
  }

  void _sortByTitle() {
    setState(() {
      _downloadedTracks.sort((a, b) => a.title.compareTo(b.title));
    });
  }

  void _sortByArtist() {
    setState(() {
      _downloadedTracks
          .sort((a, b) => a.artists.first.name.compareTo(b.artists.first.name));
    });
  }

  void _sortByDate() {
    setState(() {
      _downloadedTracks
          .sort((a, b) => a.lastModified.compareTo(b.lastModified));
    });
  }

  void _playTrack(TrackModel track) {
    // Play track functionality
  }

  void _removeTrack(int index) {
    setState(() {
      _downloadedTracks.removeAt(index);
      _calculateTotalSize();
    });
  }

  void _calculateTotalSize() {
    int totalSize = 0;
    for (final track in _downloadedTracks) {
      totalSize += track.duration ~/ 60 * 320; // Rough estimate
    }
    setState(() {
      _totalDownloadSize = totalSize;
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Download on Wi-Fi only'),
              subtitle: const Text('Only download when connected to Wi-Fi'),
              value: false,
              onChanged: (value) {
                // Toggle Wi-Fi only setting
              },
            ),
            SwitchListTile(
              title: const Text('Download quality'),
              subtitle: const Text('Choose audio quality for downloads'),
              value: true,
              onChanged: (value) {
                // Toggle download quality
              },
            ),
            SwitchListTile(
              title: const Text('Auto-download'),
              subtitle: const Text('Automatically download new tracks'),
              value: false,
              onChanged: (value) {
                // Toggle auto-download
              },
            ),
            ListTile(
              title: const Text('Clear cache'),
              subtitle: const Text('Remove all downloaded tracks'),
              leading: const Icon(Icons.delete_sweep),
              onTap: () {
                _clearCache();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    setState(() {
      _downloadedTracks.clear();
      _totalDownloadSize = 0;
    });
  }
}
