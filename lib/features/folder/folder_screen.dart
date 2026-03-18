import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../data/models/track_model.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<FolderItem> _folderItems = [];
  List<FolderItem> _currentPath = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _currentFolderId = 'root';

  @override
  void initState() {
    super.initState();
    _loadFolderContents(_currentFolderId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFolderContents(String folderId) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isLoading = false;
      if (folderId == 'root') {
        _currentPath = [];
        _folderItems = [
          FolderItem(
            id: 'music',
            name: 'Music',
            type: FolderType.folder,
            itemCount: 156,
            path: '/music',
            modifiedDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          FolderItem(
            id: 'downloads',
            name: 'Downloads',
            type: FolderType.folder,
            itemCount: 42,
            path: '/downloads',
            modifiedDate: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          FolderItem(
            id: 'rock',
            name: 'Rock',
            type: FolderType.folder,
            itemCount: 89,
            path: '/music/rock',
            modifiedDate: DateTime.now().subtract(const Duration(days: 7)),
          ),
          FolderItem(
            id: 'pop',
            name: 'Pop',
            type: FolderType.folder,
            itemCount: 67,
            path: '/music/pop',
            modifiedDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
          FolderItem(
            id: 'jazz',
            name: 'Jazz',
            type: FolderType.folder,
            itemCount: 34,
            path: '/music/jazz',
            modifiedDate: DateTime.now().subtract(const Duration(days: 14)),
          ),
          FolderItem(
            id: 'electronic',
            name: 'Electronic',
            type: FolderType.folder,
            itemCount: 78,
            path: '/music/electronic',
            modifiedDate: DateTime.now().subtract(const Duration(days: 5)),
          ),
          FolderItem(
            id: 'classical',
            name: 'Classical',
            type: FolderType.folder,
            itemCount: 45,
            path: '/music/classical',
            modifiedDate: DateTime.now().subtract(const Duration(days: 21)),
          ),
        ];
      } else if (folderId == 'music') {
        _currentPath = [
          FolderItem(id: 'root', name: '..', type: FolderType.folder, path: '/'),
          FolderItem(id: 'rock', name: 'Rock', type: FolderType.folder, itemCount: 89, path: '/music/rock'),
          FolderItem(id: 'pop', name: 'Pop', type: FolderType.folder, itemCount: 67, path: '/music/pop'),
          FolderItem(id: 'jazz', name: 'Jazz', type: FolderType.folder, itemCount: 34, path: '/music/jazz'),
          FolderItem(id: 'electronic', name: 'Electronic', type: FolderType.folder, itemCount: 78, path: '/music/electronic'),
          FolderItem(id: 'classical', name: 'Classical', type: FolderType.folder, itemCount: 45, path: '/music/classical'),
        ];
        _folderItems = [
          TrackFolderItem(
            id: '1',
            name: 'Bohemian Rhapsody.mp3',
            artist: 'Queen',
            album: 'A Night at the Opera',
            duration: 334,
            size: 5.2,
            modifiedDate: DateTime.now().subtract(const Duration(days: 30)),
          ),
          TrackFolderItem(
            id: '2',
            name: 'Stairway to Heaven.mp3',
            artist: 'Led Zeppelin',
            album: 'Led Zeppelin IV',
            duration: 482,
            size: 7.8,
            modifiedDate: DateTime.now().subtract(const Duration(days: 25)),
          ),
          TrackFolderItem(
            id: '3',
            name: 'Hotel California.mp3',
            artist: 'Eagles',
            album: 'Hotel California',
            duration: 391,
            size: 6.1,
            modifiedDate: DateTime.now().subtract(const Duration(days: 20)),
          ),
          TrackFolderItem(
            id: '4',
            name: 'Sweet Child O\' Mine.mp3',
            artist: 'Queen',
            album: 'A Night at the Opera',
            duration: 348,
            size: 5.4,
            modifiedDate: DateTime.now().subtract(const Duration(days: 15)),
          ),
          TrackFolderItem(
            id: '5',
            name: 'Another Brick in the Wall.mp3',
            artist: 'Pink Floyd',
            album: 'The Wall',
            duration: 623,
            size: 9.8,
            modifiedDate: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ];
      } else {
        // Handle other folders with sample data
        _currentPath = [
          FolderItem(id: 'root', name: '..', type: FolderType.folder, path: '/'),
        ];
        _folderItems = [
          TrackFolderItem(
            id: '1',
            name: 'Sample Track.mp3',
            artist: 'Sample Artist',
            album: 'Sample Album',
            duration: 240,
            size: 4.2,
            modifiedDate: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getFolderTitle()),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: _currentFolderId != 'root'
            ? IconButton(
                onPressed: () => _navigateToFolder('root'),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_name',
                child: ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: Text('Sort by Name'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sort_date',
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text('Sort by Date'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sort_size',
                child: ListTile(
                  leading: const Icon(Icons.storage),
                  title: Text('Sort by Size'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'view_list',
                child: ListTile(
                  leading: const Icon(Icons.list),
                  title: Text('List View'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'view_grid',
                child: ListTile(
                  leading: const Icon(Icons.grid_view),
                  title: Text('Grid View'),
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
          _buildBreadcrumbNavigation(),
          
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
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                _filterItems(value);
              },
            ),
          ),
          
          // Folder Contents
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _folderItems.isEmpty
                    ? _buildEmptyState()
                    : _buildFolderContents(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Root/Home
            InkWell(
              onTap: () => _navigateToFolder('root'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _currentFolderId == 'root'
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
                      color: _currentFolderId == 'root'
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: _currentFolderId == 'root'
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Breadcrumb items
            ..._currentPath.map((item) {
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_right, size: 16),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _navigateToFolder(item.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: item.id == _currentFolderId
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: item.id == _currentFolderId
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderContents() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _folderItems.length,
      itemBuilder: (context, index) {
        final item = _folderItems[index];
        
        if (item is TrackFolderItem) {
          return TrackFolderTile(
            track: item,
            onTap: () => _playTrack(item),
            onPlay: () => _playTrack(item),
          );
        } else {
          return FolderTile(
            folder: item,
            onTap: () => _navigateToFolder(item.id),
            onLongPress: () => _showFolderOptions(item),
          );
        }
      },
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

  String _getFolderTitle() {
    if (_currentFolderId == 'root') {
      return 'Music Library';
    } else {
      final folder = _currentPath.firstWhere(
        (item) => item.id == _currentFolderId,
        orElse: () => FolderItem(id: '', name: '', type: FolderType.folder),
      );
      return folder.name;
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _loadFolderContents(_currentFolderId);
      } else {
        // Filter items (in real app, this would call API)
        _folderItems = _folderItems.where((item) {
          final name = item.name.toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToFolder(String folderId) {
    setState(() {
      _currentFolderId = folderId;
    });
    _loadFolderContents(folderId);
  }

  void _playTrack(TrackFolderItem track) {
    final trackModel = TrackModel(
      id: int.parse(track.id),
      title: track.name,
      album: track.album,
      albumhash: track.album.hashCode.toString(),
      artists: [],
      albumartists: [],
      artisthashes: [],
      track: 0,
      disc: 1,
      duration: track.duration,
      bitrate: 320,
      filepath: track.id, // Use ID as filepath for demo
      folder: '',
      genres: [],
      genrehashes: [],
      copyright: '',
      date: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      lastModified: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      trackhash: track.id,
      image: '',
      weakHash: '',
      extra: {},
      lastplayed: 0,
      playcount: 0,
      playduration: track.duration,
      explicit: false,
      favUserids: [],
      isFavorite: false,
      score: 0.0,
    );

    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.setQueue([trackModel]);
    audioProvider.loadTrack(trackModel);
    audioProvider.play();
    
    Navigator.pushNamed(context, '/player');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort_name':
        setState(() {
          _folderItems.sort((a, b) => a.name.compareTo(b.name));
        });
        break;
      case 'sort_date':
        setState(() {
          _folderItems.sort((a, b) => b.modifiedDate!.compareTo(a.modifiedDate!));
        });
        break;
      case 'sort_size':
        setState(() {
          _folderItems.sort((a, b) {
            final sizeA = a is TrackFolderItem ? a.size : 0;
            final sizeB = b is TrackFolderItem ? b.size : 0;
            return sizeA.compareTo(sizeB);
          });
        });
        break;
      // View options would be handled here
    }
  }

  void _showFolderOptions(FolderItem folder) {
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
                _playAllInFolder();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text('Shuffle All'),
              onTap: () {
                Navigator.pop(context);
                _shuffleAllInFolder();
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                _addToPlaylist();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteFolder();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _playAllInFolder() {
    // Implementation to play all tracks in folder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playing all tracks in folder')),
    );
  }

  void _shuffleAllInFolder() {
    // Implementation to shuffle all tracks in folder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shuffling all tracks in folder')),
    );
  }

  void _addToPlaylist() {
    // Implementation to add folder contents to playlist
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to playlist')),
    );
  }

  void _deleteFolder() {
    // Implementation to delete folder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Folder deleted')),
    );
  }
}

// Helper classes
class FolderItem {
  final String id;
  final String name;
  final FolderType type;
  final int? itemCount;
  final String? path;
  final DateTime? modifiedDate;

  FolderItem({
    required this.id,
    required this.name,
    required this.type,
    this.itemCount,
    this.path,
    this.modifiedDate,
  });
}

class TrackFolderItem extends FolderItem {
  final String artist;
  final String album;
  final int duration;
  final double size;

  TrackFolderItem({
    required String id,
    required String name,
    required this.artist,
    required this.album,
    required this.duration,
    required this.size,
    String? path,
    DateTime? modifiedDate,
  }) : super(
          id: id,
          name: name,
          type: FolderType.track,
          path: path,
          modifiedDate: modifiedDate ?? DateTime.now(),
        );
}

enum FolderType {
  folder,
  track,
}

// Custom widgets
class FolderTile extends StatelessWidget {
  final FolderItem folder;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FolderTile({
    super.key,
    required this.folder,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Folder/Track Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: folder.type == FolderType.folder
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  folder.type == FolderType.folder ? Icons.folder : Icons.music_note,
                  color: folder.type == FolderType.folder
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Folder/Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (folder.itemCount != null)
                      Text(
                        '${folder.itemCount} items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (folder.modifiedDate != null)
                      Text(
                        _formatDate(folder.modifiedDate!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (folder is TrackFolderItem)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (folder as TrackFolderItem).artist,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            (folder as TrackFolderItem).album,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
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
}

class TrackFolderTile extends StatelessWidget {
  final TrackFolderItem track;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const TrackFolderTile({
    super.key,
    required this.track,
    required this.onTap,
    this.onPlay,
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
              // Track Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.music_note,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artist,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      track.album,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatDuration(track.duration),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${track.size.toStringAsFixed(1)} MB',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Play Button
              IconButton(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()} weeks ago';
  } else {
    return '${(difference.inDays / 30).floor()} months ago';
  }
}

String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
}
