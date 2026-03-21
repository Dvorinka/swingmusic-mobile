import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/session_controller.dart';
import '../widgets/app_shell.dart';
import 'connect_server_screen.dart';
import 'login_screen.dart';
import 'setup_required_screen.dart';

class RootGateScreen extends StatelessWidget {
  const RootGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, session, _) {
        if (session.initializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!session.hasServer) {
          return const ConnectServerScreen();
        }

        if (!session.setupComplete) {
          return const SetupRequiredScreen();
        }

        if (!session.isAuthenticated) {
          return const LoginScreen();
        }

        return const AppShell();
      },
    );
  }
}
