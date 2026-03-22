import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../data/services/lyrics_service.dart';
import '../../data/services/enhanced_api_service.dart';
import '../../core/constants/app_spacing.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  bool _isLoading = false;
  String? _lyrics;
  String? _error;
  final TextEditingController _lyricsController = TextEditingController();
  late LyricsService _lyricsService;

  @override
  void initState() {
    super.initState();
    // Get API service from provider context in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize lyrics service with API service from provider
    final apiService = context.read<EnhancedApiService>();
    _lyricsService = LyricsService(apiService);
    
    // Auto-load lyrics for current track
    final audioProvider = context.read<AudioProvider>();
    if (audioProvider.currentTrack != null) {
      _loadLyrics(audioProvider.currentTrack!.trackhash);
    }
  }

  @override
  void dispose() {
    _lyricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Lyrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          final currentTrack = audioProvider.currentTrack;
          
          if (currentTrack == null) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Track Info
              Container(
                padding: AppSpacing.paddingLG,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.displayTitle,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentTrack.artistNames,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (currentTrack.displayAlbum.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              currentTrack.displayAlbum,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Album Art
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: currentTrack.image.isNotEmpty
                            ? Image.network(
                                currentTrack.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                          Theme.of(context).colorScheme.primary,
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.music_note,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      size: 32,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                      Theme.of(context).colorScheme.primary,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 32,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sync Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _loadLyrics(currentTrack.trackhash),
                  icon: Icon(
                    Icons.sync,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: const Text('Sync Lyrics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Lyrics Content
              Expanded(
                child: Container(
                  padding: AppSpacing.paddingLG,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isLoading) ...[
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ] else if (_error != null) ...[
                        Container(
                          padding: AppSpacing.paddingMD,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_lyrics != null && _lyrics!.isNotEmpty) ...[
                        // Edit Mode
                        if (_isEditMode) ...[
                          _buildEditMode(context),
                        ] else ...[
                          // Display Mode
                          _buildLyricsDisplay(context),
                        ],
                      ] else ...[
                        Container(
                          padding: AppSpacing.paddingXL,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lyrics,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No lyrics available',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingXL,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No lyrics available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Play a track to see its lyrics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsDisplay(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lyrics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  // Edit/Save buttons
                  if (_isEditMode) ...[
                    IconButton(
                      onPressed: () => _saveLyrics(context),
                      icon: Icon(
                        Icons.save,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _cancelEdit(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: () => _enableEditMode(),
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          // Lyrics text
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _lyrics!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _lyricsController,
              maxLines: null,
              style: TextStyle(
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _saveLyrics(context),
            icon: Icon(
              Icons.save,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isEditMode => _lyricsController.text != _lyrics;

  void _enableEditMode() {
    _lyricsController.text = _lyrics ?? '';
    setState(() {});
  }

  void _cancelEdit() {
    _lyricsController.text = _lyrics ?? '';
    setState(() {});
  }

  void _saveLyrics(BuildContext context) async {
    final updatedLyrics = _lyricsController.text.trim();
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final currentTrack = audioProvider.currentTrack;
    
    if (currentTrack == null) return;
    
    // Capture context before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final success = await _lyricsService.saveLyrics(currentTrack.trackhash, updatedLyrics);
      
      if (success) {
        setState(() {
          _lyrics = updatedLyrics;
          _isLoading = false;
        });
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Lyrics saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to save lyrics';
        });
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to save lyrics'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error saving lyrics: $e';
      });
      
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error saving lyrics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadLyrics(String trackHash) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lyrics = await _lyricsService.getLyrics(trackHash);
      
      setState(() {
        _isLoading = false;
        _lyrics = lyrics;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load lyrics: $e';
      });
    }
  }

  // void _syncLyrics(BuildContext context) {
  //   final currentTrack = Provider.of<AudioProvider>(context, listen: false).currentTrack;
  //   if (currentTrack == null) return;
  //   
  //   _loadLyrics(context, currentTrack.trackhash);
  // }
}
