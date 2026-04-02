import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../player/providers/media_controller_provider.dart';
import '../../core/widgets/album_card.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../data/models/track_model.dart';
import '../../data/models/album_model.dart';
import '../../data/models/artist_model.dart' as artist_model;
import '../../data/services/enhanced_api_service.dart';
import '../../core/constants/app_spacing.dart';

class ViewAllSearchScreen extends StatefulWidget {
  final String query;
  final SearchType type;
  final String title;

  const ViewAllSearchScreen({
    super.key,
    required this.query,
    required this.type,
    required this.title,
  });

  @override
  State<ViewAllSearchScreen> createState() => _ViewAllSearchScreenState();
}

class _ViewAllSearchScreenState extends State<ViewAllSearchScreen> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  late EnhancedApiService _apiService;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService = context.read<EnhancedApiService>();
      _loadResults();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _offset = 0;
      _results = [];
      _hasMore = true;
    });

    try {
      final results = await _fetchResults(0);
      setState(() {
        _results = results;
        _isLoading = false;
        _hasMore = results.length >= _limit;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load results: $e';
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newOffset = _offset + _limit;
      final results = await _fetchResults(newOffset);

      setState(() {
        _offset = newOffset;
        _results.addAll(results);
        _isLoadingMore = false;
        _hasMore = results.length >= _limit;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more: $e')),
        );
      }
    }
  }

  Future<List<dynamic>> _fetchResults(int offset) async {
    switch (widget.type) {
      case SearchType.tracks:
        return await _apiService.getTracks(
          search: widget.query,
          limit: _limit,
          offset: offset,
        );
      case SearchType.albums:
        return await _apiService.getAlbums(
          search: widget.query,
          limit: _limit,
          offset: offset,
        );
      case SearchType.artists:
        return await _apiService.getArtists(
          search: widget.query,
          limit: _limit,
          offset: offset,
        );
      default:
        return [];
    }
  }

  Future<void> _onRefresh() async {
    await _loadResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_results.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.paddingMD,
        itemCount: _results.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _results.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = _results[index];
          return _buildItem(item);
        },
      ),
    );
  }

  Widget _buildItem(dynamic item) {
    if (item is TrackModel) {
      return _buildTrackItem(item);
    } else if (item is AlbumModel) {
      return _buildAlbumItem(item);
    } else if (item is artist_model.ArtistModel) {
      return _buildArtistItem(item);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTrackItem(TrackModel track) {
    return TrackListTile(
      track: track,
      onTap: () => _playTrack(track),
      onPlay: () => _playTrack(track),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'queue':
              _addToQueue(track);
              break;
            case 'playlist':
              _showAddToPlaylistDialog(track);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'queue',
            child: ListTile(
              leading: Icon(Icons.add_to_queue),
              title: Text('Add to Queue'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'playlist',
            child: ListTile(
              leading: Icon(Icons.playlist_add),
              title: Text('Add to Playlist'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumItem(AlbumModel album) {
    return AlbumCard(
      album: album,
      onTap: () => Navigator.pushNamed(
        context,
        '/album',
        arguments: album.albumhash,
      ),
    );
  }

  Widget _buildArtistItem(artist_model.ArtistModel artist) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/artist',
          arguments: artist.artisthash,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: artist.image.isNotEmpty
                    ? Image.network(
                        artist.image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            _buildDefaultArtistIcon(),
                      )
                    : _buildDefaultArtistIcon(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${artist.trackcount} tracks • ${artist.albumcount} albums',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultArtistIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(),
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getTypeName().toLowerCase()} found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
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
              'Failed to load results',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadResults,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (widget.type) {
      case SearchType.tracks:
        return Icons.music_note;
      case SearchType.albums:
        return Icons.album;
      case SearchType.artists:
        return Icons.person;
      default:
        return Icons.search;
    }
  }

  String _getTypeName() {
    switch (widget.type) {
      case SearchType.tracks:
        return 'Tracks';
      case SearchType.albums:
        return 'Albums';
      case SearchType.artists:
        return 'Artists';
      default:
        return 'Results';
    }
  }

  void _playTrack(TrackModel track) {
    final audioProvider = context.read<AudioProvider>();
    // Set queue source for playback logging
    final mediaController = context.read<MediaControllerProvider>();
    mediaController.setQueueSource(QueueSource.search);

    audioProvider.setQueue([track]);
    audioProvider.loadTrack(track);
    audioProvider.play();
    Navigator.pushNamed(context, '/player');
  }

  void _addToQueue(TrackModel track) {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.addToQueue(track);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "${track.title}" to queue')),
    );
  }

  void _showAddToPlaylistDialog(TrackModel track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Playlist'),
        content: const Text('Playlist selection coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

enum SearchType {
  tracks,
  albums,
  artists,
  all,
}
