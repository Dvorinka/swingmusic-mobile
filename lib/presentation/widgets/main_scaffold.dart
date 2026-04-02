import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../features/player/providers/media_controller_provider.dart';
import '../../features/widgets/home_screen_simple.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/folder/screens/folders_screen.dart';
import '../navigation/bottom_navigation.dart';
import '../widgets/mini_player.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final mediaControllerProvider = context.watch<MediaControllerProvider>();
    final location = GoRouterState.of(context).uri.path;

    // Routes where bottom nav should be hidden (matching Android app)
    const hideBottomNavRoutes = [
      '/login',
      '/qr-login',
      '/now-playing',
      '/queue',
      '/lyrics',
    ];

    final showBottomNav =
        !hideBottomNavRoutes.contains(location) && authProvider.isLoggedIn;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(context, location),
      ),
      bottomNavigationBar: showBottomNav
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show mini player when bottom nav is visible (matching Android)
                if (mediaControllerProvider.currentTrack != null)
                  const MiniPlayer(),
                const BottomNavigation(),
              ],
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, String location) {
    switch (location) {
      case '/':
      case '/home':
        return const HomeScreenSimple();
      case '/search':
        return const SearchScreen();
      case '/library':
        return const FoldersScreen();
      default:
        // For nested routes, this will be handled by the router
        return const HomeScreenSimple();
    }
  }
}
