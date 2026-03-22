import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/media_controller_provider.dart';
import '../providers/home_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/album_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load home data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaControllerProvider = context.watch<MediaControllerProvider>();
    final homeProvider = context.watch<HomeProvider>();
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => homeProvider.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_getGreeting()}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back to ${AppConstants.appName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                      icon: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Currently playing card
                if (mediaControllerProvider.currentTrack != null)
                  _buildCurrentlyPlayingCard(context, mediaControllerProvider),
                
                const SizedBox(height: 24),
                
                // Quick actions
                _buildQuickActions(context),
                
                const SizedBox(height: 32),
                
                // Stats card (matching Android HomeStatsCard)
                if (!homeProvider.isLoading || homeProvider.stats.totalTracks > 0)
                  _buildStatsCard(context, homeProvider),
                
                const SizedBox(height: 32),
                
                // Recently added albums (matching Android RecentlyAddedSection)
                _buildSectionHeader(context, 'Recently Added', Icons.album, onSeeAll: () {
                  Navigator.of(context).pushNamed('/albums');
                }),
                const SizedBox(height: 16),
                _buildRecentlyAddedAlbums(context, homeProvider),
                
                const SizedBox(height: 32),
                
                // Favorite albums
                _buildSectionHeader(context, 'Favorite Albums', Icons.favorite, onSeeAll: () {
                  Navigator.of(context).pushNamed('/favorites');
                }),
                const SizedBox(height: 16),
                _buildFavoriteAlbums(context),
                
                const SizedBox(height: 32),
                
                // Recommended artists
                _buildSectionHeader(context, 'Recommended Artists', Icons.person, onSeeAll: () {
                  Navigator.of(context).pushNamed('/artists');
                }),
                const SizedBox(height: 16),
                _buildRecommendedArtists(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
  
  Widget _buildCurrentlyPlayingCard(BuildContext context, MediaControllerProvider provider) {
    final currentTrack = provider.currentTrack!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/now-playing');
        },
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Album art
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Now Playing',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTrack.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTrack.artistNames,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Play/pause button
              IconButton(
                onPressed: provider.isPlaying ? provider.pause : provider.play,
                icon: Icon(
                  provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Search',
            Icons.search,
            () => Navigator.of(context).pushNamed('/search'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Library',
            Icons.folder,
            () => Navigator.of(context).pushNamed('/library'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Queue',
            Icons.queue_music,
            () => Navigator.of(context).pushNamed('/queue'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See all'),
          ),
      ],
    );
  }
  
  /// Stats card matching Android HomeStatsCard
  Widget _buildStatsCard(BuildContext context, HomeProvider homeProvider) {
    final stats = homeProvider.stats;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Library',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(context, stats.totalTracks.toString(), 'Tracks', Icons.music_note),
              const SizedBox(width: 24),
              _buildStatItem(context, stats.totalAlbums.toString(), 'Albums', Icons.album),
              const SizedBox(width: 24),
              _buildStatItem(context, stats.totalArtists.toString(), 'Artists', Icons.person),
            ],
          ),
          if (stats.totalPlaytime > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Total playtime: ${stats.formattedPlaytime}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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
  
  /// Recently added albums matching Android RecentlyAddedSection
  Widget _buildRecentlyAddedAlbums(BuildContext context, HomeProvider homeProvider) {
    if (homeProvider.isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    final albums = homeProvider.recentlyAdded;
    
    if (albums.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No recently added albums',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return _buildAlbumCard(context, album);
        },
      ),
    );
  }
  
  Widget _buildAlbumCard(BuildContext context, AlbumModel album) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/album', arguments: album.albumhash);
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: album.image.isNotEmpty
                    ? Image.network(
                        album.image,
                        width: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildAlbumPlaceholder(context),
                      )
                    : _buildAlbumPlaceholder(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAlbumPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.album,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
  
  
  Widget _buildFavoriteAlbums(BuildContext context) {
    // Sample data for favorite albums - replace with actual data from provider
    final favoriteAlbums = [
      {'title': 'A Night at the Opera', 'artist': 'Queen'},
      {'title': 'Led Zeppelin IV', 'artist': 'Led Zeppelin'},
      {'title': 'Hotel California', 'artist': 'Eagles'},
    ];
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
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
                    child: Icon(
                      Icons.album,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    favoriteAlbums[index]['title']!,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRecommendedArtists(BuildContext context) {
    // Sample data for recommended artists - replace with actual data from provider
    final recommendedArtists = ['The Beatles', 'Rolling Stones', 'Pink Floyd', 'Led Zeppelin'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(4, (index) {
        return ActionChip(
          avatar: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              size: 16,
              color: Colors.white,
            ),
          ),
          label: Text(recommendedArtists[index]),
          onPressed: () {
            Navigator.of(context).pushNamed('/artist', arguments: recommendedArtists[index]);
          },
        );
      }),
    );
  }
}
