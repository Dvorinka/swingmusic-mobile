import 'package:flutter/material.dart';

/// Unified icon constants and sizes matching web client
class AppIcons {
  // Navigation icons
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData search = Icons.search_outlined;
  static const IconData searchFilled = Icons.search;
  static const IconData library = Icons.library_music_outlined;
  static const IconData libraryFilled = Icons.library_music;
  
  // Media control icons
  static const IconData play = Icons.play_arrow;
  static const IconData pause = Icons.pause;
  static const IconData skipBack = Icons.skip_previous;
  static const IconData skipForward = Icons.skip_next;
  static const IconData volume = Icons.volume_up_outlined;
  static const IconData volumeMuted = Icons.volume_off_outlined;
  
  // Content icons
  static const IconData album = Icons.album;
  static const IconData artist = Icons.person;
  static const IconData track = Icons.music_note;
  static const IconData folder = Icons.folder;
  static const IconData playlist = Icons.playlist_play;
  static const IconData favorite = Icons.favorite_border;
  static const IconData favoriteFilled = Icons.favorite;
  
  // Action icons
  static const IconData more = Icons.more_vert;
  static const IconData add = Icons.add;
  static const IconData download = Icons.download;
  static const IconData share = Icons.share;
  static const IconData settings = Icons.settings;
  static const IconData notifications = Icons.notifications_outlined;
  static const IconData user = Icons.person;
  
  // Status icons
  static const IconData playing = Icons.equalizer;
  static const IconData success = Icons.check_circle;
  static const IconData error = Icons.error;
  static const IconData warning = Icons.warning;
  static const IconData info = Icons.info;
}

/// Unified icon sizes matching web client
class AppIconSizes {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
  
  // Navigation icons
  static const double navigationSize = sm;
  
  // Media control icons
  static const double mediaControlSize = lg;
  static const double mediaControlSmallSize = md;
  
  // Content icons
  static const double contentIconSize = md;
  static const double contentIconLargeSize = lg;
  
  // Action icons
  static const double actionIconSize = sm;
  static const double actionIconLargeSize = md;
  
  // Status icons
  static const double statusIconSize = sm;
  static const double statusIconLargeSize = md;
}

/// Icon widget with consistent styling
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  
  const AppIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size ?? AppIconSizes.contentIconSize,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
