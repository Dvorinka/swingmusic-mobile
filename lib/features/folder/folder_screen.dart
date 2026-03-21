import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../data/models/track_model.dart';
import 'providers/folders_provider.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFolders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFolders() async {
    final provider = context.read<FoldersProvider>();
    await provider.loadFolders();
    setState(() {
      _filteredItems = provider.folders;
    });
  }

  Future<void> _loadFolderTracks(String folderHash, String folderName) async {
    final provider = context.read<FoldersProvider>();
    await provider.loadFolderTracks(folderHash, folderName);
    setState(() {
      _filteredItems = provider.currentFolderTracks;
    });
  }

  void _filterItems(String query) {
    setState(() {
      final provider = context.read<FoldersProvider>();

      if (query.isEmpty) {
        _filteredItems = provider.hasCurrentFolder
            ? provider.currentFolderTracks
            : provider.folders;
      } else {
        if (provider.hasCurrentFolder) {
          _filteredItems = provider.currentFolderTracks.where((track) {
            return track.title.toLowerCase().contains(query.toLowerCase()) ||
                track.artistNames.toLowerCase().contains(query.toLowerCase());
          }).toList();
        } else {
          _filteredItems = provider.folders.where((folder) {
            final name = (folder['name'] ?? folder['title'] ?? '')
                .toString()
                .toLowerCase();
            return name.contains(query.toLowerCase());
          }).toList();
        }
      }
    });
  }

  void _navigateBack() {
    final provider = context.read<FoldersProvider>();
    if (provider.hasCurrentFolder) {
      provider.clearCurrentFolder();
      setState(() {
        _filteredItems = provider.folders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoldersProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              provider.hasCurrentFolder
                  ? provider.currentFolderName ?? 'Folder'
                  : 'Music Library',
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: provider.hasCurrentFolder
                ? IconButton(
                    onPressed: _navigateBack,
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
            actions: [
              PopupMenuButton<String>(
                onSelected: (action) => _handleMenuAction(action, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'sort_name',
                    child: ListTile(
                      leading: Icon(Icons.sort_by_alpha),
                      title: Text('Sort by Name'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'sort_date',
                    child: ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Sort by Date'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Breadcrumb Navigation
              _buildBreadcrumbNavigation(provider),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search in current folder...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterItems('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _filterItems,
                ),
              ),

              // Folder Contents
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null
                    ? _buildErrorState(provider.errorMessage!)
                    : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildFolderContents(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumbNavigation(FoldersProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: provider.hasCurrentFolder ? _navigateBack : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: !provider.hasCurrentFolder
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home,
                    size: 20,
                    color: !provider.hasCurrentFolder
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: !provider.hasCurrentFolder
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.hasCurrentFolder) ...[
            const Icon(Icons.chevron_right, size: 16),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.currentFolderName ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderContents(FoldersProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];

        if (item is TrackModel) {
          return _buildTrackTile(item);
        } else {
          return _buildFolderTile(item, provider);
        }
      },
    );
  }

  Widget _buildFolderTile(
    Map<String, dynamic> folder,
    FoldersProvider provider,
  ) {
    final name = folder['name'] ?? folder['title'] ?? 'Unknown';
    final itemCount = folder['count'] ?? folder['itemCount'] ?? 0;
    final path = folder['path'] ?? '';
    final hash =
        folder['hash'] ?? folder['folderhash'] ?? path.hashCode.toString();

    return Card(
      child: InkWell(
        onTap: () => _loadFolderTracks(hash, name),
        borderRadius: BorderRadius.circular(12),
        onLongPress: () => _showFolderOptions(name, hash),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$itemCount items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackTile(TrackModel track) {
    return Card(
      child: InkWell(
        onTap: () => _playTrack(track),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Track artwork or icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: track.image.isNotEmpty
                    ? Image.network(
                        track.image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultTrackIcon(),
                      )
                    : _buildDefaultTrackIcon(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artistNames,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          track.durationFormatted,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${track.bitrate} kbps',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _playTrack(track),
                icon: const Icon(Icons.play_arrow),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultTrackIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'This folder is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add music files to see them here',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              'Failed to load folders',
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
            ElevatedButton(onPressed: _loadFolders, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, FoldersProvider provider) {
    switch (action) {
      case 'sort_name':
        setState(() {
          _filteredItems.sort((a, b) {
            final nameA = a is TrackModel
                ? a.title
                : (a['name'] ?? '').toString();
            final nameB = b is TrackModel
                ? b.title
                : (b['name'] ?? '').toString();
            return nameA.compareTo(nameB);
          });
        });
        break;
      case 'sort_date':
        setState(() {
          _filteredItems.sort((a, b) {
            final dateA = a is TrackModel
                ? a.lastModified
                : (a['lastModified'] ?? 0) as int;
            final dateB = b is TrackModel
                ? b.lastModified
                : (b['lastModified'] ?? 0) as int;
            return dateB.compareTo(dateA);
          });
        });
        break;
    }
  }

  void _showFolderOptions(String folderName, String folderHash) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play All'),
              onTap: () {
                Navigator.pop(context);
                _playAllInFolder(folderHash, folderName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text('Shuffle All'),
              onTap: () {
                Navigator.pop(context);
                _shuffleAllInFolder(folderHash, folderName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to playlist')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playAllInFolder(String folderHash, String folderName) async {
    final provider = context.read<FoldersProvider>();
    await provider.loadFolderTracks(folderHash, folderName);

    if (provider.currentFolderTracks.isNotEmpty) {
      if (!mounted) return;

      final audioProvider = context.read<AudioProvider>();
      audioProvider.setQueue(provider.currentFolderTracks);
      audioProvider.loadTrack(provider.currentFolderTracks.first);
      audioProvider.play();

      if (mounted) {
        Navigator.pushNamed(context, '/player');
      }
    }
  }

  Future<void> _shuffleAllInFolder(String folderHash, String folderName) async {
    final provider = context.read<FoldersProvider>();
    await provider.loadFolderTracks(folderHash, folderName);

    if (provider.currentFolderTracks.isNotEmpty) {
      final tracks = List<TrackModel>.from(provider.currentFolderTracks);
      tracks.shuffle();

      if (!mounted) return;

      final audioProvider = context.read<AudioProvider>();
      audioProvider.setQueue(tracks);
      audioProvider.loadTrack(tracks.first);
      audioProvider.play();

      if (mounted) {
        Navigator.pushNamed(context, '/player');
      }
    }
  }

  void _playTrack(TrackModel track) {
    final provider = context.read<FoldersProvider>();
    final audioProvider = context.read<AudioProvider>();

    if (provider.hasCurrentFolder) {
      audioProvider.setQueue(provider.currentFolderTracks);
      final trackIndex = provider.currentFolderTracks.indexWhere(
        (t) => t.trackhash == track.trackhash,
      );
      if (trackIndex >= 0) {
        audioProvider.jumpToIndex(trackIndex);
      } else {
        audioProvider.loadTrack(track);
      }
    } else {
      audioProvider.setQueue([track]);
      audioProvider.loadTrack(track);
    }

    audioProvider.play();
    Navigator.pushNamed(context, '/player');
  }
}
