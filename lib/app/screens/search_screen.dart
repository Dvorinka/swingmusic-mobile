import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music_models.dart';
import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import '../state/player_controller.dart';
import '../widgets/track_tile.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';
import 'search_view_all_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  static const int _tracksPreviewCount = 20;
  static const int _artistsPreviewCount = 10;
  static const int _albumsPreviewCount = 10;
  static const int _playlistsPreviewCount = 10;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      context.read<LibraryController>().search(value);
    });
  }

  void _openViewAll(CatalogSearchType type) {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchViewAllScreen(query: query, type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LibraryController, PlayerController, OfflineController>(
      builder: (context, library, player, offline, _) {
        final scheme = Theme.of(context).colorScheme;
        final hasQuery = _controller.text.trim().isNotEmpty;
        final topTrack =
            library.searchTracks.isNotEmpty ? library.searchTracks.first : null;
        final remainingTracks = library.searchTracks
            .skip(topTrack == null ? 0 : 1)
            .take(_tracksPreviewCount)
            .toList(growable: false);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for songs, artists, albums...',
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _controller.clear();
                                library.search('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (library.searching) const LinearProgressIndicator(),
            if (library.error != null) ...[
              const SizedBox(height: 8),
              Text(library.error!, style: TextStyle(color: scheme.error)),
            ],
            if (!hasQuery)
              _InfoCard(
                message:
                    'Start typing to search for tracks, artists, albums, and playlists.',
              )
            else if (library.searchTracks.isEmpty &&
                library.searchArtists.isEmpty &&
                library.searchAlbums.isEmpty &&
                library.searchPlaylists.isEmpty)
              const _InfoCard(message: 'No results. Try a different query.')
            else ...[
              if (topTrack != null) ...[
                _SectionTitle(title: 'Top Result'),
                const SizedBox(height: 8),
                _TopResultCard(
                  track: topTrack,
                  onPlay: () => player.playTrack(
                    topTrack,
                    queue: library.searchTracks,
                    source: 'search',
                  ),
                  onFavorite: () => library.toggleFavoriteTrack(topTrack),
                  onDownload: topTrack.filepath.isEmpty
                      ? () => library.queueServerDownloadForTrack(topTrack)
                      : () => offline.downloadTrack(
                            topTrack,
                            collectionLabel: 'search',
                          ),
                ),
                const SizedBox(height: 14),
              ],
              _SectionHeader(
                title: 'Tracks (${library.searchTracks.length})',
                viewAllEnabled: library.searchTracks.isNotEmpty,
                onViewAll: () => _openViewAll(CatalogSearchType.tracks),
              ),
              const SizedBox(height: 8),
              ...remainingTracks.map(
                (track) => TrackTile(
                  track: track,
                  onPlay: () => player.playTrack(
                    track,
                    queue: library.searchTracks,
                    source: 'search',
                  ),
                  onFavorite: () => library.toggleFavoriteTrack(track),
                  onDownload: track.filepath.isEmpty
                      ? () => library.queueServerDownloadForTrack(track)
                      : () => offline.downloadTrack(
                            track,
                            collectionLabel: 'search',
                          ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionHeader(
                title: 'Artists (${library.searchArtists.length})',
                viewAllEnabled: library.searchArtists.isNotEmpty,
                onViewAll: () => _openViewAll(CatalogSearchType.artists),
              ),
              const SizedBox(height: 8),
              ...library.searchArtists.take(_artistsPreviewCount).map(
                    (artist) => _EntityRow(
                      imageUrl: artist.imageUrl,
                      fallbackIcon: Icons.person,
                      title: artist.name,
                      subtitle: artist.spotifyId ?? artist.artisthash ?? '',
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
                    ),
                  ),
              const SizedBox(height: 12),
              _SectionHeader(
                title: 'Albums (${library.searchAlbums.length})',
                viewAllEnabled: library.searchAlbums.isNotEmpty,
                onViewAll: () => _openViewAll(CatalogSearchType.albums),
              ),
              const SizedBox(height: 8),
              ...library.searchAlbums.take(_albumsPreviewCount).map(
                    (album) => _EntityRow(
                      imageUrl: album.imageUrl,
                      fallbackIcon: Icons.album,
                      title: album.title,
                      subtitle: album.artist,
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
                    ),
                  ),
              const SizedBox(height: 12),
              _SectionTitle(
                title: 'Playlists (${library.searchPlaylists.length})',
              ),
              const SizedBox(height: 8),
              ...library.searchPlaylists.take(_playlistsPreviewCount).map(
                    (playlist) => _EntityRow(
                      imageUrl: playlist.imageUrl,
                      fallbackIcon: Icons.playlist_play,
                      title: playlist.name,
                      subtitle: '${playlist.trackCount} tracks',
                    ),
                  ),
            ],
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _TopResultCard extends StatelessWidget {
  const _TopResultCard({
    required this.track,
    required this.onPlay,
    required this.onFavorite,
    required this.onDownload,
  });

  final MusicTrack track;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPlay,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 74,
                    height: 74,
                    child: track.imageUrl == null || track.imageUrl!.isEmpty
                        ? Container(
                            color: scheme.surface,
                            child: Icon(
                              Icons.music_note,
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        : Image.network(track.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: onPlay,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Favorite',
                            onPressed: onFavorite,
                            icon: Icon(
                              track.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: track.isFavorite ? Colors.red : null,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Download',
                            onPressed: onDownload,
                            icon: const Icon(
                              Icons.download_for_offline_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntityRow extends StatelessWidget {
  const _EntityRow({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: onTap,
          leading: ClipRRect(
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
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.viewAllEnabled,
    required this.onViewAll,
  });

  final String title;
  final bool viewAllEnabled;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(
          onPressed: viewAllEnabled ? onViewAll : null,
          child: Text(
            'View all',
            style: TextStyle(
              color: viewAllEnabled ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
