import 'package:flutter/material.dart';
import '../../../data/services/settings_service.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../core/constants/app_spacing.dart';

class AdvancedAudioScreen extends StatefulWidget {
  const AdvancedAudioScreen({super.key});

  @override
  State<AdvancedAudioScreen> createState() => _AdvancedAudioScreenState();
}

class _AdvancedAudioScreenState extends State<AdvancedAudioScreen> {
  late final SettingsService _settingsService;
  
  // EQ Settings
  List<double> _eqBands = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  bool _eqEnabled = false;
  String _eqPreset = 'flat';
  
  // Audio Effects
  bool _bassBoostEnabled = false;
  double _bassBoostLevel = 0.0;
  bool _virtualizerEnabled = false;
  double _virtualizerLevel = 0.0;
  bool _reverbEnabled = false;
  String _reverbPreset = 'none';
  
  // Advanced Settings
  bool _loudnessEnhancementEnabled = false;
  double _loudnessGain = 0.0;
  bool _dynamicRangeCompressionEnabled = false;
  double _compressionRatio = 1.0;
  bool _stereoWideningEnabled = false;
  double _stereoWidth = 1.0;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService(EnhancedApiService());
    _loadAudioSettings();
  }

  Future<void> _loadAudioSettings() async {
    final settings = _settingsService.currentSettings;
    
    setState(() {
      // Load EQ settings
      _eqEnabled = settings.useCrossfade; // Using existing setting as placeholder
      _eqPreset = 'flat';
      
      // Load audio effects
      _bassBoostEnabled = false;
      _virtualizerEnabled = false;
      _reverbEnabled = false;
      
      // Load advanced settings
      _loudnessEnhancementEnabled = false;
      _dynamicRangeCompressionEnabled = false;
      _stereoWideningEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Audio'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEqualizerSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildAudioEffectsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildAdvancedSettingsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildPresetsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEqualizerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.equalizer,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Equalizer',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Switch(
                  value: _eqEnabled,
                  onChanged: (value) {
                    setState(() {
                      _eqEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_eqEnabled) ...[
              _buildEQBands(),
              const SizedBox(height: AppSpacing.md),
              _buildEQPresets(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEQBands() {
    const frequencies = ['32', '64', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];
    
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(10, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${frequencies[index]}Hz',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                width: 30,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: _eqBands[index],
                    min: -12.0,
                    max: 12.0,
                    divisions: 24,
                    onChanged: (value) {
                      setState(() {
                        _eqBands[index] = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),
              ),
              Text(
                '${_eqBands[index].round()}dB',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEQPresets() {
    final presets = ['flat', 'rock', 'pop', 'jazz', 'classical', 'electronic', 'bass'];
    
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: presets.map((preset) {
        return FilterChip(
          label: Text(preset.toUpperCase()),
          selected: _eqPreset == preset,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _eqPreset = preset;
                _applyEQPreset(preset);
              });
              _saveSettings();
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildAudioEffectsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Audio Effects',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBassBoostControl(),
            const SizedBox(height: AppSpacing.md),
            _buildVirtualizerControl(),
            const SizedBox(height: AppSpacing.md),
            _buildReverbControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildBassBoostControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bass Boost',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Switch(
              value: _bassBoostEnabled,
              onChanged: (value) {
                setState(() {
                  _bassBoostEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
        if (_bassBoostEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _bassBoostLevel,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(_bassBoostLevel * 100).round()}%',
            onChanged: (value) {
              setState(() {
                _bassBoostLevel = value;
              });
              _saveSettings();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildVirtualizerControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '3D Virtualizer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Switch(
              value: _virtualizerEnabled,
              onChanged: (value) {
                setState(() {
                  _virtualizerEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
        if (_virtualizerEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _virtualizerLevel,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(_virtualizerLevel * 100).round()}%',
            onChanged: (value) {
              setState(() {
                _virtualizerLevel = value;
              });
              _saveSettings();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReverbControl() {
    final reverbPresets = ['none', 'smallroom', 'mediumroom', 'largeroom', 'hall', 'plate'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reverb',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Switch(
              value: _reverbEnabled,
              onChanged: (value) {
                setState(() {
                  _reverbEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
        if (_reverbEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _reverbPreset,
            decoration: const InputDecoration(
              labelText: 'Reverb Type',
              border: OutlineInputBorder(),
            ),
            items: reverbPresets.map((preset) {
              return DropdownMenuItem(
                value: preset,
                child: Text(preset.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _reverbPreset = value;
                });
                _saveSettings();
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Advanced Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLoudnessEnhancement(),
            const SizedBox(height: AppSpacing.md),
            _buildDynamicRangeCompression(),
            const SizedBox(height: AppSpacing.md),
            _buildStereoWidening(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoudnessEnhancement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loudness Enhancement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Switch(
              value: _loudnessEnhancementEnabled,
              onChanged: (value) {
                setState(() {
                  _loudnessEnhancementEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
        if (_loudnessEnhancementEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _loudnessGain,
            min: 0.0,
            max: 20.0,
            divisions: 20,
            label: '${_loudnessGain.round()}dB',
            onChanged: (value) {
              setState(() {
                _loudnessGain = value;
              });
              _saveSettings();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDynamicRangeCompression() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dynamic Range Compression',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Switch(
              value: _dynamicRangeCompressionEnabled,
              onChanged: (value) {
                setState(() {
                  _dynamicRangeCompressionEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
        if (_dynamicRangeCompressionEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _compressionRatio,
            min: 1.0,
            max: 10.0,
            divisions: 18,
            label: '${_compressionRatio.toStringAsFixed(1)}:1',
            onChanged: (value) {
              setState(() {
                _compressionRatio = value;
              });
              _saveSettings();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildStereoWidening() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stereo Widening',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Switch(
              value: _stereoWideningEnabled,
              onChanged: (value) {
                setState(() {
                  _stereoWideningEnabled = value;
                });
                _saveSettings();
              },
            ),
          ],
        ),
        if (_stereoWideningEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _stereoWidth,
            min: 0.0,
            max: 2.0,
            divisions: 20,
            label: '${_stereoWidth.toStringAsFixed(1)}x',
            onChanged: (value) {
              setState(() {
                _stereoWidth = value;
              });
              _saveSettings();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPresetsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Audio Presets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _AudioPresetButton(
                  label: 'Normal',
                  onTap: _applyNormalPreset,
                ),
                _AudioPresetButton(
                  label: 'Bass Boost',
                  onTap: _applyBassBoostPreset,
                ),
                _AudioPresetButton(
                  label: 'Vocal',
                  onTap: _applyVocalPreset,
                ),
                _AudioPresetButton(
                  label: 'Live',
                  onTap: _applyLivePreset,
                ),
                _AudioPresetButton(
                  label: 'Party',
                  onTap: _applyPartyPreset,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyEQPreset(String preset) {
    switch (preset) {
      case 'flat':
        _eqBands = List.filled(10, 0.0);
        break;
      case 'rock':
        _eqBands = [4, 3, 0, -1, -2, -1, 1, 3, 4, 4].map((e) => e.toDouble()).toList();
        break;
      case 'pop':
        _eqBands = [-1, 2, 4, 4, 2, 0, -1, -1, -1, -1].map((e) => e.toDouble()).toList();
        break;
      case 'jazz':
        _eqBands = [3, 2, 1, 0, -1, -1, 0, 1, 2, 3].map((e) => e.toDouble()).toList();
        break;
      case 'classical':
        _eqBands = [0, 0, 0, 0, 0, 0, -1, -1, -1, -2].map((e) => e.toDouble()).toList();
        break;
      case 'electronic':
        _eqBands = [4, 3, 0, -2, -1, 1, 3, 4, 4, 5].map((e) => e.toDouble()).toList();
        break;
      case 'bass':
        _eqBands = [6, 5, 4, 2, 0, -1, -1, 0, 1, 2].map((e) => e.toDouble()).toList();
        break;
    }
  }

  void _applyNormalPreset() {
    setState(() {
      _eqEnabled = false;
      _bassBoostEnabled = false;
      _virtualizerEnabled = false;
      _reverbEnabled = false;
      _loudnessEnhancementEnabled = false;
      _dynamicRangeCompressionEnabled = false;
      _stereoWideningEnabled = false;
    });
    _saveSettings();
  }

  void _applyBassBoostPreset() {
    setState(() {
      _eqEnabled = true;
      _eqPreset = 'bass';
      _applyEQPreset('bass');
      _bassBoostEnabled = true;
      _bassBoostLevel = 0.7;
      _virtualizerEnabled = false;
      _reverbEnabled = false;
    });
    _saveSettings();
  }

  void _applyVocalPreset() {
    setState(() {
      _eqEnabled = true;
      _eqPreset = 'pop';
      _applyEQPreset('pop');
      _bassBoostEnabled = false;
      _virtualizerEnabled = true;
      _virtualizerLevel = 0.3;
      _reverbEnabled = false;
      _stereoWideningEnabled = true;
      _stereoWidth = 1.5;
    });
    _saveSettings();
  }

  void _applyLivePreset() {
    setState(() {
      _eqEnabled = true;
      _eqPreset = 'rock';
      _applyEQPreset('rock');
      _bassBoostEnabled = true;
      _bassBoostLevel = 0.5;
      _virtualizerEnabled = true;
      _virtualizerLevel = 0.8;
      _reverbEnabled = true;
      _reverbPreset = 'hall';
      _loudnessEnhancementEnabled = true;
      _loudnessGain = 5.0;
    });
    _saveSettings();
  }

  void _applyPartyPreset() {
    setState(() {
      _eqEnabled = true;
      _eqPreset = 'electronic';
      _applyEQPreset('electronic');
      _bassBoostEnabled = true;
      _bassBoostLevel = 0.9;
      _virtualizerEnabled = true;
      _virtualizerLevel = 1.0;
      _reverbEnabled = true;
      _reverbPreset = 'largeroom';
      _loudnessEnhancementEnabled = true;
      _loudnessGain = 8.0;
      _stereoWideningEnabled = true;
      _stereoWidth = 2.0;
    });
    _saveSettings();
  }

  void _saveSettings() {
    // Save settings to SettingsService
    // This would be implemented to persist all audio settings
  }
}

class _AudioPresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AudioPresetButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(label),
    );
  }
}
