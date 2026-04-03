import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return const SizedBox.shrink();
        }

        return NavigationBar(
          height: 65,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: AppTheme.highlightBlue.withOpacity(0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.download_outlined),
              selectedIcon: Icon(Icons.download),
              label: 'Downloads',
            ),
          ],
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go(AppConstants.homeRoute);
                break;
              case 1:
                context.go(AppConstants.searchRoute);
                break;
              case 2:
                context.go(AppConstants.libraryRoute);
                break;
              case 3:
                context.go(AppConstants.downloadsRoute);
                break;
            }
          },
        );
      },
    );
  }
}

class BottomNavItem {
  static const home = BottomNavItem._(
    0,
    'Home',
    Icons.home_outlined,
    Icons.home,
  );
  static const search = BottomNavItem._(
    1,
    'Search',
    Icons.search_outlined,
    Icons.search,
  );
  static const library = BottomNavItem._(
    2,
    'Library',
    Icons.folder_outlined,
    Icons.folder,
  );
  static const downloads = BottomNavItem._(
    3,
    'Downloads',
    Icons.download_outlined,
    Icons.download,
  );

  const BottomNavItem._(this.index, this.label, this.icon, this.selectedIcon);

  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
