import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

class PodcastSupportScreen extends StatefulWidget {
  const PodcastSupportScreen({super.key});

  @override
  State<PodcastSupportScreen> createState() => _PodcastSupportScreenState();
}

class _PodcastSupportScreenState extends State<PodcastSupportScreen> {
  List<Map<String, dynamic>> _podcasts = [];
  List<Map<String, dynamic>> _episodes = [];
  List<Map<String, dynamic>> _subscriptions = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPodcastData();
  }

  Future<void> _loadPodcastData() async {
    try {
      // In a real implementation, these would be actual API calls
      final podcastsFuture = _getPodcasts();
      final episodesFuture = _getEpisodes();
      final subscriptionsFuture = _getSubscriptions();

      final results = await Future.wait([podcastsFuture, episodesFuture, subscriptionsFuture]);

      if (mounted) {
        setState(() {
          _podcasts = results[0];
          _episodes = results[1];
          _subscriptions = results[2];
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

  Future<List<Map<String, dynamic>>> _getPodcasts() async {
    // Mock podcast data
    return [
      {
        'id': '1',
        'title': 'Tech Talks Daily',
        'description': 'Latest in technology and innovation',
        'author': 'Tech Network',
        'image': 'https://via.placeholder.com/300x300',
        'category': 'technology',
        'episodeCount': 245,
        'subscribers': 12500,
        'rating': 4.8,
        'lastUpdated': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '2',
        'title': 'Music History Podcast',
        'description': 'Exploring the stories behind your favorite songs',
        'author': 'Music Scholars',
        'image': 'https://via.placeholder.com/300x300',
        'category': 'music',
        'episodeCount': 89,
        'subscribers': 8300,
        'rating': 4.9,
        'lastUpdated': DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        'id': '3',
        'title': 'True Crime Stories',
        'description': 'Investigative journalism and true crime',
        'author': 'Crime Network',
        'image': 'https://via.placeholder.com/300x300',
        'category': 'true crime',
        'episodeCount': 156,
        'subscribers': 23400,
        'rating': 4.7,
        'lastUpdated': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _getEpisodes() async {
    // Mock episode data
    return [
      {
        'id': 'ep1',
        'title': 'The Future of AI in Music',
        'description': 'How artificial intelligence is changing the music industry',
        'podcastId': '1',
        'podcastTitle': 'Tech Talks Daily',
        'duration': 2845, // seconds
        'publishDate': DateTime.now().subtract(const Duration(days: 1)),
        'imageUrl': 'https://via.placeholder.com/300x300',
        'audioUrl': 'https://example.com/audio1.mp3',
        'playCount': 15420,
        'isDownloaded': false,
        'isPlayed': false,
      },
      {
        'id': 'ep2',
        'title': 'The Beatles: Revolution Stories',
        'description': 'Behind the scenes of the White Album',
        'podcastId': '2',
        'podcastTitle': 'Music History Podcast',
        'duration': 3420,
        'publishDate': DateTime.now().subtract(const Duration(hours: 6)),
        'imageUrl': 'https://via.placeholder.com/300x300',
        'audioUrl': 'https://example.com/audio2.mp3',
        'playCount': 8930,
        'isDownloaded': true,
        'isPlayed': true,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _getSubscriptions() async {
    // Mock subscription data
    return [
      {
        'podcastId': '1',
        'subscribedDate': DateTime.now().subtract(const Duration(days: 30)),
        'autoDownload': true,
        'newEpisodesCount': 3,
      },
      {
        'podcastId': '2',
        'subscribedDate': DateTime.now().subtract(const Duration(days: 15)),
        'autoDownload': false,
        'newEpisodesCount': 1,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Podcasts'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Discover'),
              Tab(text: 'Episodes'),
              Tab(text: 'Subscriptions'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _showSearchDialog,
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildDiscoverTab(),
                  _buildEpisodesTab(),
                  _buildSubscriptionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: _buildPodcastGrid(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['all', 'technology', 'music', 'true crime', 'comedy', 'news', 'education'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodcastGrid() {
    final filteredPodcasts = _selectedCategory == 'all'
        ? _podcasts
        : _podcasts.where((p) => p['category'] == _selectedCategory).toList();

    if (_searchQuery.isNotEmpty) {
      filteredPodcasts.retainWhere((podcast) =>
          podcast['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          podcast['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }

    if (filteredPodcasts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.podcasts,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No podcasts found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Try adjusting your filters or search',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: filteredPodcasts.length,
      itemBuilder: (context, index) {
        return _PodcastCard(
          podcast: filteredPodcasts[index],
          onTap: () => _showPodcastDetails(filteredPodcasts[index]),
        );
      },
    );
  }

  Widget _buildEpisodesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _episodes.length,
      itemBuilder: (context, index) {
        return _EpisodeTile(
          episode: _episodes[index],
          onTap: () => _playEpisode(_episodes[index]),
        );
      },
    );
  }

  Widget _buildSubscriptionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];
        final podcast = _podcasts.firstWhere((p) => p['id'] == subscription['podcastId']);
        
        return _SubscriptionTile(
          podcast: podcast,
          subscription: subscription,
          onTap: () => _showPodcastDetails(podcast),
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Podcasts'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search podcasts...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPodcastDetails(Map<String, dynamic> podcast) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PodcastDetailsScreen(podcast: podcast),
      ),
    );
  }

  void _playEpisode(Map<String, dynamic> episode) {
    // Navigate to player or play directly
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing: ${episode['title']}')),
    );
  }
}

class _PodcastCard extends StatelessWidget {
  final Map<String, dynamic> podcast;
  final VoidCallback onTap;

  const _PodcastCard({
    required this.podcast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(podcast['image'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    Icons.podcasts,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 48,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast['title'] ?? 'Unknown Podcast',
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      podcast['author'] ?? 'Unknown Author',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.headphones,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${podcast['episodeCount'] ?? 0}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.people,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatSubscribers(podcast['subscribers'] ?? 0),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSubscribers(int subscribers) {
    if (subscribers >= 1000) {
      return '${(subscribers / 1000).toStringAsFixed(1)}K';
    }
    return subscribers.toString();
  }
}

class _EpisodeTile extends StatelessWidget {
  final Map<String, dynamic> episode;
  final VoidCallback onTap;

  const _EpisodeTile({
    required this.episode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: episode['duration'] ?? 0);
    final durationText = '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          episode['imageUrl'] ?? '',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.podcasts,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
      title: Text(episode['title'] ?? 'Unknown Episode'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(episode['podcastTitle'] ?? 'Unknown Podcast'),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                durationText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.play_arrow,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${episode['playCount'] ?? 0}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.play_circle),
      ),
      onTap: onTap,
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  final Map<String, dynamic> podcast;
  final Map<String, dynamic> subscription;
  final VoidCallback onTap;

  const _SubscriptionTile({
    required this.podcast,
    required this.subscription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipOval(
        child: Image.network(
          podcast['image'] ?? '',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.podcasts,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
      title: Text(podcast['title'] ?? 'Unknown Podcast'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscribed ${_getRelativeTime(subscription['subscribedDate'])}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (subscription['newEpisodesCount'] > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${subscription['newEpisodesCount']} new episodes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Switch(
        value: subscription['autoDownload'] ?? false,
        onChanged: (value) {
          // Update auto-download setting
        },
      ),
      onTap: onTap,
    );
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Recently';
    }
  }
}

class PodcastDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> podcast;

  const PodcastDetailsScreen({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                podcast['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.podcasts,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcast['title'] ?? 'Unknown Podcast',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    podcast['author'] ?? 'Unknown Author',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    podcast['description'] ?? 'No description available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Subscribe to podcast
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Subscribe'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Share podcast
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Recent Episodes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Episode list would go here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
