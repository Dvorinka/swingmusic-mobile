import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/state/session_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _crossfadeEnabled = true;
  bool _gaplessPlaybackEnabled = false;
  bool _wifiOnlyEnabled = true;
  bool _clearCacheOnStart = false;
  bool _analyticsEnabled = true;
  String _serverUrl = 'http://localhost:1970';
  String _audioQuality = 'high';
  String _downloadQuality = 'high';
  String _theme = 'system';
  String _accentColor = 'blue';
  String _maxDownloadSize = '100';
  String _cacheSize = '256';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User section
          _buildUserSection(context),

          const SizedBox(height: 32),

          // Connection settings
          _buildSectionHeader(context, 'Connection'),
          _buildConnectionSettings(context),

          const SizedBox(height: 32),

          // Audio settings
          _buildSectionHeader(context, 'Audio'),
          _buildAudioSettings(context),

          const SizedBox(height: 32),

          // Theme settings
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeSettings(context),

          const SizedBox(height: 32),

          // Download settings
          _buildSectionHeader(context, 'Downloads'),
          _buildDownloadSettings(context),

          const SizedBox(height: 32),

          // Cache settings
          _buildSectionHeader(context, 'Storage'),
          _buildCacheSettings(context),

          const SizedBox(height: 32),

          // About section
          _buildSectionHeader(context, 'About'),
          _buildAboutSection(context),

          const SizedBox(height: 32),

          // Logout button
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, session, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: Icon(Icons.person, color: colorScheme.onPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.username ?? 'Guest User',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.isAuthenticated ? 'Logged in' : 'Not logged in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (session.isAuthenticated)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditProfileDialog(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildConnectionSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Server URL'),
            subtitle: Text(_serverUrl),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _showEditServerUrlDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Connection Status'),
            subtitle: Text(
              'Connected',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Audio Quality'),
            subtitle: Text(_getAudioQualityDisplay(_audioQuality)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAudioQualityDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Crossfade'),
            subtitle: const Text('2.0 seconds'),
            trailing: Switch(
              value: _crossfadeEnabled,
              onChanged: (value) {
                setState(() {
                  _crossfadeEnabled = value;
                });
                _saveSetting('crossfade', value);
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.skip_next),
            title: const Text('Gapless Playback'),
            subtitle: const Text('Reduce silence between tracks'),
            trailing: Switch(
              value: _gaplessPlaybackEnabled,
              onChanged: (value) {
                setState(() {
                  _gaplessPlaybackEnabled = value;
                });
                _saveSetting('gapless_playback', value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_getThemeDisplay(_theme)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showThemeDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Accent Color'),
            subtitle: Text(_getAccentColorDisplay(_accentColor)),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getAccentColorValue(_accentColor),
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              _showColorPickerDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download Quality'),
            subtitle: Text(_getAudioQualityDisplay(_downloadQuality)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDownloadQualityDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Wi-Fi Only'),
            subtitle: const Text('Download only on Wi-Fi'),
            trailing: Switch(
              value: _wifiOnlyEnabled,
              onChanged: (value) {
                setState(() {
                  _wifiOnlyEnabled = value;
                });
                _saveSetting('wifi_only', value);
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Max Download Size'),
            subtitle: Text('$_maxDownloadSize MB'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDownloadSizeDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCacheSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Cache Size'),
            subtitle: Text('$_cacheSize MB'),
            trailing: TextButton(
              onPressed: () {
                _showClearCacheDialog(context);
              },
              child: const Text('Clear'),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear Cache on Start'),
            subtitle: const Text('Clear cache when app starts'),
            trailing: Switch(
              value: _clearCacheOnStart,
              onChanged: (value) {
                setState(() {
                  _clearCacheOnStart = value;
                });
                _saveSetting('clear_cache_on_start', value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('SwingMusic 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            subtitle: const Text('Help improve the app'),
            trailing: Switch(
              value: _analyticsEnabled,
              onChanged: (value) {
                setState(() {
                  _analyticsEnabled = value;
                });
                _saveSetting('analytics', value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, session, child) {
        if (!session.isAuthenticated) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }

  // Dialog methods
  void _showEditProfileDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: 'Guest User',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profile updated')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditServerUrlDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController(
      text: _serverUrl,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Server URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'Server URL',
            border: OutlineInputBorder(),
            hintText: 'http://localhost:1970',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _serverUrl = urlController.text;
              });
              _saveSetting('server_url', _serverUrl);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Server URL updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      {'name': 'Blue', 'value': 'blue', 'color': Colors.blue},
      {'name': 'Green', 'value': 'green', 'color': Colors.green},
      {'name': 'Purple', 'value': 'purple', 'color': Colors.purple},
      {'name': 'Red', 'value': 'red', 'color': Colors.red},
      {'name': 'Orange', 'value': 'orange', 'color': Colors.orange},
      {'name': 'Teal', 'value': 'teal', 'color': Colors.teal},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Accent Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final colorData = colors[index];
              final isSelected = _accentColor == colorData['value'] as String;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _accentColor = colorData['value'] as String;
                  });
                  _saveSetting('accent_color', _accentColor);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${colorData['name']} color selected'),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorData['color'] as Color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: colorScheme.onPrimary, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: colorScheme.onPrimary)
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDownloadSizeDialog(BuildContext context) {
    String selectedSize = _maxDownloadSize;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Max Download Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return RadioGroup<String>(
              groupValue: selectedSize,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedSize = value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  RadioListTile<String>(title: Text('50 MB'), value: '50'),
                  RadioListTile<String>(title: Text('100 MB'), value: '100'),
                  RadioListTile<String>(title: Text('200 MB'), value: '200'),
                  RadioListTile<String>(title: Text('500 MB'), value: '500'),
                  RadioListTile<String>(title: Text('1000 MB'), value: '1000'),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _maxDownloadSize = selectedSize;
              });
              _saveSetting('max_download_size', _maxDownloadSize);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Max download size set to $selectedSize MB'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'Are you sure you want to clear the cache? This will remove all cached music and images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Simulate cache clearing
              setState(() {
                _cacheSize = '0';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SwingMusic',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.music_note, size: 48),
      children: [
        const Text('A modern music player built with Flutter.'),
        const SizedBox(height: 16),
        const Text(' 2024 SwingMusic Team'),
        const Text('Licensed under MIT'),
      ],
    );
  }

  void _showAudioQualityDialog(BuildContext context) {
    String selectedQuality = _audioQuality;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Quality'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return RadioGroup<String>(
              groupValue: selectedQuality,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedQuality = value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Low (96kbps)'),
                    subtitle: Text(
                      'Best for saving data',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'low',
                  ),
                  RadioListTile<String>(
                    title: const Text('Medium (192kbps)'),
                    subtitle: Text(
                      'Good balance',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'medium',
                  ),
                  RadioListTile<String>(
                    title: const Text('High (320kbps)'),
                    subtitle: Text(
                      'Best quality',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'high',
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _audioQuality = selectedQuality;
              });
              _saveSetting('audio_quality', _audioQuality);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    String selectedTheme = _theme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return RadioGroup<String>(
              groupValue: selectedTheme,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedTheme = value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RadioListTile<String>(title: Text('Light'), value: 'light'),
                  const RadioListTile<String>(title: Text('Dark'), value: 'dark'),
                  RadioListTile<String>(
                    title: const Text('System'),
                    subtitle: Text(
                      'Follow device settings',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'system',
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _theme = selectedTheme;
              });
              _saveSetting('theme', _theme);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDownloadQualityDialog(BuildContext context) {
    String selectedQuality = _downloadQuality;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Quality'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return RadioGroup<String>(
              groupValue: selectedQuality,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedQuality = value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Low (96kbps)'),
                    subtitle: Text(
                      'Smallest files',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'low',
                  ),
                  RadioListTile<String>(
                    title: const Text('Medium (192kbps)'),
                    subtitle: Text(
                      'Balanced size and quality',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'medium',
                  ),
                  RadioListTile<String>(
                    title: const Text('High (320kbps)'),
                    subtitle: Text(
                      'Best quality',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'high',
                  ),
                  RadioListTile<String>(
                    title: const Text('Lossless (FLAC)'),
                    subtitle: Text(
                      'Original quality',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    value: 'lossless',
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _downloadQuality = selectedQuality;
              });
              _saveSetting('download_quality', _downloadQuality);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getAudioQualityDisplay(String quality) {
    switch (quality) {
      case 'low':
        return 'Low (96kbps)';
      case 'medium':
        return 'Medium (192kbps)';
      case 'high':
        return 'High (320kbps)';
      case 'lossless':
        return 'Lossless (FLAC)';
      default:
        return 'High (320kbps)';
    }
  }

  String _getThemeDisplay(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System';
      default:
        return 'System';
    }
  }

  String _getAccentColorDisplay(String color) {
    switch (color) {
      case 'blue':
        return 'Blue';
      case 'green':
        return 'Green';
      case 'purple':
        return 'Purple';
      case 'red':
        return 'Red';
      case 'orange':
        return 'Orange';
      case 'teal':
        return 'Teal';
      default:
        return 'Blue';
    }
  }

  Color _getAccentColorValue(String color) {
    switch (color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  void _saveSetting(String key, dynamic value) {
    // In a real app, you would save to SharedPreferences or another storage
    debugPrint('Setting saved: $key = $value');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Setting saved')));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SessionController>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
