import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.check_circle : Icons.error,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected ? 'Connected' : 'Disconnected',
            style: const TextStyle(
              color: Colors.white,
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
            _audioQuality = value == 'Low' ? 0.5 : value == 'High' ? 1.0 : 0.75;
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
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          value: ThemeMode.light,
          groupValue: _themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              setState(() {
                _themeMode = value;
              });
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          value: ThemeMode.dark,
          groupValue: _themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              setState(() {
                _themeMode = value;
              });
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System'),
          value: ThemeMode.system,
          groupValue: _themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              setState(() {
                _themeMode = value;
              });
            }
          },
        ),
      ],
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
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
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