import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'enhanced_api_service.dart';

class WaveformService {
  final EnhancedApiService _apiService;
  late Dio _dio;

  WaveformService(this._apiService) {
    _dio = Dio(BaseOptions(
      baseUrl: _apiService.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  Future<List<double>> generateWaveformData(String trackHash) async {
    try {
      // Get waveform data from API
      final response = await _dio.get('/waveform/$trackHash');

      if (response.statusCode == 200 && response.data['waveform'] != null) {
        final List<dynamic> waveformList = response.data['waveform'];
        return waveformList.map((value) => (value as num).toDouble()).toList();
      } else {
        // Generate mock waveform data if API doesn't have it
        return _generateMockWaveformData();
      }
    } catch (e) {
      // Generate mock waveform data on error
      return _generateMockWaveformData();
    }
  }

  List<double> _generateMockWaveformData() {
    // Generate realistic-looking waveform data
    final random = List<double>.generate(100, (index) {
      final base = 0.3;
      final variation = (index % 10) / 10.0;
      final noise = (index % 7) / 20.0;
      return base + variation + noise;
    });

    // Normalize to 0-1 range
    final max = random.reduce((a, b) => a > b ? a : b);
    return random.map((value) => value / max).toList();
  }

  Future<Map<String, dynamic>> getAudioAnalysis(String trackHash) async {
    try {
      final response = await _dio.get('/analysis/$trackHash');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>? ?? {};
      } else {
        return _getMockAnalysisData();
      }
    } catch (e) {
      return _getMockAnalysisData();
    }
  }

  Map<String, dynamic> _getMockAnalysisData() {
    return {
      'tempo': 120.0,
      'key': 'C',
      'mode': 'major',
      'energy': 0.7,
      'danceability': 0.8,
      'valence': 0.6,
      'acousticness': 0.3,
      'instrumentalness': 0.1,
      'speechiness': 0.05,
      'loudness': -8.5,
      'duration': 225.0,
      'segments': [
        {'start': 0.0, 'end': 30.0, 'type': 'intro'},
        {'start': 30.0, 'end': 195.0, 'type': 'verse'},
        {'start': 195.0, 'end': 225.0, 'type': 'outro'},
      ],
    };
  }
}

class WaveformVisualizer extends StatefulWidget {
  final String trackHash;
  final Duration duration;
  final Duration currentPosition;
  final Function(Duration)? onSeek;
  final Color? color;
  final double height;
  final bool showProgress;

  const WaveformVisualizer({
    super.key,
    required this.trackHash,
    required this.duration,
    required this.currentPosition,
    this.onSeek,
    this.color,
    this.height = 60.0,
    this.showProgress = true,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer> {
  final WaveformService _waveformService =
      WaveformService(EnhancedApiService());
  List<double> _waveformData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWaveform();
  }

  Future<void> _loadWaveform() async {
    try {
      final data =
          await _waveformService.generateWaveformData(widget.trackHash);
      if (mounted) {
        setState(() {
          _waveformData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Waveform unavailable',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        if (widget.onSeek != null) {
          final tapPosition = details.localPosition.dx;
          final progress = tapPosition / MediaQuery.of(context).size.width;
          final seekPosition = Duration(
            milliseconds: (widget.duration.inMilliseconds * progress).round(),
          );
          widget.onSeek!(seekPosition);
        }
      },
      child: SizedBox(
        height: widget.height,
        child: CustomPaint(
          painter: WaveformPainter(
            data: _waveformData,
            progress: widget.duration.inMilliseconds > 0
                ? widget.currentPosition.inMilliseconds /
                    widget.duration.inMilliseconds
                : 0.0,
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class AdvancedWaveformVisualizer extends StatefulWidget {
  final String trackHash;
  final Duration duration;
  final Duration currentPosition;
  final Function(Duration)? onSeek;
  final Map<String, dynamic>? analysisData;
  final Color? color;
  final double height;

  const AdvancedWaveformVisualizer({
    super.key,
    required this.trackHash,
    required this.duration,
    required this.currentPosition,
    this.onSeek,
    this.analysisData,
    this.color,
    this.height = 120.0,
  });

  @override
  State<AdvancedWaveformVisualizer> createState() =>
      _AdvancedWaveformVisualizerState();
}

class _AdvancedWaveformVisualizerState
    extends State<AdvancedWaveformVisualizer> {
  final WaveformService _waveformService =
      WaveformService(EnhancedApiService());
  List<double> _waveformData = [];
  Map<String, dynamic> _analysisData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final waveformFuture =
          _waveformService.generateWaveformData(widget.trackHash);
      final analysisFuture =
          _waveformService.getAudioAnalysis(widget.trackHash);

      final results = await Future.wait([waveformFuture, analysisFuture]);

      if (mounted) {
        setState(() {
          _waveformData = results[0] as List<double>;
          _analysisData = results[1] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Advanced waveform unavailable',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Main waveform
        SizedBox(
          height: widget.height * 0.7,
          child: GestureDetector(
            onTapUp: (details) {
              if (widget.onSeek != null) {
                final tapPosition = details.localPosition.dx;
                final containerWidth = MediaQuery.of(context).size.width;
                final progress = tapPosition / containerWidth;
                final seekPosition = Duration(
                  milliseconds:
                      (widget.duration.inMilliseconds * progress).round(),
                );
                widget.onSeek!(seekPosition);
              }
            },
            child: CustomPaint(
              painter: WaveformPainter(
                data: _waveformData,
                progress: widget.duration.inMilliseconds > 0
                    ? widget.currentPosition.inMilliseconds /
                        widget.duration.inMilliseconds
                    : 0.0,
                color: widget.color ?? Theme.of(context).colorScheme.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),

        // Analysis info
        SizedBox(
          height: widget.height * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnalysisItem(
                  'BPM', '${_analysisData['tempo']?.toInt() ?? 0}'),
              _buildAnalysisItem('Key', _analysisData['key'] ?? 'Unknown'),
              _buildAnalysisItem('Energy',
                  '${((_analysisData['energy'] ?? 0.0) * 100).toInt()}%'),
              _buildAnalysisItem('Dance',
                  '${((_analysisData['danceability'] ?? 0.0) * 100).toInt()}%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final Color color;
  final Color backgroundColor;

  WaveformPainter({
    required this.data,
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / data.length;
    final centerY = size.height / 2;

    for (int i = 0; i < data.length; i++) {
      final barHeight = data[i] * centerY * 0.8;
      final x = i * barWidth + barWidth / 2;

      // Determine if this bar should be highlighted
      final isPlayed = i / data.length <= progress;

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        isPlayed ? progressPaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
