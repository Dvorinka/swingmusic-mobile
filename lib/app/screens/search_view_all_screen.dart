import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music_models.dart';
import '../services/swing_api_client.dart';
import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import '../state/player_controller.dart';
import '../widgets/track_tile.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';

enum CatalogSearchType { tracks, albums, artists }

extension CatalogSearchTypeX on CatalogSearchType {
  String get apiValue => switch (this) {
        CatalogSearchType.tracks => 'tracks',
        CatalogSearchType.albums => 'albums',
        CatalogSearchType.artists => 'artists',
      };

  String get label => switch (this) {
        CatalogSearchType.tracks => 'Tracks',
        CatalogSearchType.albums => 'Albums',
        CatalogSearchType.artists => 'Artists',
      };
}

class SearchViewAllScreen extends StatefulWidget {
  const SearchViewAllScreen({
    super.key,
    required this.query,
    required this.type,
  });

  final String query;
  final CatalogSearchType type;

  @override
  State<SearchViewAllScreen> createState() => _SearchViewAllScreenState();
}

class _SearchViewAllScreenState extends State<SearchViewAllScreen> {
  static const int _pageSize = 25;

  final ScrollController _scrollController = ScrollController();
  List<MusicTrack> _tracks = const [];
  List<MusicAlbum> _albums = const [];
  List<MusicArtist> _artists = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    Future.microtask(() => _loadPage(reset: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 220;
    if (_scrollController.position.pixels < threshold) return;

    if (_loading || _loadingMore || !_hasMore) return;
    _loadPage();
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_loadingMore) return;
    if (!reset && !_hasMore) return;

    if (reset) {
      setState(() {
        _loading = true;
        _loadingMore = false;
        _error = null;
        _offset = 0;
        _hasMore = true;
        _tracks = const [];
        _albums = const [];
        _artists = const [];
      });
    } else {
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      final api = context.read<SwingApiClient>();
      final payload = await api.searchCatalog(
        query: widget.query,
        type: widget.type.apiValue,
        limit: _pageSize,
        offset: _offset,
      );

      final hasMore = _extractHasMore(payload);
      final pageSize = _appendPage(payload);
      if (!mounted) return;

      setState(() {
        _offset += pageSize;
        _hasMore = hasMore && pageSize > 0;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load results: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  bool _extractHasMore(Map<String, dynamic> payload) {
    final raw = payload['has_more'];
    if (raw is bool) return raw;
    if (raw is Map) {
      final value = raw[widget.type.apiValue];
      if (value is bool) return value;
    }
    return false;
  }

  int _appendPage(Map<String, dynamic> payload) {
    switch (widget.type) {
      case CatalogSearchType.tracks:
        final page = _asMapList(
          payload['tracks'],
        ).map(MusicTrack.fromCatalogJson).toList(growable: false);
        _tracks = _mergeById<MusicTrack>(_tracks, page, (track) => track.id);
        return page.length;
      case CatalogSearchType.albums:
        final page = _asMapList(
          payload['albums'],
        ).map(MusicAlbum.fromCatalogJson).toList(growable: false);
        _albums = _mergeById<MusicAlbum>(_albums, page, (album) => album.id);
        return page.length;
      case CatalogSearchType.artists:
        final page = _asMapList(
          payload['artists'],
        ).map(MusicArtist.fromCatalogJson).toList(growable: false);
        _artists = _mergeById<MusicArtist>(
          _artists,
          page,
          (artist) => artist.id,
        );
        return page.length;
    }
  }

  List<T> _mergeById<T>(
    List<T> current,
    List<T> incoming,
    String Function(T item) idOf,
  ) {
    final merged = <String, T>{};
    for (final item in current) {
      final id = idOf(item);
      if (id.isEmpty) continue;
      merged[id] = item;
    }
    for (final item in incoming) {
      final id = idOf(item);
      if (id.isEmpty) continue;
      merged[id] = item;
    }
    return merged.values.toList(growable: false);
  }

  List<Map<String, dynamic>> _asMapList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LibraryController, PlayerController, OfflineController>(
      builder: (context, library, player, offline, _) {
        return Scaffold(
          appBar: AppBar(title: Text('${widget.type.label}: ${widget.query}')),
          body: _buildBody(library, player, offline),
        );
      },
    );
  }

  Widget _buildBody(
    LibraryController library,
    PlayerController player,
    OfflineController offline,
  ) {
    final hasData = switch (widget.type) {
      CatalogSearchType.tracks => _tracks.isNotEmpty,
      CatalogSearchType.albums => _albums.isNotEmpty,
      CatalogSearchType.artists => _artists.isNotEmpty,
    };

    if (_loading && !hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && !hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _loadPage(reset: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasData) {
      return const Center(
        child: Text('No results found. Try a different search query.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPage(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _itemCount + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _itemCount) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return switch (widget.type) {
            CatalogSearchType.tracks => _buildTrackTile(
                index,
                library,
                player,
                offline,
              ),
            CatalogSearchType.albums => _buildAlbumTile(_albums[index]),
            CatalogSearchType.artists => _buildArtistTile(_artists[index]),
          };
        },
      ),
    );
  }

  int get _itemCount => switch (widget.type) {
        CatalogSearchType.tracks => _tracks.length,
        CatalogSearchType.albums => _albums.length,
        CatalogSearchType.artists => _artists.length,
      };

  Widget _buildTrackTile(
    int index,
    LibraryController library,
    PlayerController player,
    OfflineController offline,
  ) {
    final track = _tracks[index];
    return TrackTile(
      track: track,
      onPlay: () =>
          player.playTrack(track, queue: _tracks, source: 'search-view-all'),
      onFavorite: () async {
        await library.toggleFavoriteTrack(track);
        if (!mounted) return;
        setState(() {
          _tracks = List<MusicTrack>.from(_tracks);
          _tracks[index] = track.copyWith(isFavorite: !track.isFavorite);
        });
      },
      onDownload: track.filepath.isEmpty
          ? () => library.queueServerDownloadForTrack(track)
          : () => offline.downloadTrack(track, collectionLabel: 'search'),
    );
  }

  Widget _buildAlbumTile(MusicAlbum album) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: album.spotifyId == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AlbumDetailScreen(
                        albumId: album.spotifyId!,
                        albumName: album.title,
                      ),
                    ),
                  ),
          leading: _Artwork(
            imageUrl: album.imageUrl,
            fallbackIcon: Icons.album,
          ),
          title: Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _buildArtistTile(MusicArtist artist) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: artist.spotifyId == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArtistDetailScreen(
                        artistId: artist.spotifyId!,
                        artistName: artist.name,
                      ),
                    ),
                  ),
          leading: _Artwork(
            imageUrl: artist.imageUrl,
            fallbackIcon: Icons.person,
          ),
          title: Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(artist.spotifyId ?? artist.artisthash ?? ''),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.imageUrl, required this.fallbackIcon});

  final String? imageUrl;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 44,
        height: 44,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Container(
                color: scheme.surface,
                child: Icon(fallbackIcon, color: scheme.onSurfaceVariant),
              )
            : Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}
