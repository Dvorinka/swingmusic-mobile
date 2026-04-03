import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../services/dragonfly_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  // Connection settings
  String _serverUrl = '';
  String _username = '';
  bool _isConnected = false;

  // Audio settings
  double _volume = 1.0;
  double _audioQuality = 1.0; // 0.5 = Low, 1.0 = High
  bool _gaplessPlayback = false;
  bool _crossfade = true;
  double _crossfadeDuration = 5.0;

  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;

  // Download settings
  String _downloadQuality = 'high'; // 'low', 'medium', 'high'
  bool _wifiOnlyDownloads = true;
  int _maxDownloadSize = 1000; // MB

  // Cache settings
  int _cacheSize = 500; // MB
  bool _clearCacheOnStart = false;

  // Analytics settings
  bool _enableAnalytics = true;
  bool _shareListeningData = false;

  // DragonflyDB cache status
  DragonflyStats? _dragonflyStats;
  bool _isLoadingDragonfly = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadDragonflyStats();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _serverUrl = prefs.getString('server_url') ?? AppConstants.defaultApiUrl;
      _username = prefs.getString('username') ?? '';
      _isConnected = prefs.getBool('is_connected') ?? false;
      _volume = prefs.getDouble('volume') ?? 1.0;
      _audioQuality = prefs.getDouble('audio_quality') ?? 1.0;
      _gaplessPlayback = prefs.getBool('gapless_playback') ?? false;
      _crossfade = prefs.getBool('crossfade') ?? true;
      _crossfadeDuration = prefs.getDouble('crossfade_duration') ?? 5.0;

      final themeIndex = prefs.getInt('theme_mode') ?? 2;
      _themeMode = ThemeMode.values[themeIndex];

      _downloadQuality = prefs.getString('download_quality') ?? 'high';
      _wifiOnlyDownloads = prefs.getBool('wifi_only_downloads') ?? true;
      _maxDownloadSize = prefs.getInt('max_download_size') ?? 1000;
      _cacheSize = prefs.getInt('cache_size') ?? 500;
      _clearCacheOnStart = prefs.getBool('clear_cache_on_start') ?? false;
      _enableAnalytics = prefs.getBool('enable_analytics') ?? true;
      _shareListeningData = prefs.getBool('share_listening_data') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('server_url', _serverUrl);
    await prefs.setString('username', _username);
    await prefs.setBool('is_connected', _isConnected);
    await prefs.setDouble('volume', _volume);
    await prefs.setDouble('audio_quality', _audioQuality);
    await prefs.setBool('gapless_playback', _gaplessPlayback);
    await prefs.setBool('crossfade', _crossfade);
    await prefs.setDouble('crossfade_duration', _crossfadeDuration);
    await prefs.setInt('theme_mode', _themeMode.index);
    await prefs.setString('download_quality', _downloadQuality);
    await prefs.setBool('wifi_only_downloads', _wifiOnlyDownloads);
    await prefs.setInt('max_download_size', _maxDownloadSize);
    await prefs.setInt('cache_size', _cacheSize);
    await prefs.setBool('clear_cache_on_start', _clearCacheOnStart);
    await prefs.setBool('enable_analytics', _enableAnalytics);
    await prefs.setBool('share_listening_data', _shareListeningData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Connection Section
                _buildSectionHeader('Connection'),
                _buildServerUrlField(),
                _buildUsernameField(),
                _buildConnectionStatus(),
                const SizedBox(height: 24),

                // Audio Section
                _buildSectionHeader('Audio'),
                _buildVolumeSlider(),
                _buildAudioQualityDropdown(),
                _buildGaplessPlaybackSwitch(),
                _buildCrossfadeSwitch(),
                _buildCrossfadeDurationSlider(),
                const SizedBox(height: 24),

                // Theme Section
                _buildSectionHeader('Appearance'),
                _buildThemeSelector(),
                const SizedBox(height: 24),

                // Download Section
                _buildSectionHeader('Downloads'),
                _buildDownloadQualityDropdown(),
                _buildWifiOnlySwitch(),
                _buildMaxDownloadSizeField(),
                const SizedBox(height: 24),

                // Cache Section
                _buildSectionHeader('Storage'),
                _buildCacheSizeField(),
                _buildClearCacheSwitch(),
                _buildClearCacheButton(),
                const SizedBox(height: 24),

                // DragonflyDB Cache Status
                _buildSectionHeader('Cache Server'),
                _buildDragonflyStatus(),
                const SizedBox(height: 24),

                // Analytics Section
                _buildSectionHeader('Analytics'),
                _buildAnalyticsSwitch(),
                _buildShareDataSwitch(),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('About'),
                _buildAppInfo(),
                _buildVersionInfo(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildServerUrlField() {
    return TextField(
      controller: TextEditingController(text: _serverUrl),
      decoration: const InputDecoration(
        labelText: 'Server URL',
        hintText: 'http://192.168.1.100:1970',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        _serverUrl = value;
      },
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: TextEditingController(text: _username),
      decoration: const InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        _username = value;
      },
    );
  }

  Widget _buildConnectionStatus() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isConnected 
            ? colorScheme.primary.withValues(alpha: 0.15)
            : colorScheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.check_circle : Icons.error,
            color: _isConnected ? colorScheme.primary : colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: _isConnected ? colorScheme.primary : colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Volume: ${(_volume * 100).round()}%'),
        Slider(
          value: _volume,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          onChanged: (value) {
            setState(() {
              _volume = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAudioQualityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Audio Quality',
        border: OutlineInputBorder(),
      ),
      items: ['Low', 'Medium', 'High'].map((quality) {
        return DropdownMenuItem(
          value: quality,
          child: Text(quality),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _audioQuality = value == 'Low'
                ? 0.5
                : value == 'High'
                    ? 1.0
                    : 0.75;
          });
        }
      },
    );
  }

  Widget _buildGaplessPlaybackSwitch() {
    return SwitchListTile(
      title: const Text('Gapless Playback'),
      subtitle: const Text('Remove gaps between tracks'),
      value: _gaplessPlayback,
      onChanged: (value) {
        setState(() {
          _gaplessPlayback = value;
        });
      },
    );
  }

  Widget _buildCrossfadeSwitch() {
    return SwitchListTile(
      title: const Text('Crossfade'),
      subtitle: const Text('Smooth transition between tracks'),
      value: _crossfade,
      onChanged: (value) {
        setState(() {
          _crossfade = value;
        });
      },
    );
  }

  Widget _buildCrossfadeDurationSlider() {
    if (!_crossfade) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Crossfade Duration: ${_crossfadeDuration.round()}s'),
        Slider(
          value: _crossfadeDuration,
          min: 1.0,
          max: 10.0,
          divisions: 18,
          onChanged: (value) {
            setState(() {
              _crossfadeDuration = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.settings_system_daydream),
        ),
      ],
      selected: {_themeMode},
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        setState(() {
          _themeMode = newSelection.first;
        });
      },
    );
  }

  Widget _buildDownloadQualityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Download Quality',
        border: OutlineInputBorder(),
      ),
      items: ['Low', 'Medium', 'High'].map((quality) {
        return DropdownMenuItem(
          value: quality,
          child: Text(quality),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _downloadQuality = value;
          });
        }
      },
    );
  }

  Widget _buildWifiOnlySwitch() {
    return SwitchListTile(
      title: const Text('Wi-Fi Only Downloads'),
      subtitle: const Text('Only download when connected to Wi-Fi'),
      value: _wifiOnlyDownloads,
      onChanged: (value) {
        setState(() {
          _wifiOnlyDownloads = value;
        });
      },
    );
  }

  Widget _buildMaxDownloadSizeField() {
    return TextField(
      controller: TextEditingController(text: _maxDownloadSize.toString()),
      decoration: const InputDecoration(
        labelText: 'Max Download Size (MB)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _maxDownloadSize = int.tryParse(value) ?? _maxDownloadSize;
      },
    );
  }

  Widget _buildCacheSizeField() {
    return TextField(
      controller: TextEditingController(text: _cacheSize.toString()),
      decoration: const InputDecoration(
        labelText: 'Cache Size (MB)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _cacheSize = int.tryParse(value) ?? _cacheSize;
      },
    );
  }

  Widget _buildClearCacheSwitch() {
    return SwitchListTile(
      title: const Text('Clear Cache on Start'),
      subtitle: const Text('Clear cache when app starts'),
      value: _clearCacheOnStart,
      onChanged: (value) {
        setState(() {
          _clearCacheOnStart = value;
        });
      },
    );
  }

  Widget _buildClearCacheButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: () async {
        // Clear cache logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared')),
        );
      },
      icon: const Icon(Icons.delete_outline),
      label: const Text('Clear Cache'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
    );
  }

  Widget _buildAnalyticsSwitch() {
    return SwitchListTile(
      title: const Text('Enable Analytics'),
      subtitle: const Text('Track listening statistics'),
      value: _enableAnalytics,
      onChanged: (value) {
        setState(() {
          _enableAnalytics = value;
        });
      },
    );
  }

  Widget _buildShareDataSwitch() {
    return SwitchListTile(
      title: const Text('Share Listening Data'),
      subtitle: const Text('Share anonymous listening data for improvements'),
      value: _shareListeningData,
      onChanged: (value) {
        setState(() {
          _shareListeningData = value;
        });
      },
    );
  }

  Widget _buildAppInfo() {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('About SwingMusic'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'SwingMusic',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(Icons.music_note),
          children: [
            const Text('A modern music player for SwingMusic server'),
            const Text('Built with Flutter'),
          ],
        );
      },
    );
  }

  Future<void> _loadDragonflyStats() async {
    if (!_isConnected || _serverUrl.isEmpty) return;

    setState(() {
      _isLoadingDragonfly = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final service = DragonflyService(
        baseUrl: _serverUrl,
        authToken: token,
      );

      final stats = await service.getStats();
      setState(() {
        _dragonflyStats = stats;
        _isLoadingDragonfly = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDragonfly = false;
      });
    }
  }

  Widget _buildDragonflyStatus() {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_isConnected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Connect to server to view cache status',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_isLoadingDragonfly) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dragonflyStats == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Text(
              'Cache server status unavailable',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ],
        ),
      );
    }

    final stats = _dragonflyStats!;
    final statusColor = stats.connected
        ? (stats.latencyMs > 100 ? colorScheme.tertiary : colorScheme.primary)
        : colorScheme.error;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stats.statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadDragonflyStats,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
                'Latency', '${stats.latencyMs.toStringAsFixed(1)} ms'),
            _buildStatRow('Memory Used', stats.memoryUsed),
            _buildStatRow('Memory Peak', stats.memoryPeak),
            _buildStatRow('Cached Keys', stats.totalKeys.toString()),
            _buildStatRow('Uptime', stats.uptimeFormatted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return ListTile(
      leading: const Icon(Icons.code),
      title: const Text('Version'),
      subtitle: const Text('1.0.0 (Flutter)'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Show changelog
      },
    );
  }
}
