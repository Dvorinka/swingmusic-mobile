import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../../player/providers/media_controller_provider.dart';
import '../../../shared/providers/audio_provider.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/artist_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  SearchType _selectedType = SearchType.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      // Debounce search
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _searchController.text == query) {
          context.read<SearchProvider>().search(
                _searchController.text,
                type: _selectedType,
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProviderState = context.watch<SearchProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search tracks, albums, artists...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchProvider>().clearSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search type filters
                  _buildSearchTypeFilters(),
                ],
              ),
            ),

            // Search results
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
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
                            'Search failed',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.errorMessage!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.clearError(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!provider.hasQuery) {
                    return _buildSearchSuggestions(context);
                  }

                  if (!provider.hasResults) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords or filters',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildSearchResults(context, searchProviderState);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeFilters() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SearchType.values.map((type) {
              final isSelected = provider.searchType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getSearchTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                      provider.setSearchType(type);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getSearchTypeLabel(SearchType type) {
    switch (type) {
      case SearchType.all:
        return 'All';
      case SearchType.tracks:
        return 'Tracks';
      case SearchType.albums:
        return 'Albums';
      case SearchType.artists:
        return 'Artists';
    }
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Suggestions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Rock',
              'Pop',
              'Jazz',
              'Classical',
              'Electronic',
              'Hip Hop',
              '2023',
              '2024',
              'Best of',
              'Greatest Hits',
              'Live',
              'Acoustic'
            ].map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  _searchController.text = suggestion;
                  context
                      .read<SearchProvider>()
                      .search(suggestion, type: _selectedType);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(BuildContext context, TrackModel track) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          track.image,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            );
          },
        ),
      ),
      title: Text(track.title),
      subtitle: Text(track.artistNames),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () {
          _playTrack(track);
        },
      ),
    );
  }

  void _playTrack(TrackModel track) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Set queue source for playback logging
    final mediaController =
        Provider.of<MediaControllerProvider>(context, listen: false);
    mediaController.setQueueSource(QueueSource.search);

    audioProvider.setQueue([track]);
    audioProvider.loadTrack(track);
    audioProvider.play();

    Navigator.pushNamed(context, '/player');
  }

  Widget _buildAlbumTile(BuildContext context, AlbumModel album) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          album.image,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.album,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            );
          },
        ),
      ),
      title: Text(album.title),
      subtitle: Text(album.artistNames),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildArtistTile(BuildContext context, ArtistModel artist) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(artist.image),
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(artist.name),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          provider.errorMessage ?? 'An error occurred',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    if (!provider.hasResults) {
      return Center(
        child: Text(
          'No results found',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.trackResults.isNotEmpty) ...[
            Text(
              'Tracks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...provider.trackResults
                .map((track) => _buildTrackTile(context, track)),
            const SizedBox(height: 16),
          ],
          if (provider.albumResults.isNotEmpty) ...[
            Text(
              'Albums',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...provider.albumResults
                .map((album) => _buildAlbumTile(context, album)),
            const SizedBox(height: 16),
          ],
          if (provider.artistResults.isNotEmpty) ...[
            Text(
              'Artists',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...provider.artistResults
                .map((artist) => _buildArtistTile(context, artist)),
          ],
        ],
      ),
    );
  }
}
