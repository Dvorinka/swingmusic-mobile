import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../core/constants/app_spacing.dart';

class SocialFeaturesScreen extends StatefulWidget {
  const SocialFeaturesScreen({super.key});

  @override
  State<SocialFeaturesScreen> createState() => _SocialFeaturesScreenState();
}

class _SocialFeaturesScreenState extends State<SocialFeaturesScreen> {
  late final EnhancedApiService _apiService;
  List<Map<String, dynamic>> _userPlaylists = [];
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = EnhancedApiService();
    _loadSocialData();
  }

  Future<void> _loadSocialData() async {
    try {
      final playlistsFuture = _apiService.getPlaylists();
      final statsFuture = _apiService.getUserSettings();

      final results = await Future.wait([playlistsFuture, statsFuture]);

      if (mounted) {
        setState(() {
          _userPlaylists = results[0] as List<Map<String, dynamic>>;
          _userStats = results[1] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share & Connect'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShareStatsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSharePlaylistsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSocialConnectSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildShareStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Share Your Stats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Show off your music taste with personalized stats',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatPreview(),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareStats,
                icon: const Icon(Icons.share),
                label: const Text('Share Stats'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPreview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'My 2024 in Music 🎵',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatPreviewItem(
                label: 'Songs',
                value: '${_userStats['totalTracks'] ?? 0}',
              ),
              _StatPreviewItem(
                label: 'Artists',
                value: '${_userStats['totalArtists'] ?? 0}',
              ),
              _StatPreviewItem(
                label: 'Hours',
                value: '${((_userStats['totalPlayTime'] ?? 0) / 3600).round()}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSharePlaylistsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.playlist_play,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Share Playlists',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Share your favorite playlists with friends',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_userPlaylists.isEmpty)
              Text(
                'No playlists to share',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              Column(
                children: _userPlaylists.take(3).map((playlist) {
                  return _PlaylistShareItem(
                    playlist: playlist,
                    onShare: () => _sharePlaylist(playlist),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialConnectSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Connect with Friends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Follow friends and discover what they\'re listening to',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _SocialConnectItem(
              icon: Icons.person_add,
              title: 'Find Friends',
              subtitle: 'Connect with friends using their username',
              onTap: _findFriends,
            ),
            const SizedBox(height: AppSpacing.sm),
            _SocialConnectItem(
              icon: Icons.qr_code_scanner,
              title: 'Scan QR Code',
              subtitle: 'Add friends by scanning their QR code',
              onTap: _scanQRCode,
            ),
            const SizedBox(height: AppSpacing.sm),
            _SocialConnectItem(
              icon: Icons.share,
              title: 'Invite Friends',
              subtitle: 'Share SwingMusic with your friends',
              onTap: _inviteFriends,
            ),
          ],
        ),
      ),
    );
  }

  void _shareStats() {
    final statsText = '''
🎵 My 2024 in Music 🎵

📊 My Stats:
• ${_userStats['totalTracks'] ?? 0} songs discovered
• ${_userStats['totalArtists'] ?? 0} artists explored
• ${((_userStats['totalPlayTime'] ?? 0) / 3600).round()} hours of music

🎧 Top Artist: ${_userStats['topArtist'] ?? 'Unknown'}
🔥 Most Played: ${_userStats['topTrack'] ?? 'Unknown'}

What's your 2024 music story? #SwingMusic #MusicRecap
''';

    Share.share(
      statsText,
      subject: 'My 2024 Music Recap',
    );
  }

  void _sharePlaylist(Map<String, dynamic> playlist) {
    final playlistText = '''
🎵 Check out my playlist: ${playlist['name'] ?? 'My Playlist'}

${playlist['description'] ?? 'A great collection of songs'}

🎧 ${playlist['trackcount'] ?? 0} tracks
⏱️ ${playlist['duration'] ?? '0'} minutes total

Listen on SwingMusic! 🎶
''';

    Share.share(
      playlistText,
      subject: playlist['name'] ?? 'My Playlist',
    );
  }

  void _findFriends() {
    // Navigate to find friends screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Find friends feature coming soon!')),
    );
  }

  void _scanQRCode() {
    // Navigate to QR scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR scanner feature coming soon!')),
    );
  }

  void _inviteFriends() {
    final inviteText = '''
🎵 Join me on SwingMusic! 🎵

Discover, organize, and enjoy your music collection with me. SwingMusic is the ultimate music management app with features like:

• 📚 Complete library management
• 🎵 Advanced analytics and stats
• 📱 Cross-platform support
• 🎧 High-quality streaming
• 📊 Year-end music recaps

Download now and let's share our music journey together!

#SwingMusic #MusicLovers
''';

    Share.share(
      inviteText,
      subject: 'Join me on SwingMusic!',
    );
  }
}

class _StatPreviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatPreviewItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _PlaylistShareItem extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final VoidCallback onShare;

  const _PlaylistShareItem({
    required this.playlist,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.playlist_play,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(playlist['name'] ?? 'Unknown Playlist'),
      subtitle: Text('${playlist['trackcount'] ?? 0} tracks'),
      trailing: IconButton(
        onPressed: onShare,
        icon: const Icon(Icons.share),
      ),
    );
  }
}

class _SocialConnectItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SocialConnectItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
