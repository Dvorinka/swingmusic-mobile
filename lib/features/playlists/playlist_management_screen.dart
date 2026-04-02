import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../player/providers/media_controller_provider.dart';
import '../../data/models/track_model.dart';
import '../../data/models/artist_model.dart' as artist;
import '../../core/constants/app_spacing.dart';

class PlaylistManagementScreen extends StatefulWidget {
  const PlaylistManagementScreen({super.key});

  @override
  State<PlaylistManagementScreen> createState() =>
      _PlaylistManagementScreenState();
}

class _PlaylistManagementScreenState extends State<PlaylistManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Playlist> _playlists = [];
  List<TrackModel> _favoriteTracks = [];
  final TextEditingController _playlistNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'created', 'favorites'

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
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _playlistNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Playlists',
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
            onPressed: _showCreatePlaylistDialog,
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Playlists'),
            Tab(text: 'Created'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: AppSpacing.paddingMD,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search playlists...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _filterPlaylists('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _filterPlaylists,
              ),
            ),

            // Filter Chips
            Container(
              padding: AppSpacing.paddingMD,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'created', 'favorites'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                          _filterPlaylists('');
                        },
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Playlists Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlaylistsList('all'),
                  _buildPlaylistsList('created'),
                  _buildFavoritesList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlaylistDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlaylistsList(String type) {
    final playlists = type == 'favorites'
        ? _playlists.where((p) => p.isFavorite).toList()
        : _playlists.where((p) => !p.isFavorite).toList();

    if (playlists.isEmpty) {
      return _buildEmptyPlaylistsState(type);
    }

    return ListView.builder(
      padding: AppSpacing.paddingMD,
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return PlaylistTile(
          playlist: playlist,
          onTap: () => _openPlaylist(playlist),
          onEdit: () => _editPlaylist(playlist),
          onDelete: () => _deletePlaylist(playlist),
          onPlay: () => _playPlaylist(playlist),
          onToggleFavorite: () => _togglePlaylistFavorite(playlist),
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    if (_favoriteTracks.isEmpty) {
      return _buildEmptyPlaylistsState('favorites');
    }

    return ListView.builder(
      padding: AppSpacing.paddingMD,
      itemCount: _favoriteTracks.length,
      itemBuilder: (context, index) {
        final track = _favoriteTracks[index];
        return TrackListTile(
          track: track,
          onTap: () => _playTrack(track),
          onPlay: () => _playTrack(track),
          onRemoveFromFavorites: () => _removeFromFavorites(track),
        );
      },
    );
  }

  Widget _buildEmptyPlaylistsState(String type) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case 'favorites':
        title = 'No favorite tracks';
        subtitle = 'Add tracks to favorites to see them here';
        icon = Icons.favorite_border;
        break;
      case 'created':
        title = 'No created playlists';
        subtitle = 'Create playlists to organize your music';
        icon = Icons.playlist_add;
        break;
      default:
        title = 'No playlists';
        subtitle = 'Create playlists to organize your music';
        icon = Icons.playlist_play;
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: type == 'favorites'
                  ? _showAddToFavoritesDialog
                  : _showCreatePlaylistDialog,
              icon: Icon(
                type == 'favorites' ? Icons.favorite : Icons.add,
              ),
              label: Text(
                  type == 'favorites' ? 'Add Favorites' : 'Create Playlist'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TrackModel _createSampleTrack({
    required int id,
    required String title,
    required String album,
    required String artistName,
    required int duration,
    required String image,
    bool isFavorite = false,
  }) {
    return TrackModel(
      id: id,
      title: title,
      album: album,
      albumhash: 'album_$id',
      artists: [
        artist.ArtistModel(
          name: artistName,
          artisthash: 'artist_$id',
          image: image,
        )
      ],
      albumartists: [
        artist.ArtistModel(
          name: artistName,
          artisthash: 'artist_$id',
          image: image,
        )
      ],
      artisthashes: ['artist_$id'],
      track: 1,
      disc: 1,
      duration: duration,
      bitrate: 320,
      filepath: '/mock/path/track_$id.mp3',
      folder: '/mock/path',
      genres: [],
      genrehashes: [],
      date: 20230101,
      lastModified: 20230101,
      trackhash: 'track_$id',
      image: image,
      extra: {},
      isFavorite: isFavorite,
    );
  }

  void _loadData() async {
    try {
      // Simulate API calls
      await Future.delayed(const Duration(milliseconds: 1000));

      final samplePlaylists = [
        Playlist(
          id: '1',
          name: 'My Favorites',
          description: 'My favorite tracks collection',
          trackCount: 23,
          isFavorite: true,
          createdDate: DateTime.now().subtract(const Duration(days: 30)),
          coverImage: 'https://picsum.photos/seed/favorites/200',
        ),
        Playlist(
          id: '2',
          name: 'Road Trip Mix',
          description: 'Perfect for long drives',
          trackCount: 45,
          isFavorite: false,
          createdDate: DateTime.now().subtract(const Duration(days: 7)),
          coverImage: 'https://picsum.photos/seed/roadtrip/200',
        ),
        Playlist(
          id: '3',
          name: 'Workout Energy',
          description: 'High energy tracks for exercising',
          trackCount: 32,
          isFavorite: false,
          createdDate: DateTime.now().subtract(const Duration(days: 14)),
          coverImage: 'https://picsum.photos/seed/workout/200',
        ),
        Playlist(
          id: '4',
          name: 'Chill Vibes',
          description: 'Relaxing tracks for unwinding',
          trackCount: 28,
          isFavorite: false,
          createdDate: DateTime.now().subtract(const Duration(days: 21)),
          coverImage: 'https://picsum.photos/seed/chill/200',
        ),
      ];

      final sampleFavorites = [
        _createSampleTrack(
          id: 1,
          title: 'Bohemian Rhapsody',
          album: 'A Night at the Opera',
          artistName: 'Queen',
          duration: 334,
          image: 'https://picsum.photos/seed/queen/200',
          isFavorite: true,
        ),
        _createSampleTrack(
          id: 2,
          title: 'Hotel California',
          album: 'Hotel California',
          artistName: 'Eagles',
          duration: 391,
          image: 'https://picsum.photos/seed/eagles/200',
          isFavorite: true,
        ),
        _createSampleTrack(
          id: 3,
          title: 'Sweet Child O\' Mine',
          album: 'Appetite for Destruction',
          artistName: 'Guns N\' Roses',
          duration: 348,
          image: 'https://picsum.photos/seed/gnr/200',
          isFavorite: true,
        ),
      ];

      setState(() {
        _playlists = samplePlaylists;
        _favoriteTracks = sampleFavorites;
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  void _filterPlaylists(String query) {
    // Filter logic would be implemented here
    // For demo, just return all playlists
  }

  void _openPlaylist(Playlist playlist) {
    Navigator.pushNamed(
      context,
      '/playlist',
      arguments: {'playlist': playlist},
    );
  }

  void _editPlaylist(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _playlistNameController..text = playlist.name,
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updatePlaylistName(playlist);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updatePlaylistName(Playlist playlist) {
    final newName = _playlistNameController.text.trim();
    if (newName.isNotEmpty && newName != playlist.name) {
      setState(() {
        final index = _playlists.indexWhere((p) => p.id == playlist.id);
        if (index != -1) {
          _playlists[index] = playlist.copyWith(name: newName);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playlist updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deletePlaylist(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _playlists.removeWhere((p) => p.id == playlist.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Playlist deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _togglePlaylistFavorite(Playlist playlist) {
    setState(() {
      final index = _playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) {
        _playlists[index] = playlist.copyWith(isFavorite: !playlist.isFavorite);
      }
    });
  }

  void _playPlaylist(Playlist playlist) {
    // Get the tracks for this playlist (for demo, use favorite tracks)
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Set queue source for playback logging
    final mediaController =
        Provider.of<MediaControllerProvider>(context, listen: false);

    if (_favoriteTracks.isNotEmpty) {
      // Determine if this is favorites or a regular playlist
      if (playlist.isFavorite) {
        mediaController.setQueueSource(QueueSource.favorite);
      } else {
        mediaController.setQueueSource(QueueSource.playlist,
            identifier: playlist.id);
      }

      audioProvider.setQueue(_favoriteTracks);
      audioProvider.loadTrack(_favoriteTracks.first);
      audioProvider.play();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Playing ${playlist.name} (${_favoriteTracks.length} tracks)'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to player screen
      Navigator.pushNamed(context, '/player');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tracks available in this playlist'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _playTrack(TrackModel track) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Set queue source for playback logging (single track from playlist/favorites)
    final mediaController =
        Provider.of<MediaControllerProvider>(context, listen: false);
    mediaController.setQueueSource(QueueSource.unknown);

    audioProvider.setQueue([track]);
    audioProvider.loadTrack(track);
    audioProvider.play();

    Navigator.pushNamed(context, '/player');
  }

  void _removeFromFavorites(TrackModel track) {
    setState(() {
      _favoriteTracks.removeWhere((t) => t.id == track.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _playlistNameController,
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'Enter playlist name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createPlaylist();
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createPlaylist() {
    final name = _playlistNameController.text.trim();
    if (name.isNotEmpty) {
      final newPlaylist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: 'Custom playlist',
        trackCount: 0,
        isFavorite: false,
        createdDate: DateTime.now(),
        coverImage: 'https://picsum.photos/seed/custom/200',
      );

      setState(() {
        _playlists.insert(0, newPlaylist);
      });

      _playlistNameController.clear();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist "$name" created'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddToFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Favorites'),
        content: const Text(
            'Feature coming soon! Add tracks to favorites from the player screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class Playlist {
  final String id;
  final String name;
  final String description;
  final int trackCount;
  final bool isFavorite;
  final DateTime createdDate;
  final String? coverImage;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.trackCount,
    required this.isFavorite,
    required this.createdDate,
    this.coverImage,
  });

  Playlist copyWith({
    String? name,
    String? description,
    int? trackCount,
    bool? isFavorite,
    String? coverImage,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      trackCount: trackCount ?? this.trackCount,
      isFavorite: isFavorite ?? this.isFavorite,
      createdDate: createdDate,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPlay;
  final VoidCallback onToggleFavorite;

  const PlaylistTile({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onPlay,
    required this.onToggleFavorite,
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
              // Cover Image
              Container(
                width: 60,
                height: 60,
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
                  child: playlist.coverImage != null
                      ? Image.network(
                          playlist.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.8),
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.playlist_play,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 24,
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.8),
                                Theme.of(context).colorScheme.primary,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.playlist_play,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Playlist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            playlist.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            playlist.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: playlist.isFavorite
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${playlist.trackCount} tracks',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(playlist.createdDate),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
}

class TrackListTile extends StatelessWidget {
  final TrackModel track;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback onRemoveFromFavorites;

  const TrackListTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.onPlay,
    required this.onRemoveFromFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: track.image.isNotEmpty
              ? Image.network(
                  track.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.8),
                            Theme.of(context).colorScheme.primary,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24,
                      ),
                    );
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.8),
                        Theme.of(context).colorScheme.primary,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
        ),
      ),
      title: Text(
        track.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${track.artistNames} • ${track.album}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow),
            color: Theme.of(context).colorScheme.primary,
            iconSize: 20,
          ),
          IconButton(
            onPressed: onRemoveFromFavorites,
            icon: const Icon(Icons.favorite_border),
            color: Theme.of(context).colorScheme.error,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
