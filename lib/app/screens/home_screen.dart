import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/session_controller.dart';
import 'artist_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LibraryController, SessionController>(
      builder: (context, library, session, _) {
        final scheme = Theme.of(context).colorScheme;
        final greeting = _buildGreeting(session.username ?? '');

        return RefreshIndicator(
          onRefresh: library.loadHome,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Home', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (library.loadingHome) const LinearProgressIndicator(),
              if (library.error != null) ...[
                const SizedBox(height: 8),
                Text(library.error!, style: TextStyle(color: scheme.error)),
              ],
              const SizedBox(height: 14),
              _SectionHeader(
                title: 'Recommended Artists',
                subtitle: 'Discover global artists picked for your profile',
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                padding: const EdgeInsets.all(10),
                child: library.recommendedArtists.isEmpty
                    ? SizedBox(
                        height: 160,
                        child: Center(
                          child: Text(
                            'No recommendations yet',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width >= 700
                              ? 4
                              : width >= 460
                              ? 3
                              : 2;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: library.recommendedArtists.length.clamp(
                              0,
                              12,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.78,
                                ),
                            itemBuilder: (context, index) {
                              final artist = library.recommendedArtists[index];
                              return _RecommendedArtistCard(artist: artist);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Recently Added'),
              const SizedBox(height: 8),
              _RecentBlock(entries: library.recentlyAdded),
              const SizedBox(height: 14),
              _SectionHeader(title: 'Recently Played'),
              const SizedBox(height: 8),
              _RecentBlock(entries: library.recentlyPlayed),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  String _buildGreeting(String username) {
    final hour = DateTime.now().hour;
    final suffix = username.trim().isEmpty ? '' : ' $username';

    if (hour <= 3) return 'Hey there night owl$suffix';
    if (hour <= 5) return 'Hey there early bird$suffix';
    if (hour <= 12) return 'Good morning$suffix';
    if (hour <= 17) return 'Good afternoon$suffix';
    return 'Good evening$suffix';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _RecommendedArtistCard extends StatelessWidget {
  const _RecommendedArtistCard({required this.artist});

  final dynamic artist;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: artist.spotifyId == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(
                      artistId: artist.spotifyId!,
                      artistName: artist.name,
                    ),
                  ),
                );
              },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outlineVariant),
          ),
          padding: const EdgeInsets.all(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox.expand(
                    child: artist.imageUrl == null || artist.imageUrl!.isEmpty
                        ? Container(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person,
                              size: 28,
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        : Image.network(artist.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentBlock extends StatelessWidget {
  const _RecentBlock({required this.entries});

  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: entries.isEmpty
          ? Text(
              'No items yet',
              style: TextStyle(color: scheme.onSurfaceVariant),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries
                  .map((entry) => _RecentItemChip(entry: entry))
                  .toList(growable: false),
            ),
    );
  }
}

class _RecentItemChip extends StatelessWidget {
  const _RecentItemChip({required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final type = entry['type']?.toString() ?? 'item';
    final title =
        entry['title']?.toString() ??
        entry['name']?.toString() ??
        entry['hash']?.toString() ??
        type;

    return Chip(
      backgroundColor: Theme.of(context).colorScheme.surface,
      avatar: Icon(_iconForType(type), size: 17),
      label: Text(
        '$type · $title',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'album':
        return Icons.album;
      case 'artist':
        return Icons.mic;
      case 'playlist':
        return Icons.playlist_play;
      case 'folder':
        return Icons.folder;
      case 'track':
        return Icons.music_note;
      default:
        return Icons.history;
    }
  }
}
