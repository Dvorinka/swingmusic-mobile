import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/qr/mobile_scanner_screen.dart';
import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import '../state/session_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pairServerController = TextEditingController();
  final _pairCodeController = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionController>();
    _pairServerController.text = session.baseUrl ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pairServerController.dispose();
    _pairCodeController.dispose();
    super.dispose();
  }

  Future<void> _onLoginWithPassword() async {
    final session = context.read<SessionController>();
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await session.loginWithCredentials(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      await _afterSuccessfulLogin();
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _onPairLogin() async {
    final session = context.read<SessionController>();
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await session.loginWithPairCode(
        serverUrl: _pairServerController.text.trim(),
        code: _pairCodeController.text.trim(),
      );
      await _afterSuccessfulLogin();
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _scanQrAndLogin() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const MobileScannerScreen()),
    );

    if (!mounted || result == null || result.trim().isEmpty) {
      return;
    }

    final session = context.read<SessionController>();
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final parsed = session.parseQrPayload(result);
      _pairServerController.text = parsed.serverUrl;
      _pairCodeController.text = parsed.code;
      await session.loginWithPairCode(
        serverUrl: parsed.serverUrl,
        code: parsed.code,
      );
      await _afterSuccessfulLogin();
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _afterSuccessfulLogin() async {
    final library = context.read<LibraryController>();
    final offline = context.read<OfflineController>();
    await library.bootstrap();
    await offline.load();
    await offline.syncPending();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in with account credentials or pair using a QR code from web UI.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _busy ? null : _onLoginWithPassword,
                            child: const Text('Login with Password'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _pairServerController,
                          decoration: const InputDecoration(
                            labelText: 'Server URL',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pairCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Pair Code',
                            hintText: 'e.g. A1B2C3',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: _busy ? null : _onPairLogin,
                                child: const Text('Pair Login'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _busy ? null : _scanQrAndLogin,
                                icon: const Icon(Icons.qr_code_scanner),
                                label: const Text('Scan QR'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: scheme.error)),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy ? null : session.clearServerConnection,
                    child: const Text('Change Server URL'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
