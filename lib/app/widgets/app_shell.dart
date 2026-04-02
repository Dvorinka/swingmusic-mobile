import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/downloads_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/player_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import 'mini_player_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final library = context.read<LibraryController>();
    final offline = context.read<OfflineController>();
    Future.microtask(() async {
      await library.bootstrap();
      await offline.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(index: _index, children: _pages),
            ),
            MiniPlayerBar(
              onOpenPlayer: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const PlayerScreen()));
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              _NavButton(
                label: 'Home',
                icon: Icons.home_outlined,
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavButton(
                label: 'Search',
                icon: Icons.search,
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavButton(
                label: 'Library',
                icon: Icons.library_music,
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavButton(
                label: 'Profile',
                icon: Icons.person_outline,
                selected: false,
                onTap: () => _showProfileSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary.withValues(alpha: 0.2),
                    child: Icon(Icons.person, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Profile & Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.download, color: scheme.onSurfaceVariant),
              title: const Text('Downloads'),
              subtitle: const Text('Manage offline tracks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: scheme.onSurfaceVariant),
              title: const Text('Settings'),
              subtitle: const Text('App preferences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? scheme.primary.withValues(alpha: 0.2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 21,
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
