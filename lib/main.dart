import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';
import 'features/player/enhanced_player_screen_new.dart';
import 'features/search/search_screen.dart';
import 'features/playlists/playlists_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/auth/enhanced_auth_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'shared/providers/audio_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/enhanced_library_provider.dart';
import 'shared/routes/app_router.dart';
import 'shared/widgets/main_navigation.dart';
import 'core/themes/app_theme.dart';

void main() {
  runApp(const SwingMusicApp());
}

class SwingMusicApp extends StatelessWidget {
  const SwingMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedLibraryProvider()),
      ],
      child: MaterialApp.router(
        title: 'SwingMusic',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
