import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../app/state/library_controller.dart';
import '../../core/widgets/album_card.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../data/models/track_model.dart';
import '../../data/models/album_model.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LibraryController _libraryController;
  late AudioProvider _audioProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _libraryController = Provider.of<LibraryController>(context, listen: false);
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
    _loadLibraryData();
  }

  Future<void> _loadLibraryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load library data using canonical controller
      await _libraryController.bootstrap();
    } catch (e) {
      // Handle error silently for now
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Library',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search your library...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Recent'),
              Tab(text: 'Albums'),
              Tab(text: 'Tracks'),
              Tab(text: 'Folders'),
              Tab(text: 'Favorites'),
              Tab(text: 'Playlists'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecentTab(),
                _buildAlbumsTab(),
                _buildTracksTab(),
                _buildFoldersTab(),
                _buildFavoritesTab(),
                _buildPlaylistsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently Played',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_libraryController.recentlyPlayed.isEmpty)
            _buildEmptyState('No recently played tracks')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _libraryController.recentlyPlayed.length,
              itemBuilder: (context, index) {
                final trackData = _libraryController.recentlyPlayed[index];
                final track = TrackModel.fromJson(trackData);
                return TrackListTile(
                  track: track,
                  onTap: () => _playTrack(track),
                  onPlay: () => _playTrack(track),
                  isPlaying: _isCurrentTrack(track),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAlbumsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Albums',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_libraryController.recentlyAdded.isEmpty)
            _buildEmptyState('No albums found')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _libraryController.recentlyAdded.length,
              itemBuilder: (context, index) {
                final albumData = _libraryController.recentlyAdded[index];
                final album = AlbumModel.fromJson(albumData);
                return AlbumCard(
                  album: album,
                  onTap: () {
                    // Navigate to album details
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTracksTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Tracks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_libraryController.folderTracks.isEmpty)
            _buildEmptyState('No tracks found')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _libraryController.folderTracks.length,
              itemBuilder: (context, index) {
                final musicTrack = _libraryController.folderTracks[index];
                // Convert MusicTrack to TrackModel for compatibility
                final track = TrackModel(
                  id: index,
                  title: musicTrack.title,
                  album: musicTrack.album,
                  albumhash: musicTrack.albumhash ?? '',
                  artists: [],
                  albumartists: [],
                  artisthashes: [],
                  track: 0,
                  disc: 0,
                  duration: musicTrack.durationSeconds,
                  bitrate: musicTrack.bitrate,
                  filepath: musicTrack.filepath,
                  folder: '',
                  genres: [],
                  genrehashes: [],
                  date: 0,
                  lastModified: 0,
                  trackhash: musicTrack.trackhash,
                  image: musicTrack.imageUrl ?? '',
                  isFavorite: musicTrack.isFavorite,
                  extra: {},
                );
                return TrackListTile(
                  track: track,
                  onTap: () => _playTrack(track),
                  onPlay: () => _playTrack(track),
                  isPlaying: _isCurrentTrack(track),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorite Tracks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_libraryController.favoriteTracks.isEmpty)
            _buildEmptyState('No favorite tracks yet')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _libraryController.favoriteTracks.length,
              itemBuilder: (context, index) {
                final musicTrack = _libraryController.favoriteTracks[index];
                // Convert MusicTrack to TrackModel for compatibility
                final track = TrackModel(
                  id: index,
                  title: musicTrack.title,
                  album: musicTrack.album,
                  albumhash: musicTrack.albumhash ?? '',
                  artists: [],
                  albumartists: [],
                  artisthashes: [],
                  track: 0,
                  disc: 0,
                  duration: musicTrack.durationSeconds,
                  bitrate: musicTrack.bitrate,
                  filepath: musicTrack.filepath,
                  folder: '',
                  genres: [],
                  genrehashes: [],
                  date: 0,
                  lastModified: 0,
                  trackhash: musicTrack.trackhash,
                  image: musicTrack.imageUrl ?? '',
                  isFavorite: true,
                  extra: {},
                );
                return TrackListTile(
                  track: track,
                  onTap: () => _playTrack(track),
                  onPlay: () => _playTrack(track),
                  isPlaying: _isCurrentTrack(track),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFoldersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Folders',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_libraryController.folders.isEmpty)
            _buildEmptyState('No folders found')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _libraryController.folders.length,
              itemBuilder: (context, index) {
                final folder = _libraryController.folders[index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to folder contents
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Playlists',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_libraryController.playlists.isEmpty)
            _buildEmptyState('No playlists yet')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _libraryController.playlists.length,
              itemBuilder: (context, index) {
                final playlist = _libraryController.playlists[index];
                return ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(playlist.name),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to playlist contents
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _playTrack(TrackModel track) {
    _audioProvider.setQueue([track]);
    _audioProvider.loadTrack(track);
    _audioProvider.play();

    Navigator.pushNamed(context, '/player');
  }

  bool _isCurrentTrack(TrackModel track) {
    return _audioProvider.currentTrack?.trackhash == track.trackhash;
  }
}
