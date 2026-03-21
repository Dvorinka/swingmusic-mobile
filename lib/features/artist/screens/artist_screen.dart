import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/artist_info_provider.dart';
import '../../player/providers/media_controller_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/audio_provider.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/artist_model.dart';

class ArtistScreen extends StatefulWidget {
  final String artistHash;
  
  const ArtistScreen({super.key, required this.artistHash});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArtistInfoProvider>().loadArtistInfo(widget.artistHash);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ArtistInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasArtist) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.errorMessage != null) {
            return Center(
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
                    'Failed to load artist',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadArtistInfo(widget.artistHash),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (!provider.hasArtist) {
            return const Center(
              child: Text('Artist not found'),
            );
          }
          
          return CustomScrollView(
            slivers: [
              // Header with artist info
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildArtistHeader(context, provider),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      provider.currentArtist!.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: provider.currentArtist!.isFavorite
                          ? Colors.red
                          : null,
                    ),
                    onPressed: () => provider.toggleFavoriteArtist(),
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artist stats
                      _buildArtistStats(context, provider),
                      
                      const SizedBox(height: 32),
                      
                      // Albums section
                      _buildSectionHeader(context, 'Albums', provider.artistAlbums.length),
                      const SizedBox(height: 16),
                      _buildAlbumsGrid(context, provider),
                      
                      const SizedBox(height: 32),
                      
                      // Popular tracks
                      _buildSectionHeader(context, 'Popular Tracks', provider.artistTracks.length),
                      const SizedBox(height: 16),
                      _buildTracksList(context, provider),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildArtistHeader(BuildContext context, ArtistInfoProvider provider) {
    final artist = provider.currentArtist!;
    
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
          // Background image
          if (artist.image.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                artist.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.primary,
                  );
                },
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
          
          // Artist info
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.artistAlbums.length} albums • ${provider.artistTracks.length} tracks',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArtistStats(BuildContext context, ArtistInfoProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Albums',
            provider.artistAlbums.length.toString(),
            Icons.album,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Tracks',
            provider.artistTracks.length.toString(),
            Icons.music_note,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Duration',
            _formatDuration(provider.artistTracks),
            Icons.access_time,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAlbumsGrid(BuildContext context, ArtistInfoProvider provider) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.artistAlbums.length,
        itemBuilder: (context, index) {
          final album = provider.artistAlbums[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        album.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.album,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        album.artistNames,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTracksList(BuildContext context, ArtistInfoProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.artistTracks.length,
      itemBuilder: (context, index) {
        final track = provider.artistTracks[index];
        return ListTile(
          leading: Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(track.title),
          subtitle: Text(track.album),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _playTrack(track),
          ),
        );
      },
    );
  }
  
  String _formatDuration(List tracks) {
    if (tracks.isEmpty) return '0m';
    
    int totalSeconds = 0;
    for (var track in tracks) {
      if (track.duration != null) {
        totalSeconds += track.duration!.inSeconds as int;
      } else {
        // Default to 3 minutes per track if duration is not available
        totalSeconds += 180;
      }
    }
    
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  void _playTrack(dynamic track) {
    final trackModel = TrackModel(
      id: track.id ?? 1,
      title: track.title ?? 'Unknown Track',
      album: track.album ?? 'Unknown Album',
      albumhash: track.albumhash ?? 'unknown_album',
      artists: track.artists ?? [ArtistModel(name: track.artist ?? 'Unknown Artist', artisthash: 'unknown_artist')],
      albumartists: track.albumartists ?? [ArtistModel(name: track.artist ?? 'Unknown Artist', artisthash: 'unknown_artist')],
      artisthashes: track.artisthashes ?? ['unknown_artist'],
      track: track.track ?? 1,
      disc: track.disc ?? 1,
      duration: track.duration?.inSeconds ?? 180, // Convert Duration to seconds or default to 3 minutes
      bitrate: track.bitrate ?? 320,
      filepath: track.filepath ?? '/unknown/path',
      folder: track.folder ?? '/unknown/folder',
      genres: track.genres ?? [GenreModel(name: 'Unknown', genrehash: 'unknown_genre')],
      genrehashes: track.genrehashes ?? ['unknown_genre'],
      date: track.date ?? 2024,
      lastModified: track.lastModified ?? 1640995200,
      trackhash: track.hash ?? 'unknown_hash',
      extra: track.extra ?? {},
    );
    
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Set queue source for playback logging
    final mediaController = Provider.of<MediaControllerProvider>(context, listen: false);
    mediaController.setQueueSource(QueueSource.artist, identifier: widget.artistHash);
    
    audioProvider.setQueue([trackModel]);
    audioProvider.loadTrack(trackModel);
    audioProvider.play();
    
    Navigator.pushNamed(context, '/player');
  }
}
