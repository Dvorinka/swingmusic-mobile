import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../data/services/enhanced_api_service.dart';
import '../../data/services/analytics_service.dart';
import '../../core/constants/app_spacing.dart';

class HomeScreenWidgets extends StatefulWidget {
  const HomeScreenWidgets({super.key});

  @override
  State<HomeScreenWidgets> createState() => _HomeScreenWidgetsState();
}

class _HomeScreenWidgetsState extends State<HomeScreenWidgets> {
  late final EnhancedApiService _apiService;
  late final AnalyticsService _analyticsService;
  
  Map<String, dynamic> _quickStats = {};
  List<Map<String, dynamic>> _recentTracks = [];
  List<Map<String, dynamic>> _topArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = EnhancedApiService();
    _analyticsService = AnalyticsService(_apiService);
    _loadWidgetData();
  }

  Future<void> _loadWidgetData() async {
    try {
      final statsFuture = _analyticsService.getListeningStats();
      final recentFuture = _apiService.getTracks(limit: 5);
      final artistsFuture = _analyticsService.getTopArtists(limit: 3);

      final results = await Future.wait([statsFuture, recentFuture, artistsFuture]);

      if (mounted) {
        setState(() {
          _quickStats = results[0] as Map<String, dynamic>;
          _recentTracks = (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
          _topArtists = results[2] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Widget
          _QuickStatsWidget(stats: _quickStats),
          const SizedBox(height: AppSpacing.lg),
          
          // Now Playing Widget
          _NowPlayingWidget(),
          const SizedBox(height: AppSpacing.lg),
          
          // Recent Tracks Widget
          _RecentTracksWidget(tracks: _recentTracks),
          const SizedBox(height: AppSpacing.lg),
          
          // Top Artists Widget
          _TopArtistsWidget(artists: _topArtists),
          const SizedBox(height: AppSpacing.lg),
          
          // Quick Actions Widget
          _QuickActionsWidget(),
        ],
      ),
    );
  }
}

class _QuickStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _QuickStatsWidget({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Music',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Tracks',
                    value: stats['totalTracks']?.toString() ?? '0',
                    icon: Icons.music_note,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Artists',
                    value: stats['totalArtists']?.toString() ?? '0',
                    icon: Icons.person,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Hours',
                    value: ((stats['totalPlayTime'] as int? ?? 0) / 3600).toStringAsFixed(1),
                    icon: Icons.access_time,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _NowPlayingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final currentTrack = audioProvider.currentTrack;
        
        if (currentTrack == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.music_note,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'No track playing',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navigate to player or show mini player
                    },
                    icon: const Icon(Icons.play_arrow),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now Playing',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentTrack.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.album,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentTrack.artists.map((a) => a.name).join(', '),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Text(
                                audioProvider.positionFormatted,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Expanded(
                                child: LinearProgressIndicator(
                                  value: 0.5, // This should be actual progress
                                ),
                              ),
                              Text(
                                audioProvider.durationFormatted,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: audioProvider.playPrevious,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: audioProvider.isPlaying ? audioProvider.pause : audioProvider.play,
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                    IconButton(
                      onPressed: audioProvider.playNext,
                      icon: const Icon(Icons.skip_next),
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
}

class _RecentTracksWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tracks;

  const _RecentTracksWidget({required this.tracks});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tracks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full recent tracks
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (tracks.isEmpty)
              Text(
                'No recent tracks',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Column(
                children: tracks.take(3).map((track) => _RecentTrackItem(track: track)).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentTrackItem extends StatelessWidget {
  final Map<String, dynamic> track;

  const _RecentTrackItem({required this.track});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          track['image'] ?? '',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 40,
              height: 40,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            );
          },
        ),
      ),
      title: Text(
        track['title'] ?? 'Unknown Track',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track['artist'] ?? 'Unknown Artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: () {
          // Play this track
        },
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class _TopArtistsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> artists;

  const _TopArtistsWidget({required this.artists});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Artists',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full artists list
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (artists.isEmpty)
              Text(
                'No artists data',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artists.length,
                  itemBuilder: (context, index) {
                    final artist = artists[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: _ArtistCircle(artist: artist),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArtistCircle extends StatelessWidget {
  final Map<String, dynamic> artist;

  const _ArtistCircle({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.network(
            artist['image'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            artist['name'] ?? 'Unknown',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _QuickActionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.shuffle,
                    label: 'Shuffle',
                    onTap: () {
                      // Start shuffle play
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.favorite,
                    label: 'Favorites',
                    onTap: () {
                      // Navigate to favorites
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.download,
                    label: 'Downloads',
                    onTap: () {
                      // Navigate to downloads
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
