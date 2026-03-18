import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/enhanced_library_provider.dart';
import '../../core/constants/app_spacing.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Settings
            _buildSection(
              context,
              'Connection',
              Icons.cloud,
              [
                _buildServerUrlTile(context),
                _buildAuthStatusTile(context),
                _buildConnectionTestTile(context),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Audio Settings
            _buildSection(
              context,
              'Audio',
              Icons.music_note,
              [
                _buildAudioQualityTile(context),
                _buildCrossfadeTile(context),
                _buildGaplessTile(context),
                _buildVolumeTile(context),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Download Settings
            _buildSection(
              context,
              'Downloads',
              Icons.download,
              [
                _buildDownloadQualityTile(context),
                _buildDownloadLocationTile(context),
                _buildWifiOnlyTile(context),
                _buildMaxDownloadSizeTile(context),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Theme Settings
            _buildSection(
              context,
              'Appearance',
              Icons.palette,
              [
                _buildThemeTile(context),
                _buildAccentColorTile(context),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Cache Settings
            _buildSection(
              context,
              'Storage',
              Icons.storage,
              [
                _buildCacheSizeTile(context),
                _buildClearCacheTile(context),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // About
            _buildSection(
              context,
              'About',
              Icons.info,
              [
                _buildVersionTile(context),
                _buildBuildNumberTile(context),
                _buildDeveloperTile(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildServerUrlTile(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.link,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Server URL',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            authProvider.baseUrl ?? 'Not set',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: IconButton(
            onPressed: () => _showServerUrlDialog(context, authProvider),
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthStatusTile(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ListTile(
          leading: Icon(
            authProvider.isLoggedIn ? Icons.check_circle : Icons.error,
            color: authProvider.isLoggedIn 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Authentication Status',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            authProvider.isLoggedIn ? 'Connected' : 'Not connected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: authProvider.isLoggedIn 
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: authProvider.isLoggedIn
              ? IconButton(
                  onPressed: () => _showLogoutDialog(context, authProvider),
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildConnectionTestTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.wifi,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        'Test Connection',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        'Check server connectivity',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: IconButton(
        onPressed: () => _testConnection(context),
        icon: Icon(
          Icons.play_arrow,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAudioQualityTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.high_quality,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Audio Quality',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Higher quality uses more storage',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<String>(
            value: libraryProvider.userPreferences['audioQuality'] ?? '320kbps',
            items: const ['128kbps', '320kbps', '512kbps', 'flac'],
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'audioQuality': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildCrossfadeTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.blur_on,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Crossfade',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Smooth transitions between tracks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Switch(
            value: libraryProvider.userPreferences['crossfade'] ?? false,
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'crossfade': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildGaplessTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.skip_next,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Gapless Playback',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Remove silence between tracks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Switch(
            value: libraryProvider.userPreferences['gapless'] ?? false,
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'gapless': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildVolumeTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.volume_up,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Default Volume',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Set default volume level',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<double>(
            value: (libraryProvider.userPreferences['defaultVolume'] ?? 1.0).toDouble(),
            items: [0.25, 0.5, 0.75, 1.0],
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'defaultVolume': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildDownloadQualityTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.download,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Download Quality',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Choose audio quality for downloads',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<String>(
            value: libraryProvider.userPreferences['downloadQuality'] ?? '320kbps',
            items: const ['128kbps', '320kbps', '512kbps', 'flac'],
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'downloadQuality': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildDownloadLocationTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.folder,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Download Location',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Where to save downloaded files',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<String>(
            value: libraryProvider.userPreferences['downloadLocation'] ?? 'Music',
            items: const ['Music', 'Downloads', 'Custom'],
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'downloadLocation': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildWifiOnlyTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.wifi,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Wi-Fi Only',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Download only when connected to Wi-Fi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Switch(
            value: libraryProvider.userPreferences['wifiOnly'] ?? false,
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'wifiOnly': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildMaxDownloadSizeTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.sd_storage,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Max Download Size',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Maximum size for automatic downloads',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<String>(
            value: libraryProvider.userPreferences['maxDownloadSize'] ?? '100MB',
            items: const ['50MB', '100MB', '500MB', '1GB'],
            onChanged: (value) => libraryProvider.updateUserPreferences({
              'maxDownloadSize': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.palette,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Theme',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Choose app appearance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<ThemeMode>(
            value: _getThemeMode(libraryProvider.userPreferences['theme']),
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (ThemeMode? value) => libraryProvider.updateUserPreferences({
              'theme': value?.name,
            }),
          ),
        );
      },
    );
  }

  Widget _buildAccentColorTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.color_lens,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Accent Color',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Customize accent colors',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<String>(
            value: libraryProvider.userPreferences['accentColor'] ?? 'Blue',
            items: const [
              DropdownMenuItem(value: 'Blue', child: Text('Blue')),
              DropdownMenuItem(value: 'Green', child: Text('Green')),
              DropdownMenuItem(value: 'Purple', child: Text('Purple')),
              DropdownMenuItem(value: 'Orange', child: Text('Orange')),
              DropdownMenuItem(value: 'Red', child: Text('Red')),
            ],
            onChanged: (String? value) => libraryProvider.updateUserPreferences({
              'accentColor': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildCacheSizeTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.cached,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Cache Size',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Maximum cache size',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<String>(
            value: libraryProvider.userPreferences['cacheSize'] ?? '500MB',
            items: const ['100MB', '500MB', '1GB', '2GB', '5GB'],
            onChanged: (String? value) => libraryProvider.updateUserPreferences({
              'cacheSize': value,
            }),
          ),
        );
      },
    );
  }

  Widget _buildClearCacheTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.clear_all,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Clear Cache',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Free up storage space',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: IconButton(
            onPressed: () => _showClearCacheDialog(context),
            icon: Icon(
              Icons.delete_sweep,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.info,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Version',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            libraryProvider.statistics['version'] ?? 'Unknown',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBuildNumberTile(BuildContext context) {
    return Consumer<EnhancedLibraryProvider>(
      builder: (context, libraryProvider, child) {
        return ListTile(
          leading: Icon(
            Icons.build,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(
            'Build Number',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            libraryProvider.statistics['buildNumber'] ?? 'Unknown',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeveloperTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.code,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        'Developer',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        'View developer options',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
          trailing: IconButton(
            onPressed: () => _showDeveloperOptions(context),
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
  }

  ThemeMode _getThemeMode(String? themeString) {
    switch (themeString) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _showServerUrlDialog(BuildContext context, AuthProvider authProvider) {
    final controller = TextEditingController(text: authProvider.baseUrl ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Server URL'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Server URL',
            hintText: 'https://your-server.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authProvider.updateBaseUrl(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pop();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _testConnection(BuildContext context) {
    // TODO: Implement connection test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connection test not implemented yet')),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache'),
        content: Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Developer Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Debug Mode'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement debug mode
                },
              ),
            ),
            ListTile(
              title: Text('Enable Logging'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement logging
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
