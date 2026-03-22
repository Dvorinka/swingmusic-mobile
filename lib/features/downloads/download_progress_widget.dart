import 'package:flutter/material.dart';
import '../../services/download_progress_service.dart';

/// Widget displaying active downloads with real-time progress
class DownloadProgressWidget extends StatefulWidget {
  final DownloadProgressService service;
  final VoidCallback? onCompleted;
  final Function(DownloadProgress)? onTrackTap;

  const DownloadProgressWidget({
    super.key,
    required this.service,
    this.onCompleted,
    this.onTrackTap,
  });

  @override
  State<DownloadProgressWidget> createState() => _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState extends State<DownloadProgressWidget> {
  List<DownloadProgress> _downloads = [];
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _fetchDownloads();
    // Poll for updates every 2 seconds while downloads are active
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _fetchDownloads();
        _startPolling();
      }
    });
  }

  Future<void> _fetchDownloads() async {
    final downloads = await widget.service.getActiveDownloads();
    if (mounted) {
      setState(() {
        _downloads = downloads;
      });
    }
  }

  Future<void> _cancelDownload(String downloadId) async {
    await widget.service.cancelDownload(downloadId);
    await _fetchDownloads();
  }

  @override
  Widget build(BuildContext context) {
    final activeDownloads = _downloads.where((d) => d.isActive).toList();

    if (activeDownloads.isEmpty) {
      return const SizedBox.shrink();
    }

    final overallProgress = activeDownloads.isEmpty
        ? 0.0
        : activeDownloads.map((d) => d.progressPercent).reduce((a, b) => a + b) /
            activeDownloads.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.download, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Downloads',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${activeDownloads.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LinearProgressIndicator(
                          value: overallProgress / 100,
                          backgroundColor: Theme.of(context).dividerColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${overallProgress.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Download list
          if (_expanded) ...[
            Divider(height: 1, color: Theme.of(context).dividerColor),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeDownloads.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor,
              ),
              itemBuilder: (context, index) {
                final download = activeDownloads[index];
                return _buildDownloadItem(download);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadItem(DownloadProgress download) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  download.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  download.artist,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: download.progressPercent / 100,
                  backgroundColor: Theme.of(context).dividerColor,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      download.formattedSize,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (download.formattedSpeed.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        download.formattedSpeed,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (download.formattedETA.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        'ETA: ${download.formattedETA}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(download.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              download.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(download.status),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Cancel button
          if (download.status == 'downloading')
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => _cancelDownload(download.downloadId),
              tooltip: 'Cancel',
              color: Theme.of(context).colorScheme.error,
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'queued':
        return Colors.orange;
      case 'downloading':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
