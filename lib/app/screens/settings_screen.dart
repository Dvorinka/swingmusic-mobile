import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/offline_controller.dart';
import '../state/session_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _qualityValues = <String>[
    '96',
    '128',
    '256',
    '320',
    '512',
    '1024',
    '1411',
    'original',
  ];

  late String _streamingQuality;
  late String _downloadQuality;
  late bool _adaptiveStreaming;
  late bool _wifiOnlyDownloads;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionController>();
    _streamingQuality = session.streamingQuality;
    _downloadQuality = session.downloadQuality;
    _adaptiveStreaming = session.adaptiveStreaming;
    _wifiOnlyDownloads = session.wifiOnlyDownloads;
  }

  Future<void> _save() async {
    final session = context.read<SessionController>();
    setState(() => _saving = true);
    await session.saveQualitySettings(
      streamingQuality: _streamingQuality,
      downloadQuality: _downloadQuality,
      adaptiveStreaming: _adaptiveStreaming,
      wifiOnlyDownloads: _wifiOnlyDownloads,
    );
    if (mounted) {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickDownloadDirectory() async {
    final session = context.read<SessionController>();
    final selected = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Offline Download Directory',
    );
    if (selected != null && selected.isNotEmpty) {
      await session.saveDownloadDirectory(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final user = session.user;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (user.isNotEmpty) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(user['username']?.toString() ?? 'User'),
            subtitle: Text('ID: ${user['id'] ?? '-'}'),
            trailing: Text(
              session.baseUrl ?? '',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
          const Divider(),
        ],
        _SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Streaming', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _streamingQuality,
                items: _qualityValues
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(
                  () => _streamingQuality = value ?? _streamingQuality,
                ),
                decoration: const InputDecoration(
                  labelText: 'Streaming Quality',
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Adaptive Streaming'),
                subtitle: const Text(
                  'Lower quality automatically on mobile data',
                ),
                value: _adaptiveStreaming,
                onChanged: (value) =>
                    setState(() => _adaptiveStreaming = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offline', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _downloadQuality,
                items: _qualityValues
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(
                  () => _downloadQuality = value ?? _downloadQuality,
                ),
                decoration: const InputDecoration(
                  labelText: 'Download Quality',
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Wi-Fi Only Downloads'),
                value: _wifiOnlyDownloads,
                onChanged: (value) =>
                    setState(() => _wifiOnlyDownloads = value),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Download Directory'),
                subtitle: Text(
                  session.downloadDirectory ?? 'App documents/offline_tracks',
                ),
                trailing: OutlinedButton(
                  onPressed: _pickDownloadDirectory,
                  child: const Text('Change'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Settings'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.read<OfflineController>().syncPending(),
          icon: const Icon(Icons.sync),
          label: const Text('Sync Pending Analytics/Favorites'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.read<LibraryController>().syncPendingData(),
          icon: const Icon(Icons.sync_problem),
          label: const Text('Run Background Sync Now'),
        ),
        const Divider(height: 30),
        OutlinedButton(onPressed: session.logout, child: const Text('Logout')),
        OutlinedButton(
          onPressed: session.clearServerConnection,
          child: const Text('Disconnect Server'),
        ),
      ],
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
