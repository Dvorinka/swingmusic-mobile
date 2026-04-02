import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../core/widgets/album_card.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../data/models/track_model.dart';
import '../../data/models/album_model.dart';
import '../../data/models/artist_model.dart' as artist_model;
import '../../data/models/search_suggestion_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Search results
  final List<TrackModel> _trackResults = [];
  final List<AlbumModel> _albumResults = [];
  final List<artist_model.ArtistModel> _artistResults = [];
  List<SearchSuggestion> _searchSuggestions = [];

  bool _isSearching = false;
  String _currentQuery = '';
  bool _showSuggestions = false;

  // Search filters
  String _selectedFilter = 'all'; // 'all', 'tracks', 'albums', 'artists'
  final List<String> _searchFilters = ['all', 'tracks', 'albums', 'artists'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search tracks, albums, artists...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,
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
                ),

                const SizedBox(height: 12),

                // Search Suggestions Dropdown
                if (_searchSuggestions.isNotEmpty && _showSuggestions)
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _searchSuggestions.take(5).map((suggestion) {
                        return ListTile(
                          leading: suggestion.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    suggestion.imageUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        child: Icon(
                                          Icons.music_note,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Text(
                                    suggestion.text[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          title: Text(suggestion.title),
                          subtitle: Text(suggestion.type),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            _searchController.text = suggestion.title;
                            _performSearch(suggestion.title);
                            _hideSuggestions();
                          },
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _searchFilters.map((filter) {
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
                            _performSearch(_currentQuery);
                          },
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _currentQuery.isEmpty
                    ? _buildSearchSuggestions()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Top'),
              Tab(text: 'Tracks'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTopSearches(),
                _buildRecentSearches(),
                _buildBrowseGenres(),
                _buildBrowseFolders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearches() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Searches',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Sample top searches
          ...['Rock', 'Pop', 'Jazz', 'Electronic', 'Classical'].map((genre) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(genre),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _searchController.text = genre;
                  _performSearch(genre);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Sample recent searches
          ...['Beatles', 'Queen', 'Pink Floyd', 'Led Zeppelin'].map((search) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(search),
                trailing: IconButton(
                  onPressed: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBrowseGenres() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: [
          'Rock',
          'Pop',
          'Jazz',
          'Electronic',
          'Classical',
          'Hip Hop',
          'Country',
          'R&B'
        ].length,
        itemBuilder: (context, index) {
          final genre = [
            'Rock',
            'Pop',
            'Jazz',
            'Electronic',
            'Classical',
            'Hip Hop',
            'Country',
            'R&B'
          ][index];
          return Card(
            child: InkWell(
              onTap: () {
                _searchController.text = genre;
                _performSearch(genre);
              },
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  genre,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrowseFolders() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Folder browsing coming soon',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_selectedFilter == 'all') {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'Tracks'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTrackResults(),
                  _buildAlbumResults(),
                  _buildArtistResults(),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (_selectedFilter == 'tracks') {
      return _buildTrackResults();
    } else if (_selectedFilter == 'albums') {
      return _buildAlbumResults();
    } else {
      return _buildArtistResults();
    }
  }

  Widget _buildTrackResults() {
    if (_trackResults.isEmpty) {
      return _buildEmptyResults('No tracks found');
    }

    return ListView.builder(
      itemCount: _trackResults.length,
      itemBuilder: (context, index) {
        final track = _trackResults[index];
        return TrackListTile(
          track: track,
          onTap: () => _playTrack(track),
          onPlay: () => _playTrack(track),
        );
      },
    );
  }

  Widget _buildAlbumResults() {
    if (_albumResults.isEmpty) {
      return _buildEmptyResults('No albums found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _albumResults.length,
      itemBuilder: (context, index) {
        final album = _albumResults[index];
        return AlbumCard(
          album: album,
          onTap: () {
            // Navigate to album details
          },
        );
      },
    );
  }

  Widget _buildArtistResults() {
    if (_artistResults.isEmpty) {
      return _buildEmptyResults('No artists found');
    }

    return ListView.builder(
      itemCount: _artistResults.length,
      itemBuilder: (context, index) {
        final artist = _artistResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
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
    );
  }

  Widget _buildEmptyResults(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or browse categories',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    _currentQuery = query;
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _showSuggestions = false;
        _searchSuggestions.clear();
        _trackResults.clear();
        _albumResults.clear();
        _artistResults.clear();
      });
    } else {
      // Show suggestions after 2 characters of typing
      if (query.length >= 2) {
        _fetchSearchSuggestions(query);
      }
      setState(() {
        _showSuggestions = true;
      });
    }
  }

  void _onSearchSubmitted(String query) {
    _performSearch(query);
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
      _isSearching = false;
      _showSuggestions = false;
      _searchSuggestions.clear();
      _trackResults.clear();
      _albumResults.clear();
      _artistResults.clear();
    });
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    try {
      // Simulate API call for search suggestions
      await Future.delayed(const Duration(milliseconds: 300));

      final suggestions = <SearchSuggestion>[
        SearchSuggestion(
          id: '1',
          title: '$query - Track 1',
          type: 'track',
          imageUrl: 'https://picsum.photos/seed/music1/200',
        ),
        SearchSuggestion(
          id: '2',
          title: '$query - Album 1',
          type: 'album',
          imageUrl: 'https://picsum.photos/seed/album1/200',
        ),
        SearchSuggestion(
          id: '3',
          title: '$query - Artist 1',
          type: 'artist',
          imageUrl: 'https://picsum.photos/seed/artist1/200',
        ),
      ];

      setState(() {
        _searchSuggestions = suggestions;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // This would be actual API calls
      setState(() {
        _isSearching = false;
        // For demo, just clear results
        _trackResults.clear();
        _albumResults.clear();
        _artistResults.clear();
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      // Handle error
    }
  }

  void _playTrack(TrackModel track) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.setQueue([track]);
    audioProvider.loadTrack(track);
    audioProvider.play();

    Navigator.pushNamed(context, '/player');
  }
}
