import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../app/state/library_controller.dart';
import '../player/providers/media_controller_provider.dart';
import '../../core/widgets/album_card.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../data/models/track_model.dart';
import '../../data/models/album_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LibraryController _libraryController;
  late AudioProvider _audioProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _libraryController = Provider.of<LibraryController>(context, listen: false);
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load home data using the canonical controller
      await _libraryController.loadHome();
    } catch (e) {
      // Handle error silently for now
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Text(
              'SwingMusic',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Show notifications
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'settings') {
                    Navigator.pushNamed(context, '/settings');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Quick Actions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.search,
                          label: 'Search',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Navigator.pushNamed(context, '/search');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.library_music,
                          label: 'Library',
                          color: Theme.of(context).colorScheme.secondary,
                          onTap: () {
                            Navigator.pushNamed(context, '/library');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.favorite,
                          label: 'Favorites',
                          color: Colors.red,
                          onTap: () {
                            Navigator.pushNamed(context, '/library');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.download,
                          label: 'Downloads',
                          color: Colors.green,
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
          ),

          // Recently Played Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recently Played',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/library');
                        },
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_libraryController.recentlyPlayed.isEmpty)
                    _buildEmptySection('No recently played tracks')
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _libraryController.recentlyPlayed.length
                            .clamp(0, 10),
                        itemBuilder: (context, index) {
                          final trackData =
                              _libraryController.recentlyPlayed[index];
                          final track = TrackModel.fromJson(trackData);
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            child: TrackListTile(
                              track: track,
                              onTap: () => _playTrack(track),
                              onPlay: () => _playTrack(track),
                              showAlbumArt: true,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Recent Albums Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Albums',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/library');
                        },
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_libraryController.recentlyAdded.isEmpty)
                    _buildEmptySection('No recent albums')
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount:
                          _libraryController.recentlyAdded.length.clamp(0, 4),
                      itemBuilder: (context, index) {
                        final albumData =
                            _libraryController.recentlyAdded[index];
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
            ),
          ),

          // Top Artists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Artists',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_libraryController.recommendedArtists.isEmpty)
                    _buildEmptySection('No top artists')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _libraryController.recommendedArtists.length
                          .clamp(0, 5),
                      itemBuilder: (context, index) {
                        final artist =
                            _libraryController.recommendedArtists[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              artist.name.isNotEmpty
                                  ? artist.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(artist.name),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to artist details
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Space for mini player
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _playTrack(TrackModel track) {
    // Set queue source for playback logging
    final mediaController =
        Provider.of<MediaControllerProvider>(context, listen: false);
    mediaController.setQueueSource(QueueSource.unknown);

    _audioProvider.setQueue([track]);
    _audioProvider.loadTrack(track);
    _audioProvider.play();

    Navigator.pushNamed(context, '/player');
  }
}
