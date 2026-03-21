import 'package:flutter/material.dart';
import '../../data/models/album_model.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/themes/app_theme.dart';

class AlbumCard extends StatefulWidget {
  final AlbumModel album;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.circularLG,
        ),
        color: _isHovered ? AppTheme.gray5 : null, // Match web client hover background
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppBorderRadius.circularLG,
            child: SizedBox(
              width: widget.width ?? 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album Art
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: AppBorderRadius.circularLG,
                    ),
                    child: ClipRRect(
                      borderRadius: AppBorderRadius.circularLG,
                      child: Stack(
                        children: [
                          if (widget.album.image.isNotEmpty)
                            Image.network(
                              widget.album.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAlbumArt(context);
                              },
                            )
                          else
                            _buildDefaultAlbumArt(context),
                          // Gradient overlay matching web client
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: _isHovered ? 1.0 : 0.0,
                              duration: AppSpacing.transitionNormal, // 0.25s ease from web client
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.6),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.8],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Play button overlay matching web client PlayBtn.vue exactly
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: AnimatedContainer(
                              duration: AppSpacing.transitionNormal,
                              transform: Matrix4.translationValues(
                                0, 
                                _isHovered ? 0 : 16, // translateY(1rem) = 16px
                                0,
                              ),
                              child: AnimatedOpacity(
                                opacity: _isHovered ? 1.0 : 0.0,
                                duration: AppSpacing.transitionNormal,
                                child: Container(
                                  width: 40, // 2.5rem = 40px
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkBlue, // $darkblue exact match
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      // Match web client shadow effects
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: AppTheme.onPrimaryColor,
                                    size: 28, // 1.75rem = 28px
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Album Info
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.album.displayTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15, // 0.95rem from web client
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.album.artistNames,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w700,
                          fontSize: 13, // 0.8rem from web client
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.album.year.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.album.year,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        size: 48,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
