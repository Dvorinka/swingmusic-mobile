import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/providers/audio_provider.dart';
import '../../core/constants/app_spacing.dart';
import 'providers/download_provider.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Settings
  bool _wifiOnly = true;
  bool _highQuality = false;
  String _downloadPath = '/storage/emulated/0/Android/data/com.swingmusic/files/Music';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    _loadSettings();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadProvider>().loadDownloads();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _wifiOnly = prefs.getBool('wifi_only') ?? true;
        _highQuality = prefs.getBool('high_quality') ?? false;
        _downloadPath = prefs.getString('download_path') ?? '/storage/emulated/0/Android/data/com.swingmusic/files/Music';
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('wifi_only', _wifiOnly);
      await prefs.setBool('high_quality', _highQuality);
      await prefs.setString('download_path', _downloadPath);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Downloads',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            onPressed: _showDownloadSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Downloading'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<DownloadProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && !provider.hasDownloads) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.errorMessage != null && !provider.hasDownloads) {
              return _buildErrorState(provider.errorMessage!, provider);
            }
            
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDownloadsList(provider.allDownloads, provider, 'all'),
                _buildDownloadsList(provider.downloads, provider, 'downloading'),
                _buildDownloadsList(provider.completedDownloads, provider, 'completed'),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _showAddDownloadDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDownloadsList(List<DownloadItem> downloads, DownloadProvider provider, String type) {
    if (downloads.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadDownloads(),
      child: ListView.builder(
        padding: AppSpacing.paddingMD,
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          final download = downloads[index];
          return DownloadTile(
            download: download,
            onTap: () => _handleDownloadTap(download, provider),
            onPlay: download.status == DownloadStatus.completed 
                ? () => _playDownload(download) 
                : null,
            onDelete: () => _deleteDownload(download, provider),
            onPause: download.status == DownloadStatus.downloading 
                ? () => _pauseDownload(download, provider)
                : null,
            onResume: download.status == DownloadStatus.paused
                ? () => _resumeDownload(download, provider)
                : null,
            onRetry: download.status == DownloadStatus.failed
                ? () => _retryDownload(download, provider)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case 'downloading':
        title = 'No downloads in progress';
        subtitle = 'Start downloading tracks to see them here';
        icon = Icons.download_outlined;
        break;
      case 'completed':
        title = 'No completed downloads';
        subtitle = 'Completed downloads will appear here';
        icon = Icons.download_done_outlined;
        break;
      default:
        title = 'No downloads';
        subtitle = 'Download tracks to see them here';
        icon = Icons.folder_open;
        break;
    }

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, DownloadProvider provider) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load downloads',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadDownloads(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDownloadTap(DownloadItem download, DownloadProvider provider) {
    if (download.status == DownloadStatus.completed) {
      _playDownload(download);
    } else {
      _showDownloadDetails(download, provider);
    }
  }

  void _playDownload(DownloadItem download) {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.setQueue([download.track]);
    audioProvider.loadTrack(download.track);
    audioProvider.play();
    
    Navigator.pushNamed(context, '/player');
  }

  void _deleteDownload(DownloadItem download, DownloadProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Are you sure you want to delete "${download.track.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteDownload(download.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _pauseDownload(DownloadItem download, DownloadProvider provider) {
    provider.pauseDownload(download.id);
  }

  void _resumeDownload(DownloadItem download, DownloadProvider provider) {
    provider.resumeDownload(download.id);
  }

  void _retryDownload(DownloadItem download, DownloadProvider provider) {
    provider.retryDownload(download.id);
  }

  void _showDownloadDetails(DownloadItem download, DownloadProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              download.track.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              download.track.artistNames,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            if (download.status == DownloadStatus.downloading || 
                download.status == DownloadStatus.paused) ...[
              LinearProgressIndicator(
                value: download.progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${download.progressPercentage} - ${download.sizeInfo}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (download.status == DownloadStatus.downloading)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _pauseDownload(download, provider);
                    },
                    child: const Text('Pause'),
                  )
                else if (download.status == DownloadStatus.paused)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resumeDownload(download, provider);
                    },
                    child: const Text('Resume'),
                  )
                else if (download.status == DownloadStatus.failed)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _retryDownload(download, provider);
                    },
                    child: const Text('Retry'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteDownload(download, provider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Download'),
        content: const Text('Search for tracks and tap the download button to add them to your downloads.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDownloadSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Download Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Download only on Wi-Fi'),
              subtitle: const Text('Save mobile data by downloading only on Wi-Fi'),
              value: _wifiOnly,
              onChanged: (value) {
                setState(() {
                  _wifiOnly = value;
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: const Text('High quality downloads'),
              subtitle: const Text('Download in highest available quality'),
              value: _highQuality,
              onChanged: (value) {
                setState(() {
                  _highQuality = value;
                });
                _saveSettings();
              },
            ),
            ListTile(
              title: const Text('Download location'),
              subtitle: Text(_downloadPath),
              trailing: const Icon(Icons.folder),
              onTap: _openFolderPicker,
            ),
            const SizedBox(height: 8),
            Consumer<DownloadProvider>(
              builder: (context, provider, _) {
                if (provider.completedDownloads.isNotEmpty) {
                  return ListTile(
                    leading: Icon(
                      Icons.cleaning_services,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text('Clear completed downloads'),
                    subtitle: Text('${provider.completedDownloads.length} completed'),
                    onTap: () {
                      Navigator.pop(context);
                      provider.clearCompletedDownloads();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFolderPicker() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Download Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose where to store your downloaded music:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Default Music Folder'),
              subtitle: const Text('/storage/emulated/0/Android/data/com.swingmusic/files/Music'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _downloadPath = '/storage/emulated/0/Android/data/com.swingmusic/files/Music';
                });
                _saveSettings();
              },
            ),
            ListTile(
              title: const Text('Downloads Folder'),
              subtitle: const Text('/storage/emulated/0/Download/SwingMusic'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _downloadPath = '/storage/emulated/0/Download/SwingMusic';
                });
                _saveSettings();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class DownloadTile extends StatelessWidget {
  final DownloadItem download;
  final VoidCallback onTap;
  final VoidCallback? onPlay;
  final VoidCallback onDelete;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onRetry;

  const DownloadTile({
    super.key,
    required this.download,
    required this.onTap,
    required this.onDelete,
    this.onPlay,
    this.onPause,
    this.onResume,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Album Art
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: download.track.image.isNotEmpty
                      ? Image.network(
                          download.track.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultArtwork(context);
                          },
                        )
                      : _buildDefaultArtwork(context),
                ),
              ),

              const SizedBox(width: 16),

              // Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      download.track.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      download.track.artistNames,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Status and Progress
                    Row(
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Progress or Size
                        if (download.status == DownloadStatus.downloading || 
                            download.status == DownloadStatus.paused) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                LinearProgressIndicator(
                                  value: download.progress,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  download.progressPercentage,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            '${download.totalSize.toStringAsFixed(1)} MB',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        // Action Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (download.status == DownloadStatus.completed && onPlay != null)
                              IconButton(
                                onPressed: onPlay,
                                icon: const Icon(Icons.play_arrow),
                                color: Theme.of(context).colorScheme.primary,
                                iconSize: 20,
                              )
                            else if (download.status == DownloadStatus.downloading && onPause != null)
                              IconButton(
                                onPressed: onPause,
                                icon: const Icon(Icons.pause),
                                color: Theme.of(context).colorScheme.primary,
                                iconSize: 20,
                              )
                            else if (download.status == DownloadStatus.paused && onResume != null)
                              IconButton(
                                onPressed: onResume,
                                icon: const Icon(Icons.play_arrow),
                                color: Theme.of(context).colorScheme.primary,
                                iconSize: 20,
                              )
                            else if (download.status == DownloadStatus.failed && onRetry != null)
                              IconButton(
                                onPressed: onRetry,
                                icon: const Icon(Icons.refresh),
                                color: Theme.of(context).colorScheme.primary,
                                iconSize: 20,
                              ),
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.more_vert),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultArtwork(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.primary,
          ],
        ),
      ),
      child: Icon(
        Icons.music_note,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 28,
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (download.status) {
      case DownloadStatus.downloading:
        return Theme.of(context).colorScheme.primary;
      case DownloadStatus.paused:
        return Theme.of(context).colorScheme.secondary;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }

  IconData _getStatusIcon() {
    switch (download.status) {
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause;
      case DownloadStatus.completed:
        return Icons.check;
      case DownloadStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (download.status) {
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Complete';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }
}
