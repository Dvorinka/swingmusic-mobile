import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/audio_provider.dart';
import '../../player/providers/media_controller_provider.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/artist_model.dart';
import '../../../data/services/enhanced_api_service.dart';

class AlbumScreen extends StatefulWidget {
  final String albumHash;

  const AlbumScreen({super.key, required this.albumHash});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Album header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAlbumHeader(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.play_circle_filled),
                onPressed: () => _playAlbum(),
              ),
              IconButton(
                icon:
                    Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => _toggleFavorite(),
              ),
            ],
          ),

          // Album content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album info
                  _buildAlbumInfo(context),

                  const SizedBox(height: 32),

                  // Track list
                  _buildTrackList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(204),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Album art
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.album,
                size: 100,
                color: Colors.white.withAlpha(230),
              ),
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.surface.withAlpha(230),
                  ],
                ),
              ),
            ),
          ),

          // Album art and info
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Album cover
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(77),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.album,
                    size: 60,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: 20),

                // Album details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Album Title',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Artist Name',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withAlpha(230),
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '2024 • 12 tracks • 48 min',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withAlpha(204),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Album title and artist
        Text(
          'Album Title',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Artist Name',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),

        const SizedBox(height: 16),

        // Album metadata
        Row(
          children: [
            Chip(
              label: const Text('2024'),
              avatar: const Icon(Icons.calendar_today, size: 16),
            ),
            const SizedBox(width: 8),
            Chip(
              label: const Text('12 tracks'),
              avatar: const Icon(Icons.music_note, size: 16),
            ),
            const SizedBox(width: 8),
            Chip(
              label: const Text('48 min'),
              avatar: const Icon(Icons.access_time, size: 16),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _playAlbum(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _shufflePlay(),
              icon: const Icon(Icons.shuffle),
              style: IconButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracks',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12, // Would use actual track count from album data
          itemBuilder: (context, index) {
            return _buildTrackTile(context, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildTrackTile(BuildContext context, int trackNumber) {
    return ListTile(
      dense: true,
      leading: Text(
        '$trackNumber',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      title: Text('Track $trackNumber Title'),
      subtitle: Text('Artist Name'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => _toggleFavorite(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showTrackOptions(),
          ),
        ],
      ),
      onTap: () => _playTrack(trackNumber),
    );
  }

  void _playAlbum() async {
    try {
      // Get real album tracks from API
      final apiService = EnhancedApiService();
      final tracksData = await apiService.getAlbumTracks(widget.albumHash);

      final tracks = tracksData
          .map((trackData) =>
              TrackModel.fromJson(trackData as Map<String, dynamic>))
          .toList();

      if (mounted) {
        final audioProvider =
            Provider.of<AudioProvider>(context, listen: false);
        // Set queue source for playback logging
        final mediaController =
            Provider.of<MediaControllerProvider>(context, listen: false);
        mediaController.setQueueSource(QueueSource.album,
            identifier: widget.albumHash);

        audioProvider.setQueue(tracks);
        if (tracks.isNotEmpty) {
          await audioProvider.loadTrack(tracks.first);
          await audioProvider.play();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load album: $e')),
        );
      }
    }
  }

  void _shufflePlay() async {
    try {
      // Get real album tracks from API
      final apiService = EnhancedApiService();
      final tracksData = await apiService.getAlbumTracks(widget.albumHash);

      final tracks = tracksData
          .map((trackData) =>
              TrackModel.fromJson(trackData as Map<String, dynamic>))
          .toList();
      tracks.shuffle(); // Shuffle the tracks

      if (mounted) {
        final audioProvider =
            Provider.of<AudioProvider>(context, listen: false);
        // Set queue source for playback logging
        final mediaController =
            Provider.of<MediaControllerProvider>(context, listen: false);
        mediaController.setQueueSource(QueueSource.album,
            identifier: widget.albumHash);

        audioProvider.setQueue(tracks);
        if (tracks.isNotEmpty) {
          await audioProvider.loadTrack(tracks.first);
          await audioProvider.play();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load album: $e')),
        );
      }
    }
  }

  void _playTrack(int trackNumber) {
    final track = TrackModel(
      id: trackNumber,
      title: 'Track $trackNumber Title',
      album: 'Album Title',
      albumhash: 'album_hash_${widget.albumHash}',
      artists: [ArtistModel(name: 'Artist Name', artisthash: 'artist_hash')],
      albumartists: [
        ArtistModel(name: 'Artist Name', artisthash: 'artist_hash')
      ],
      artisthashes: ['artist_hash'],
      track: trackNumber,
      disc: 1,
      duration: 225, // 3:45 in seconds
      bitrate: 320,
      filepath: '/mock/path/track_$trackNumber.mp3',
      folder: '/mock/path',
      genres: [GenreModel(name: 'Pop', genrehash: 'pop_hash')],
      genrehashes: ['pop_hash'],
      date: 2024,
      lastModified: 1640995200, // 2022-01-01 timestamp
      trackhash: 'track_hash_$trackNumber',
      extra: {},
    );

    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.setQueue([track]);
    audioProvider.loadTrack(track);
    audioProvider.play();

    Navigator.pushNamed(context, '/player');
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showTrackOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Play'),
            onTap: () {
              Navigator.pop(context);
              // Play track logic would go here
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to Playlist'),
            onTap: () {
              Navigator.pop(context);
              // Add to playlist logic would go here
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download'),
            onTap: () {
              Navigator.pop(context);
              // Download logic would go here
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              // Share logic would go here
            },
          ),
        ],
      ),
    );
  }
}
