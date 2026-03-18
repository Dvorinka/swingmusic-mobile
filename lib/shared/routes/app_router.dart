import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/player/enhanced_player_screen_new.dart';
import '../../features/library/library_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/playlists/playlists_screen.dart';
import '../../features/settings/enhanced_settings_screen.dart';
import '../../features/auth/enhanced_auth_screen.dart';
import '../../features/downloads/downloads_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/home/home_screen.dart';
import '../widgets/main_navigation.dart';
import '../../core/constants/app_constants.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppConstants.homeRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.homeRoute,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppConstants.libraryRoute,
            name: 'library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: AppConstants.playerRoute,
            name: 'player',
            builder: (context, state) => const EnhancedPlayerScreen(),
          ),
          GoRoute(
            path: AppConstants.searchRoute,
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppConstants.playlistsRoute,
            name: 'playlists',
            builder: (context, state) => const PlaylistsScreen(),
          ),
          GoRoute(
            path: AppConstants.authRoute,
            name: 'auth',
            builder: (context, state) => const EnhancedAuthScreen(),
          ),
          GoRoute(
            path: '/downloads',
            name: 'downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            path: AppConstants.analyticsRoute,
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: AppConstants.settingsRoute,
            name: 'settings',
            builder: (context, state) => const EnhancedSettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}
