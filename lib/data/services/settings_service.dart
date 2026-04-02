import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'enhanced_api_service.dart';
import '../models/settings_model.dart';

class SettingsService {
  final EnhancedApiService _apiService;
  late SharedPreferences _prefs;
  UserSettings _currentSettings = const UserSettings();

  SettingsService(this._apiService) {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs.getString('user_settings');
      if (settingsJson != null) {
        // In a real implementation, you'd parse JSON here
        // For now, we'll load individual settings
        _currentSettings = UserSettings(
          theme: _prefs.getString('theme') ?? 'dark',
          accentColor: _prefs.getString('accentColor') ?? 'blue',
          useCircularArtistImages:
              _prefs.getBool('useCircularArtistImages') ?? true,
          showTrackNumbers: _prefs.getBool('showTrackNumbers') ?? true,
          compactLayout: _prefs.getBool('compactLayout') ?? false,
          volume: _prefs.getDouble('volume') ?? 1.0,
          isMuted: _prefs.getBool('isMuted') ?? false,
          crossfadeDuration: _prefs.getInt('crossfadeDuration') ?? 1000,
          useCrossfade: _prefs.getBool('useCrossfade') ?? false,
          useSilenceSkip: _prefs.getBool('useSilenceSkip') ?? true,
          streamingQuality: _prefs.getString('streamingQuality') ?? 'original',
          defaultView: _prefs.getString('defaultView') ?? 'albums',
          showAlbumsAsSingles: _prefs.getBool('showAlbumsAsSingles') ?? false,
          mergeAlbums: _prefs.getBool('mergeAlbums') ?? false,
          cleanTrackTitles: _prefs.getBool('cleanTrackTitles') ?? true,
          hideRemasteredVersions:
              _prefs.getBool('hideRemasteredVersions') ?? true,
          repeatMode: _prefs.getString('repeatMode') ?? 'none',
          autoPlay: _prefs.getBool('autoPlay') ?? true,
          showNowPlayingInTab: _prefs.getBool('showNowPlayingInTab') ?? true,
          showLyricsByDefault: _prefs.getBool('showLyricsByDefault') ?? true,
          extendWidth: _prefs.getBool('extendWidth') ?? false,
          useSidebar: _prefs.getBool('useSidebar') ?? false,
          showInlineFavoriteIcon:
              _prefs.getBool('showInlineFavoriteIcon') ?? false,
          highlightFavoriteTracks:
              _prefs.getBool('highlightFavoriteTracks') ?? false,
          useLyricsPlugin: _prefs.getBool('useLyricsPlugin') ?? false,
          autoDownloadLyrics: _prefs.getBool('autoDownloadLyrics') ?? false,
          overrideUnsyncedLyrics:
              _prefs.getBool('overrideUnsyncedLyrics') ?? false,
          enableTracking: _prefs.getBool('enableTracking') ?? true,
          statsPeriod: _prefs.getString('statsPeriod') ?? 'week',
          statsGroup: _prefs.getString('statsGroup') ?? 'artists',
          lastfmApiKey: _prefs.getString('lastfmApiKey') ?? '',
          lastfmApiSecret: _prefs.getString('lastfmApiSecret') ?? '',
          lastfmSessionKey: _prefs.getString('lastfmSessionKey') ?? '',
          enablePeriodicScans: _prefs.getBool('enablePeriodicScans') ?? false,
          periodicScanInterval: _prefs.getInt('periodicScanInterval') ?? 3600,
          enableWatchdog: _prefs.getBool('enableWatchdog') ?? false,
          enableNotifications: _prefs.getBool('enableNotifications') ?? true,
          showPlayingNotification:
              _prefs.getBool('showPlayingNotification') ?? true,
          showControlsInNotification:
              _prefs.getBool('showControlsInNotification') ?? true,
        );
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _prefs.setString('theme', _currentSettings.theme);
      await _prefs.setString('accentColor', _currentSettings.accentColor);
      await _prefs.setBool(
          'useCircularArtistImages', _currentSettings.useCircularArtistImages);
      await _prefs.setBool(
          'showTrackNumbers', _currentSettings.showTrackNumbers);
      await _prefs.setBool('compactLayout', _currentSettings.compactLayout);
      await _prefs.setDouble('volume', _currentSettings.volume);
      await _prefs.setBool('isMuted', _currentSettings.isMuted);
      await _prefs.setInt(
          'crossfadeDuration', _currentSettings.crossfadeDuration);
      await _prefs.setBool('useCrossfade', _currentSettings.useCrossfade);
      await _prefs.setBool('useSilenceSkip', _currentSettings.useSilenceSkip);
      await _prefs.setString(
          'streamingQuality', _currentSettings.streamingQuality);
      await _prefs.setString('defaultView', _currentSettings.defaultView);
      await _prefs.setBool(
          'showAlbumsAsSingles', _currentSettings.showAlbumsAsSingles);
      await _prefs.setBool('mergeAlbums', _currentSettings.mergeAlbums);
      await _prefs.setBool(
          'cleanTrackTitles', _currentSettings.cleanTrackTitles);
      await _prefs.setBool(
          'hideRemasteredVersions', _currentSettings.hideRemasteredVersions);
      await _prefs.setString('repeatMode', _currentSettings.repeatMode);
      await _prefs.setBool('autoPlay', _currentSettings.autoPlay);
      await _prefs.setBool(
          'showNowPlayingInTab', _currentSettings.showNowPlayingInTab);
      await _prefs.setBool(
          'showLyricsByDefault', _currentSettings.showLyricsByDefault);
      await _prefs.setBool('extendWidth', _currentSettings.extendWidth);
      await _prefs.setBool('useSidebar', _currentSettings.useSidebar);
      await _prefs.setBool(
          'showInlineFavoriteIcon', _currentSettings.showInlineFavoriteIcon);
      await _prefs.setBool(
          'highlightFavoriteTracks', _currentSettings.highlightFavoriteTracks);
      await _prefs.setBool('useLyricsPlugin', _currentSettings.useLyricsPlugin);
      await _prefs.setBool(
          'autoDownloadLyrics', _currentSettings.autoDownloadLyrics);
      await _prefs.setBool(
          'overrideUnsyncedLyrics', _currentSettings.overrideUnsyncedLyrics);
      await _prefs.setBool('enableTracking', _currentSettings.enableTracking);
      await _prefs.setString('statsPeriod', _currentSettings.statsPeriod);
      await _prefs.setString('statsGroup', _currentSettings.statsGroup);
      await _prefs.setString('lastfmApiKey', _currentSettings.lastfmApiKey);
      await _prefs.setString(
          'lastfmApiSecret', _currentSettings.lastfmApiSecret);
      await _prefs.setString(
          'lastfmSessionKey', _currentSettings.lastfmSessionKey);
      await _prefs.setBool(
          'enablePeriodicScans', _currentSettings.enablePeriodicScans);
      await _prefs.setInt(
          'periodicScanInterval', _currentSettings.periodicScanInterval);
      await _prefs.setBool('enableWatchdog', _currentSettings.enableWatchdog);
      await _prefs.setBool(
          'enableNotifications', _currentSettings.enableNotifications);
      await _prefs.setBool(
          'showPlayingNotification', _currentSettings.showPlayingNotification);
      await _prefs.setBool('showControlsInNotification',
          _currentSettings.showControlsInNotification);

      // Also sync with server if available
      try {
        await _apiService.updateUserSettings(_currentSettings.toJson());
      } catch (e) {
        debugPrint('Failed to sync settings with server: $e');
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  UserSettings get currentSettings => _currentSettings;

  // Appearance settings
  Future<void> setTheme(String theme) async {
    _currentSettings = _currentSettings.copyWith(theme: theme);
    await _saveSettings();
  }

  Future<void> setAccentColor(String color) async {
    _currentSettings = _currentSettings.copyWith(accentColor: color);
    await _saveSettings();
  }

  Future<void> setUseCircularArtistImages(bool use) async {
    _currentSettings = _currentSettings.copyWith(useCircularArtistImages: use);
    await _saveSettings();
  }

  Future<void> setShowTrackNumbers(bool show) async {
    _currentSettings = _currentSettings.copyWith(showTrackNumbers: show);
    await _saveSettings();
  }

  Future<void> setCompactLayout(bool compact) async {
    _currentSettings = _currentSettings.copyWith(compactLayout: compact);
    await _saveSettings();
  }

  // Audio settings
  Future<void> setVolume(double volume) async {
    _currentSettings = _currentSettings.copyWith(volume: volume);
    await _saveSettings();
  }

  Future<void> setIsMuted(bool muted) async {
    _currentSettings = _currentSettings.copyWith(isMuted: muted);
    await _saveSettings();
  }

  Future<void> setCrossfadeDuration(int duration) async {
    _currentSettings = _currentSettings.copyWith(crossfadeDuration: duration);
    await _saveSettings();
  }

  Future<void> setUseCrossfade(bool use) async {
    _currentSettings = _currentSettings.copyWith(useCrossfade: use);
    await _saveSettings();
  }

  Future<void> setUseSilenceSkip(bool use) async {
    _currentSettings = _currentSettings.copyWith(useSilenceSkip: use);
    await _saveSettings();
  }

  Future<void> setStreamingQuality(String quality) async {
    _currentSettings = _currentSettings.copyWith(streamingQuality: quality);
    await _saveSettings();
  }

  // Library settings
  Future<void> setDefaultView(String view) async {
    _currentSettings = _currentSettings.copyWith(defaultView: view);
    await _saveSettings();
  }

  Future<void> setShowAlbumsAsSingles(bool show) async {
    _currentSettings = _currentSettings.copyWith(showAlbumsAsSingles: show);
    await _saveSettings();
  }

  Future<void> setMergeAlbums(bool merge) async {
    _currentSettings = _currentSettings.copyWith(mergeAlbums: merge);
    await _saveSettings();
  }

  Future<void> setCleanTrackTitles(bool clean) async {
    _currentSettings = _currentSettings.copyWith(cleanTrackTitles: clean);
    await _saveSettings();
  }

  Future<void> setHideRemasteredVersions(bool hide) async {
    _currentSettings = _currentSettings.copyWith(hideRemasteredVersions: hide);
    await _saveSettings();
  }

  // Player settings
  Future<void> setRepeatMode(String mode) async {
    _currentSettings = _currentSettings.copyWith(repeatMode: mode);
    await _saveSettings();
  }

  Future<void> setAutoPlay(bool auto) async {
    _currentSettings = _currentSettings.copyWith(autoPlay: auto);
    await _saveSettings();
  }

  Future<void> setShowNowPlayingInTab(bool show) async {
    _currentSettings = _currentSettings.copyWith(showNowPlayingInTab: show);
    await _saveSettings();
  }

  Future<void> setShowLyricsByDefault(bool show) async {
    _currentSettings = _currentSettings.copyWith(showLyricsByDefault: show);
    await _saveSettings();
  }

  // Plugin settings
  Future<void> setUseLyricsPlugin(bool use) async {
    _currentSettings = _currentSettings.copyWith(useLyricsPlugin: use);
    await _saveSettings();
  }

  Future<void> setAutoDownloadLyrics(bool auto) async {
    _currentSettings = _currentSettings.copyWith(autoDownloadLyrics: auto);
    await _saveSettings();
  }

  Future<void> setOverrideUnsyncedLyrics(bool override) async {
    _currentSettings =
        _currentSettings.copyWith(overrideUnsyncedLyrics: override);
    await _saveSettings();
  }

  // Stats settings
  Future<void> setEnableTracking(bool enable) async {
    _currentSettings = _currentSettings.copyWith(enableTracking: enable);
    await _saveSettings();
  }

  Future<void> setStatsPeriod(String period) async {
    _currentSettings = _currentSettings.copyWith(statsPeriod: period);
    await _saveSettings();
  }

  Future<void> setStatsGroup(String group) async {
    _currentSettings = _currentSettings.copyWith(statsGroup: group);
    await _saveSettings();
  }

  // Last.fm settings
  Future<void> setLastFmCredentials(
      String apiKey, String apiSecret, String sessionKey) async {
    _currentSettings = _currentSettings.copyWith(
      lastfmApiKey: apiKey,
      lastfmApiSecret: apiSecret,
      lastfmSessionKey: sessionKey,
    );
    await _saveSettings();
  }

  // Advanced settings
  Future<void> setEnablePeriodicScans(bool enable) async {
    _currentSettings = _currentSettings.copyWith(enablePeriodicScans: enable);
    await _saveSettings();
  }

  Future<void> setPeriodicScanInterval(int interval) async {
    _currentSettings =
        _currentSettings.copyWith(periodicScanInterval: interval);
    await _saveSettings();
  }

  Future<void> setEnableWatchdog(bool enable) async {
    _currentSettings = _currentSettings.copyWith(enableWatchdog: enable);
    await _saveSettings();
  }

  // Notification settings
  Future<void> setEnableNotifications(bool enable) async {
    _currentSettings = _currentSettings.copyWith(enableNotifications: enable);
    await _saveSettings();
  }

  Future<void> setShowPlayingNotification(bool show) async {
    _currentSettings = _currentSettings.copyWith(showPlayingNotification: show);
    await _saveSettings();
  }

  Future<void> setShowControlsInNotification(bool show) async {
    _currentSettings =
        _currentSettings.copyWith(showControlsInNotification: show);
    await _saveSettings();
  }

  // Utility methods
  List<SettingsCategory> getSettingsCategories() {
    return [
      SettingsCategory(
        title: 'Appearance',
        description: 'Customize the look and feel',
        icon: 'palette',
        settings: [
          SettingItem(
            key: 'theme',
            title: 'Theme',
            description: 'Choose your preferred theme',
            type: SettingsType.selection,
            value: _currentSettings.theme,
            options: ['light', 'dark', 'auto'],
          ),
          SettingItem(
            key: 'accentColor',
            title: 'Accent Color',
            description: 'Select accent color',
            type: SettingsType.selection,
            value: _currentSettings.accentColor,
            options: ['blue', 'green', 'purple', 'red', 'orange', 'pink'],
          ),
          SettingItem(
            key: 'useCircularArtistImages',
            title: 'Circular Artist Images',
            description: 'Show artist images as circles',
            type: SettingsType.boolean,
            value: _currentSettings.useCircularArtistImages,
          ),
          SettingItem(
            key: 'showTrackNumbers',
            title: 'Show Track Numbers',
            description: 'Display track numbers in lists',
            type: SettingsType.boolean,
            value: _currentSettings.showTrackNumbers,
          ),
          SettingItem(
            key: 'compactLayout',
            title: 'Compact Layout',
            description: 'Use more compact layout',
            type: SettingsType.boolean,
            value: _currentSettings.compactLayout,
          ),
        ],
      ),
      SettingsCategory(
        title: 'Audio',
        description: 'Audio playback settings',
        icon: 'volume_up',
        settings: [
          SettingItem(
            key: 'volume',
            title: 'Volume',
            description: 'Default volume level',
            type: SettingsType.slider,
            value: _currentSettings.volume,
          ),
          SettingItem(
            key: 'crossfadeDuration',
            title: 'Crossfade Duration',
            description: 'Crossfade duration in milliseconds',
            type: SettingsType.number,
            value: _currentSettings.crossfadeDuration,
          ),
          SettingItem(
            key: 'useCrossfade',
            title: 'Enable Crossfade',
            description: 'Use crossfade between tracks',
            type: SettingsType.boolean,
            value: _currentSettings.useCrossfade,
          ),
          SettingItem(
            key: 'streamingQuality',
            title: 'Streaming Quality',
            description: 'Audio streaming quality',
            type: SettingsType.selection,
            value: _currentSettings.streamingQuality,
            options: ['original', 'high', 'medium', 'low'],
          ),
        ],
      ),
      SettingsCategory(
        title: 'Library',
        description: 'Library organization settings',
        icon: 'library_music',
        settings: [
          SettingItem(
            key: 'defaultView',
            title: 'Default View',
            description: 'Default library view',
            type: SettingsType.selection,
            value: _currentSettings.defaultView,
            options: ['albums', 'artists', 'folders', 'playlists'],
          ),
          SettingItem(
            key: 'cleanTrackTitles',
            title: 'Clean Track Titles',
            description: 'Clean up track titles',
            type: SettingsType.boolean,
            value: _currentSettings.cleanTrackTitles,
          ),
          SettingItem(
            key: 'hideRemasteredVersions',
            title: 'Hide Remastered',
            description: 'Hide remastered versions',
            type: SettingsType.boolean,
            value: _currentSettings.hideRemasteredVersions,
          ),
        ],
      ),
      SettingsCategory(
        title: 'Player',
        description: 'Music player behavior',
        icon: 'play_circle',
        settings: [
          SettingItem(
            key: 'repeatMode',
            title: 'Repeat Mode',
            description: 'Default repeat mode',
            type: SettingsType.selection,
            value: _currentSettings.repeatMode,
            options: ['none', 'one', 'all'],
          ),
          SettingItem(
            key: 'autoPlay',
            title: 'Auto Play',
            description: 'Automatically play next track',
            type: SettingsType.boolean,
            value: _currentSettings.autoPlay,
          ),
          SettingItem(
            key: 'showLyricsByDefault',
            title: 'Show Lyrics by Default',
            description: 'Automatically show lyrics',
            type: SettingsType.boolean,
            value: _currentSettings.showLyricsByDefault,
          ),
        ],
      ),
      SettingsCategory(
        title: 'Plugins',
        description: 'Plugin settings',
        icon: 'extension',
        settings: [
          SettingItem(
            key: 'useLyricsPlugin',
            title: 'Use Lyrics Plugin',
            description: 'Enable lyrics plugin',
            type: SettingsType.boolean,
            value: _currentSettings.useLyricsPlugin,
          ),
          SettingItem(
            key: 'autoDownloadLyrics',
            title: 'Auto Download Lyrics',
            description: 'Automatically download lyrics',
            type: SettingsType.boolean,
            value: _currentSettings.autoDownloadLyrics,
          ),
        ],
      ),
      SettingsCategory(
        title: 'Notifications',
        description: 'Notification settings',
        icon: 'notifications',
        settings: [
          SettingItem(
            key: 'enableNotifications',
            title: 'Enable Notifications',
            description: 'Show notifications',
            type: SettingsType.boolean,
            value: _currentSettings.enableNotifications,
          ),
          SettingItem(
            key: 'showPlayingNotification',
            title: 'Show Playing Notification',
            description: 'Show currently playing track',
            type: SettingsType.boolean,
            value: _currentSettings.showPlayingNotification,
          ),
          SettingItem(
            key: 'showControlsInNotification',
            title: 'Show Controls in Notification',
            description: 'Show playback controls in notification',
            type: SettingsType.boolean,
            value: _currentSettings.showControlsInNotification,
          ),
        ],
      ),
    ];
  }

  Future<void> updateSetting(String key, dynamic value) async {
    switch (key) {
      case 'theme':
        await setTheme(value as String);
        break;
      case 'accentColor':
        await setAccentColor(value as String);
        break;
      case 'useCircularArtistImages':
        await setUseCircularArtistImages(value as bool);
        break;
      case 'showTrackNumbers':
        await setShowTrackNumbers(value as bool);
        break;
      case 'compactLayout':
        await setCompactLayout(value as bool);
        break;
      case 'volume':
        await setVolume(value as double);
        break;
      case 'crossfadeDuration':
        await setCrossfadeDuration(value as int);
        break;
      case 'useCrossfade':
        await setUseCrossfade(value as bool);
        break;
      case 'streamingQuality':
        await setStreamingQuality(value as String);
        break;
      case 'defaultView':
        await setDefaultView(value as String);
        break;
      case 'cleanTrackTitles':
        await setCleanTrackTitles(value as bool);
        break;
      case 'hideRemasteredVersions':
        await setHideRemasteredVersions(value as bool);
        break;
      case 'repeatMode':
        await setRepeatMode(value as String);
        break;
      case 'autoPlay':
        await setAutoPlay(value as bool);
        break;
      case 'showLyricsByDefault':
        await setShowLyricsByDefault(value as bool);
        break;
      case 'useLyricsPlugin':
        await setUseLyricsPlugin(value as bool);
        break;
      case 'autoDownloadLyrics':
        await setAutoDownloadLyrics(value as bool);
        break;
      case 'enableNotifications':
        await setEnableNotifications(value as bool);
        break;
      case 'showPlayingNotification':
        await setShowPlayingNotification(value as bool);
        break;
      case 'showControlsInNotification':
        await setShowControlsInNotification(value as bool);
        break;
      default:
        debugPrint('Unknown setting key: $key');
    }
  }

  Future<void> resetToDefaults() async {
    _currentSettings = const UserSettings();
    await _saveSettings();
  }

  Future<void> exportSettings() async {
    // Export settings to file or share
    final settingsJson = _currentSettings.toJson();
    debugPrint('Exporting settings: ${settingsJson.length} items');
    // In a real implementation, you'd save to a file or share
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      _currentSettings = UserSettings.fromJson(settings);
      await _saveSettings();
    } catch (e) {
      debugPrint('Error importing settings: $e');
      throw Exception('Failed to import settings: $e');
    }
  }
}
