import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import '../state/player_controller.dart';
import '../widgets/track_tile.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: scheme.surfaceContainerHighest,
            child: const TabBar(
              tabs: [
                Tab(text: 'Folders'),
                Tab(text: 'Playlists'),
                Tab(text: 'Favorites'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_FolderTab(), _PlaylistsTab(), _FavoritesTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<LibraryController, PlayerController, OfflineController>(
      builder: (context, library, player, offline, _) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Path: ${library.currentFolder}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => library.loadFolder(library.currentFolder),
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Download folder offline',
                  onPressed: library.folderTracks.isEmpty
                      ? null
                      : () async {
                          await offline.downloadTracksBatch(
                            label: 'folder',
                            tracks: library.folderTracks,
                          );
                          await library.queueServerDownloadsForTracks(
                            library.folderTracks,
                          );
                        },
                  icon: const Icon(Icons.download_for_offline_outlined),
                ),
              ],
            ),
            if (library.loadingLibrary) const LinearProgressIndicator(),
            if (library.currentFolder != r'$home')
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text('..'),
                onTap: () {
                  final parent = _parentPath(library.currentFolder);
                  library.loadFolder(parent);
                },
              ),
            ...library.folders.map(
              (folder) => ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                subtitle: Text('${folder.trackCount} tracks'),
                onTap: () => library.loadFolder(folder.path),
              ),
            ),
            const Divider(height: 20),
            ...library.folderTracks.map(
              (track) => TrackTile(
                track: track,
                onPlay: () => player.playTrack(
                  track,
                  queue: library.folderTracks,
                  source: 'folder:${library.currentFolder}',
                ),
                onFavorite: () => library.toggleFavoriteTrack(track),
                onDownload: track.filepath.isEmpty
                    ? () => library.queueServerDownloadForTrack(track)
                    : () => offline.downloadTrack(
                        track,
                        collectionLabel: 'folder ${library.currentFolder}',
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _parentPath(String path) {
    if (path == r'$home') return r'$home';
    if (!path.contains('/')) return r'$home';
    final parts = path.split('/')..removeLast();
    final joined = parts.join('/');
    return joined.isEmpty ? r'$home' : joined;
  }
}

class _PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<LibraryController, PlayerController, OfflineController>(
      builder: (context, library, player, offline, _) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                const Expanded(child: Text('Your Playlists')),
                IconButton(
                  onPressed: () async {
                    final name = await _askPlaylistName(context);
                    if (name != null) {
                      await library.createPlaylist(name);
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            ...library.playlists.map(
              (playlist) => ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      playlist.imageUrl == null || playlist.imageUrl!.isEmpty
                      ? null
                      : NetworkImage(playlist.imageUrl!),
                  child: playlist.imageUrl == null || playlist.imageUrl!.isEmpty
                      ? const Icon(Icons.playlist_play)
                      : null,
                ),
                title: Text(playlist.name),
                subtitle: Text('${playlist.trackCount} tracks'),
                onTap: () async {
                  await library.loadPlaylistTracks(playlist.id);
                  if (!context.mounted) return;
                  final tracks = library.tracksForPlaylist(playlist.id);
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => DraggableScrollableSheet(
                      expand: false,
                      builder: (context, controller) {
                        return ListView(
                          controller: controller,
                          children: [
                            ListTile(
                              title: Text(playlist.name),
                              subtitle: Text('${tracks.length} tracks'),
                              trailing: IconButton(
                                tooltip: 'Download playlist offline',
                                onPressed: tracks.isEmpty
                                    ? null
                                    : () async {
                                        await offline.downloadTracksBatch(
                                          label: 'playlist ${playlist.name}',
                                          tracks: tracks,
                                        );
                                        await library
                                            .queueServerDownloadsForTracks(
                                              tracks,
                                            );
                                      },
                                icon: const Icon(
                                  Icons.download_for_offline_outlined,
                                ),
                              ),
                            ),
                            ...tracks.map(
                              (track) => TrackTile(
                                track: track,
                                onPlay: () => player.playTrack(
                                  track,
                                  queue: tracks,
                                  source: 'playlist:${playlist.id}',
                                ),
                                onFavorite: () =>
                                    library.toggleFavoriteTrack(track),
                                onDownload: track.filepath.isEmpty
                                    ? () => library.queueServerDownloadForTrack(
                                        track,
                                      )
                                    : () => offline.downloadTrack(
                                        track,
                                        collectionLabel:
                                            'playlist ${playlist.name}',
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _askPlaylistName(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Playlist name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return value == null || value.trim().isEmpty ? null : value.trim();
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<LibraryController, PlayerController, OfflineController>(
      builder: (context, library, player, offline, _) {
        final tracks = library.favoriteTracks;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                Text('Favorite Tracks (${tracks.length})'),
                const Spacer(),
                IconButton(
                  onPressed: library.loadFavorites,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Download favorites offline',
                  onPressed: tracks.isEmpty
                      ? null
                      : () async {
                          await offline.downloadTracksBatch(
                            label: 'favorites',
                            tracks: tracks,
                          );
                          await library.queueServerDownloadsForTracks(tracks);
                        },
                  icon: const Icon(Icons.download_for_offline_outlined),
                ),
              ],
            ),
            ...tracks.map(
              (track) => TrackTile(
                track: track.copyWith(isFavorite: true),
                onPlay: () =>
                    player.playTrack(track, queue: tracks, source: 'favorites'),
                onFavorite: () => library.toggleFavoriteTrack(track),
                onDownload: track.filepath.isEmpty
                    ? () => library.queueServerDownloadForTrack(track)
                    : () => offline.downloadTrack(
                        track,
                        collectionLabel: 'favorites',
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Favorite Albums (${library.favoriteAlbums.length})'),
            ...library.favoriteAlbums.map(
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
              ),
            ),
            const SizedBox(height: 12),
            Text('Favorite Artists (${library.favoriteArtists.length})'),
            ...library.favoriteArtists.map(
              (artist) => ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      artist.imageUrl == null || artist.imageUrl!.isEmpty
                      ? null
                      : NetworkImage(artist.imageUrl!),
                  child: artist.imageUrl == null || artist.imageUrl!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(artist.name),
              ),
            ),
          ],
        );
      },
    );
  }
}
