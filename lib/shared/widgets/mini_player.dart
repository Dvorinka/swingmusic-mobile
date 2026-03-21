import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/audio_provider.dart';
import '../../core/constants/app_spacing.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  double _dragStartX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleHorizontalDrag(DragUpdateDetails details) async {
    if (!_isDragging) {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
    }

    final deltaX = details.globalPosition.dx - _dragStartX;
    final normalizedDelta = deltaX / MediaQuery.of(context).size.width;

    // Clamp the animation value between -0.3 and 0.3
    final clampedValue = normalizedDelta.clamp(-0.3, 0.3);
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(clampedValue, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond.dx;
    
    // Swipe threshold
    const swipeThreshold = 100.0;
    
    if (velocity > swipeThreshold) {
      // Swiped right - previous track
      _slideToPosition(-0.3, () {
        context.read<AudioProvider>().playPrevious();
      });
    } else if (velocity < -swipeThreshold) {
      // Swiped left - next track
      _slideToPosition(0.3, () {
        context.read<AudioProvider>().playNext();
      });
    } else {
      // Reset to center
      _slideToPosition(0, null);
    }
  }

  void _slideToPosition(double position, VoidCallback? onComplete) {
    _slideAnimation = Tween<Offset>(
      begin: Offset(position, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward().then((_) {
      if (onComplete != null) {
        onComplete();
      }
      // Reset animation
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      ));
      _slideController.reset();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final currentTrack = audioProvider.currentTrack;
        
        if (currentTrack == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: audioProvider.progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 2,
              ),
              
              // Mini player content
              GestureDetector(
                onTap: () => _navigateToPlayer(context),
                onHorizontalDragUpdate: _handleHorizontalDrag,
                onHorizontalDragEnd: _handleDragEnd,
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _slideAnimation.value * MediaQuery.of(context).size.width,
                      child: Container(
                        padding: AppSpacing.paddingSM,
                        child: Row(
                          children: [
                            // Album art
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: currentTrack.image.isNotEmpty
                                    ? Image.network(
                                        currentTrack.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildDefaultAlbumArt(context);
                                        },
                                      )
                                    : _buildDefaultAlbumArt(context),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Track info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentTrack.displayTitle,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentTrack.artistNames,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Play/pause button
                            GestureDetector(
                              onTap: () {
                                if (audioProvider.isPlaying) {
                                  audioProvider.pause();
                                } else {
                                  audioProvider.play();
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: audioProvider.isBuffering
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        audioProvider.isPlaying 
                                            ? Icons.pause 
                                            : Icons.play_arrow,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultAlbumArt(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Icon(
        Icons.album,
        size: 24,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  void _navigateToPlayer(BuildContext context) {
    Navigator.of(context).pushNamed('/player');
  }
}
