import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../shared/providers/library_provider.dart';
import '../../core/widgets/album_card.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../data/models/track_model.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
    late TabController _tabController;
    late LibraryProvider _libraryProvider;
    late AudioProvider _audioProvider;
    bool _isLoading = false;

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 6, vsync: this);
      _libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
      _audioProvider = Provider.of<AudioProvider>(context, listen: false);
      _loadLibraryData();
    }

    Future<void> _loadLibraryData() async {
      setState(() {
        _isLoading = true;
      });

      try {
        await Future.wait([
          _libraryProvider.loadTracks(),
          _libraryProvider.loadAlbums(),
          _libraryProvider.loadArtists(),
          _libraryProvider.loadFavorites(),
        ]);
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
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            if (_libraryProvider.tracks.isEmpty)
              _buildEmptyState('No recently played tracks')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _libraryProvider.tracks.length,
                itemBuilder: (context, index) {
                  final track = _libraryProvider.tracks[index];
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
            if (_libraryProvider.albums.isEmpty)
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
                itemCount: _libraryProvider.albums.length,
                itemBuilder: (context, index) {
                  final album = _libraryProvider.albums[index];
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
            if (_libraryProvider.tracks.isEmpty)
              _buildEmptyState('No tracks found')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _libraryProvider.tracks.length,
                itemBuilder: (context, index) {
                  final track = _libraryProvider.tracks[index];
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
            if (_libraryProvider.favoriteTracks.isEmpty)
              _buildEmptyState('No favorite tracks yet')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _libraryProvider.favoriteTracks.length,
                itemBuilder: (context, index) {
                  final track = _libraryProvider.favoriteTracks[index];
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              'Folder navigation coming soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    Widget _buildPlaylistsTab() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              'Playlist management coming soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
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
