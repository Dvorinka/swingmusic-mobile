import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import '../state/player_controller.dart';
import '../widgets/track_tile.dart';

class AlbumDetailScreen extends StatefulWidget {
  const AlbumDetailScreen({
    super.key,
    required this.albumId,
    required this.albumName,
  });

  final String albumId;
  final String albumName;

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<LibraryController>().loadCatalogAlbum(widget.albumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LibraryController, PlayerController, OfflineController>(
      builder: (context, library, player, offline, _) {
        final album = library.catalogAlbum;
        final tracks = library.catalogAlbumTracks;
        final title = album['title']?.toString() ?? widget.albumName;
        final artist = album['artist']?.toString() ?? '';
        final image = album['image_url']?.toString();

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (album.isEmpty) const LinearProgressIndicator(),
              if (image != null && image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(image, height: 220, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (artist.isNotEmpty) Text(artist),
              const SizedBox(height: 14),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: tracks.isEmpty
                        ? null
                        : () async {
                            await offline.downloadTracksBatch(
                              label: 'album $title',
                              tracks: tracks,
                            );
                            await library.queueServerDownloadsForTracks(tracks);
                          },
                    icon: const Icon(Icons.download_for_offline_outlined),
                    label: const Text('Download Album Offline'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Tracks', style: Theme.of(context).textTheme.titleMedium),
              ...tracks.map(
                (track) => TrackTile(
                  track: track,
                  onPlay: () => player.playTrack(
                    track,
                    queue: tracks,
                    source: 'album:${widget.albumId}',
                  ),
                  onFavorite: () => library.toggleFavoriteTrack(track),
                  onDownload: track.filepath.isEmpty
                      ? () => library.queueServerDownloadForTrack(track)
                      : () => offline.downloadTrack(
                            track,
                            collectionLabel: 'album $title',
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
