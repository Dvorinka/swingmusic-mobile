import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/qr_login_screen.dart';
import '../../features/folder/screens/folders_screen.dart';
import '../../features/player/screens/now_playing_screen.dart';
import '../../features/player/screens/queue_screen.dart';
import '../../features/artist/screens/artist_screen.dart';
import '../../features/album/screens/album_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../presentation/widgets/main_scaffold.dart';
import '../../core/constants/app_constants.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppConstants.homeRoute,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthRoute = state.uri.path.startsWith('/login') ||
          state.uri.path.startsWith('/qr-login');

      // If not authenticated and not on auth route, redirect to login
      if (!authProvider.isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // If authenticated and on auth route, redirect to home
      if (authProvider.isLoggedIn && isAuthRoute) {
        return AppConstants.homeRoute;
      }

      return null;
    },
    routes: [
      // Public routes (no authentication required)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/qr-login',
        name: 'qr-login',
        builder: (context, state) => const QRLoginScreen(),
      ),

      // Protected routes (authentication required)
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainScaffold(),
        routes: [
          GoRoute(
            path: AppConstants.homeRoute.substring(1), // Remove leading slash
            name: 'home',
            builder: (context, state) => const MainScaffold(),
          ),
          GoRoute(
            path: AppConstants.searchRoute.substring(1),
            name: 'search',
            builder: (context, state) => const MainScaffold(),
          ),
          GoRoute(
            path: AppConstants.libraryRoute.substring(1),
            name: 'library',
            builder: (context, state) => const MainScaffold(),
          ),
          GoRoute(
            path: AppConstants.downloadsRoute.substring(1),
            name: 'downloads',
            builder: (context, state) => const MainScaffold(),
          ),
          GoRoute(
            path: 'now-playing',
            name: 'now-playing',
            builder: (context, state) => const NowPlayingScreen(),
          ),
          GoRoute(
            path: 'queue',
            name: 'queue',
            builder: (context, state) => const QueueScreen(),
          ),
          GoRoute(
            path: 'artist/:artistHash',
            name: 'artist',
            builder: (context, state) {
              final artistHash = state.pathParameters['artistHash']!;
              return ArtistScreen(artistHash: artistHash);
            },
          ),
          GoRoute(
            path: 'album/:albumHash',
            name: 'album',
            builder: (context, state) {
              final albumHash = state.pathParameters['albumHash']!;
              return AlbumScreen(albumHash: albumHash);
            },
          ),
          GoRoute(
            path: 'folder/:folderHash',
            name: 'folder',
            builder: (context, state) {
              return FoldersScreen();
            },
          ),
          GoRoute(
            path: AppConstants.settingsRoute.substring(1),
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}
