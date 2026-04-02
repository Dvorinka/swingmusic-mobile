import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import '../state/player_controller.dart';
import '../widgets/track_tile.dart';
import 'album_detail_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  const ArtistDetailScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  final String artistId;
  final String artistName;

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<LibraryController>().loadCatalogArtist(widget.artistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LibraryController, PlayerController, OfflineController>(
      builder: (context, library, player, offline, _) {
        final payload = library.catalogArtist;
        final topTracks = library.catalogArtistTopTracks;
        final albums = library.catalogArtistAlbums;
        final radio = library.catalogArtistRadio;
        final thisIs = library.catalogArtistThisIs;
        final imageUrl = payload['image_url']?.toString();
        final offlineCandidates = [...topTracks, ...thisIs, ...radio];

        return Scaffold(
          appBar: AppBar(
            title: Text(payload['name']?.toString() ?? widget.artistName),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (payload.isEmpty) const LinearProgressIndicator(),
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                payload['name']?.toString() ?? widget.artistName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (payload['genres'] is List &&
                  (payload['genres'] as List).isNotEmpty)
                Text((payload['genres'] as List).join(' · ')),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: offlineCandidates.isEmpty
                        ? null
                        : () async {
                            await offline.downloadTracksBatch(
                              label: 'artist ${widget.artistName}',
                              tracks: offlineCandidates,
                            );
                            await library.queueServerDownloadsForTracks(
                              offlineCandidates,
                            );
                          },
                    icon: const Icon(Icons.download_for_offline_outlined),
                    label: const Text('Download Artist Offline'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Top Tracks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...topTracks.map(
                (track) => TrackTile(
                  track: track,
                  onPlay: () => player.playTrack(
                    track,
                    queue: topTracks,
                    source: 'artist:${widget.artistId}',
                  ),
                  onFavorite: () => library.toggleFavoriteTrack(track),
                  onDownload: track.filepath.isEmpty
                      ? () => library.queueServerDownloadForTrack(track)
                      : () => offline.downloadTrack(
                            track,
                            collectionLabel: 'artist ${widget.artistName}',
                          ),
                ),
              ),
              if (albums.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Discography',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...albums.map(
                  (album) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          album.imageUrl == null || album.imageUrl!.isEmpty
                              ? null
                              : NetworkImage(album.imageUrl!),
                      child: album.imageUrl == null || album.imageUrl!.isEmpty
                          ? const Icon(Icons.album)
                          : null,
                    ),
                    title: Text(album.title),
                    subtitle: Text(album.artist),
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
              ],
              if (thisIs.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text('This Is', style: Theme.of(context).textTheme.titleMedium),
                ...thisIs.take(20).map(
                      (track) => TrackTile(
                        track: track,
                        onPlay: () => player.playTrack(
                          track,
                          queue: thisIs,
                          source: 'this-is:${widget.artistId}',
                        ),
                        onFavorite: () => library.toggleFavoriteTrack(track),
                        onDownload: track.filepath.isEmpty
                            ? () => library.queueServerDownloadForTrack(track)
                            : () => offline.downloadTrack(
                                  track,
                                  collectionLabel:
                                      'artist ${widget.artistName}',
                                ),
                      ),
                    ),
              ],
              if (radio.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Artist Radio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...radio.take(20).map(
                      (track) => TrackTile(
                        track: track,
                        onPlay: () => player.playTrack(
                          track,
                          queue: radio,
                          source: 'radio:${widget.artistId}',
                        ),
                        onFavorite: () => library.toggleFavoriteTrack(track),
                        onDownload: track.filepath.isEmpty
                            ? () => library.queueServerDownloadForTrack(track)
                            : () => offline.downloadTrack(
                                  track,
                                  collectionLabel:
                                      'artist ${widget.artistName}',
                                ),
                      ),
                    ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
