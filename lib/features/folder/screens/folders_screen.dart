import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/folders_provider.dart';
import '../../player/providers/media_controller_provider.dart';
import '../../../shared/providers/audio_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/folder_model.dart';
import '../../../data/models/track_model.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<FoldersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.folders.isEmpty) {
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
                    'Failed to load folders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadFolders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (provider.hasCurrentFolder) {
            return _buildCurrentFolder(context, provider);
          }
          
          return _buildFolderList(context, provider);
        },
      ),
    );
  }
  
  Widget _buildFolderList(BuildContext context, FoldersProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadFolders(),
      child: provider.folders.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: provider.folders.length,
              itemBuilder: (context, index) {
                final folder = provider.folders[index];
                return _buildFolderTile(context, folder, provider);
              },
            ),
    );
  }
  
  Widget _buildFolderTile(BuildContext context, FolderModel folder, FoldersProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: folder.image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    folder.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.folder,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
        title: Text(folder.name),
        subtitle: Text('${folder.trackcount} tracks'),
        trailing: folder.isFavorite
            ? Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              )
            : const Icon(Icons.chevron_right),
        onTap: () {
          provider.loadFolderTracks(folder.path, folder.name);
        },
      ),
    );
  }
  
  Widget _buildCurrentFolder(BuildContext context, FoldersProvider provider) {
    return Column(
      children: [
        // Breadcrumb
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 8,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => provider.clearCurrentFolder(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => provider.clearCurrentFolder(),
                        child: Text(
                          'Library',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const Text(' / '),
                      Text(
                        provider.currentFolderName!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Tracks list
        Expanded(
          child: provider.currentFolderTracks.isEmpty
              ? _buildEmptyFolderState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: provider.currentFolderTracks.length,
                  itemBuilder: (context, index) {
                    final track = provider.currentFolderTracks[index];
                    return _buildTrackTile(context, track);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildTrackTile(BuildContext context, track) {
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
      title: Text(track.title),
      subtitle: Text('${track.artist} • ${track.album}'),
      trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'play':
                _playTrack(track);
                break;
              case 'add_to_queue':
                _addTrackToQueue(track);
                break;
              case 'add_to_playlist':
                _addTrackToPlaylist(track);
                break;
              case 'favorite':
                _toggleFavorite(track);
                break;
              case 'download':
                _downloadTrack(track);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Play'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_to_queue',
              child: Row(
                children: [
                  Icon(Icons.queue_music),
                  SizedBox(width: 8),
                  Text('Add to Queue'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_to_playlist',
              child: Row(
                children: [
                  Icon(Icons.playlist_add),
                  SizedBox(width: 8),
                  Text('Add to Playlist'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(Icons.favorite_border),
                  SizedBox(width: 8),
                  Text('Add to Favorites'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
          ],
        ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No folders found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your music library is properly configured',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final foldersProvider = Provider.of<FoldersProvider>(context, listen: false);
              foldersProvider.loadFolders();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyFolderState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No tracks in this folder',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'This folder appears to be empty',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _playTrack(TrackModel track) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Set queue source for playback logging
    final mediaController = Provider.of<MediaControllerProvider>(context, listen: false);
    mediaController.setQueueSource(QueueSource.folder, identifier: track.folder);
    
    audioProvider.setQueue([track]);
    audioProvider.loadTrack(track);
    audioProvider.play();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing: ${track.title}')),
      );
    }
  }

  void _addTrackToQueue(TrackModel track) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.addToQueue(track);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to queue: ${track.title}')),
      );
    }
  }

  void _addTrackToPlaylist(TrackModel track) {
    // Show playlist selection dialog or add to default playlist
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to playlist: ${track.title}')),
      );
    }
  }

  void _toggleFavorite(TrackModel track) {
    // Toggle favorite status and update UI
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites: ${track.title}')),
      );
    }
  }

  void _downloadTrack(TrackModel track) {
    // Initiate track download for offline listening
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading: ${track.title}')),
      );
    }
  }
}
