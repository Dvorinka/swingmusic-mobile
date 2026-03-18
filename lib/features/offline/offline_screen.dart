import 'package:flutter/material.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  bool _isOfflineMode = false;
  final List<Map<String, dynamic>> _downloadedTracks = [];
  int _totalDownloads = 0;
  int _completedDownloads = 0;
  double _totalDownloadSize = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Switch(
            value: _isOfflineMode,
            onChanged: (value) {
              setState(() {
                _isOfflineMode = value;
              });
            },
            activeThumbColor: Theme.of(context).colorScheme.primary,
            activeTrackColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Mode Toggle Card
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: _isOfflineMode 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Offline Mode',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isOfflineMode 
                      ? 'Download music for offline listening'
                      : 'Connect to server for online mode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Downloads Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Downloads Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Downloads',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _clearDownloads,
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Clear All',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Download Stats
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Total', _totalDownloads.toString(), Icons.download),
                        _buildStatCard('Completed', _completedDownloads.toString(), Icons.check_circle),
                        _buildStatCard('Size', _formatFileSize(_totalDownloadSize), Icons.storage),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Downloaded Tracks List
                  Expanded(
                    child: _downloadedTracks.isEmpty
                        ? _buildEmptyState()
                        : _buildDownloadsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No downloads yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _simulateDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download),
                const SizedBox(width: 8),
                const Text('Download Sample Track'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _downloadedTracks.length,
      itemBuilder: (context, index) {
        final track = _downloadedTracks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: track['isOffline'] == true
                    ? const Icon(Icons.offline_pin, color: Colors.green)
                    : const Icon(Icons.music_note, color: Colors.blue),
              ),
            ),
            title: Text(
              track['title']?.toString() ?? 'Unknown Track',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              track['artist']?.toString() ?? 'Unknown Artist',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatFileSize(track['size']?.toDouble() ?? 0.0),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    _handleTrackAction(track, value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play',
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow, size: 16),
                          const SizedBox(width: 8),
                          const Text('Play'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatFileSize(double bytes) {
    if (bytes < 1024) {
      return '${bytes.toStringAsFixed(0)} B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  void _clearDownloads() {
    setState(() {
      _downloadedTracks.clear();
      _totalDownloads = 0;
      _completedDownloads = 0;
      _totalDownloadSize = 0.0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All downloads cleared')),
    );
  }

  void _simulateDownload() {
    setState(() {
      _totalDownloads++;
      _completedDownloads++;
      final trackSize = 5.2 * 1024 * 1024; // 5.2 MB
      _totalDownloadSize += trackSize;
      
      _downloadedTracks.add({
        'id': 'track_${_totalDownloads}',
        'title': 'Sample Track $_totalDownloads',
        'artist': 'Sample Artist',
        'album': 'Sample Album',
        'duration': '3:45',
        'size': trackSize,
        'isOffline': true,
        'downloadDate': DateTime.now().toIso8601String(),
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample track downloaded')),
    );
  }

  void _handleTrackAction(Map<String, dynamic> track, String action) {
    switch (action) {
      case 'play':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing: ${track['title']}')),
        );
        break;
      case 'delete':
        setState(() {
          _downloadedTracks.remove(track);
          _totalDownloads--;
          if (track['isOffline'] == true) {
            _completedDownloads--;
            _totalDownloadSize -= (track['size'] ?? 0.0);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted: ${track['title']}')),
        );
        break;
    }
  }
}
