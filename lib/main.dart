import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/screens/root_gate_screen.dart';
import 'app/services/local_cache_service.dart';
import 'app/services/offline_manager.dart';
import 'app/services/swing_api_client.dart';
import 'app/state/library_controller.dart';
import 'app/state/offline_controller.dart';
import 'app/state/player_controller.dart';
import 'app/state/session_controller.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final apiClient = SwingApiClient();
  runApp(SwingMusicMobileApp(apiClient: apiClient));
}

class SwingMusicMobileApp extends StatelessWidget {
  const SwingMusicMobileApp({super.key, required this.apiClient});

  final SwingApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SwingApiClient>.value(value: apiClient),
        ChangeNotifierProvider<SessionController>(
          create: (context) {
            final session = SessionController(apiClient: apiClient);
            unawaited(session.initialize());
            return session;
          },
        ),
        Provider<LocalCacheService>(create: (_) => LocalCacheService()),
        ProxyProvider3<SwingApiClient, SessionController, LocalCacheService,
            OfflineManager>(
          update: (context, api, session, cache, previous) =>
              OfflineManager(api: api, session: session, cache: cache),
        ),
        ChangeNotifierProvider<LibraryController>(
          create: (context) => LibraryController(
            api: context.read<SwingApiClient>(),
            session: context.read<SessionController>(),
            offline: context.read<OfflineManager>(),
          ),
        ),
        ChangeNotifierProvider<OfflineController>(
          create: (context) =>
              OfflineController(offline: context.read<OfflineManager>()),
        ),
        ChangeNotifierProvider<PlayerController>(
          create: (context) => PlayerController(
            api: context.read<SwingApiClient>(),
            session: context.read<SessionController>(),
            offline: context.read<OfflineManager>(),
            cache: context.read<LocalCacheService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SwingMusic Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const RootGateScreen(),
      ),
    );
  }
}
