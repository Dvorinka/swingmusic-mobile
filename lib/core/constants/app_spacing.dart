import 'package:flutter/material.dart';

/// Unified spacing constants matching web client design tokens exactly
class AppSpacing {
  // Base spacing unit (4px) matching web client
  static const double xs = 4.0; // 0.25rem = $smallest
  static const double sm = 8.0; // 0.5rem = $smaller
  static const double md = 12.0; // 0.75rem
  static const double lg = 16.0; // 1rem = $small
  static const double xl = 20.0; // 1.25rem
  static const double xxl = 24.0; // 1.5rem = $medium
  static const double xxxl = 32.0; // 2rem = $large
  static const double larger = 32.0; // $larger = 2rem

  // Web client exact sizing from _variables.scss
  static const double bannerHeight = 288.0; // $banner-height: 18rem
  static const double songItemHeight = 64.0; // $song-item-height: 4rem
  static const double contentPaddingBottom =
      32.0; // $content-padding-bottom: 2rem
  static const double navHeight = 72.0; // $navheight: 4.5rem
  static const double cardWidth = 172.0; // $cardwidth: 10.75rem
  static const double maxPadLeft = 80.0; // $maxpadleft: 5rem
  static const double padBottom = 64.0; // $padbottom: 4rem

  // Web client specific component sizing
  static const double buttonHeight = 36.0; // 2.25rem from basic.scss
  static const double buttonMoreWidth = 40.0; // 2.5rem from basic.scss
  static const double progressBarHeight = 4.8; // 0.3rem from ProgressBar.scss
  static const double searchHeight = 36.0; // 2.25rem from inputs.scss
  static const double tabHeight = 32.0; // 2rem from search-tabheaders.scss
  static const double stateSize = 32.0; // 2rem from state.scss
  static const double explicitIconWidth = 14.4; // 0.9rem from basic.scss
  static const double spinnerSize = 20.0; // 1.25rem from basic.scss

  // Grid spacing matching web client album-grid.scss
  static const double gridPadding = 16.0; // 1rem padding
  static const double gridGap = 16.0; // 1rem gap
  static const double gridGapVertical = 32.0; // 2rem vertical gap
  static const double gridMinWidth = 144.0; // 9rem min-width

  // Consistent padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Consistent margins
  static const EdgeInsets marginXS = EdgeInsets.all(xs);
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);
  static const EdgeInsets marginXL = EdgeInsets.all(xl);

  // Horizontal spacing
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical spacing
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // Card spacing matching web client album card
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardMargin = EdgeInsets.all(sm);

  // List spacing
  static const EdgeInsets listPadding = EdgeInsets.symmetric(vertical: sm);
  static const double listItemSpacing = sm;

  // Section spacing
  static const double sectionSpacing = xxl;
  static const EdgeInsets sectionPadding = EdgeInsets.all(lg);

  // Button spacing matching web client
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // Form spacing
  static const double formFieldSpacing = md;
  static const EdgeInsets formPadding = EdgeInsets.all(lg);

  // Animation and timing constants matching web client
  static const Duration transitionFast =
      Duration(milliseconds: 200); // 0.2s ease-out
  static const Duration transitionNormal =
      Duration(milliseconds: 250); // 0.25s ease
  static const Duration transitionSlow =
      Duration(milliseconds: 300); // 0.3s ease
  static const Duration spinnerDuration =
      Duration(milliseconds: 450); // 0.45s linear infinite
  static const Duration pulseDuration =
      Duration(milliseconds: 600); // 0.6s infinite
  static const Duration pulseDelay = Duration(milliseconds: 120); // $i * 0.12s

  // Z-index values matching web client
  static const int dimmerZIndex = 1001; // From Global/index.scss
}

/// Unified border radius constants matching web client exactly
class AppBorderRadius {
  static const double xs = 4.0; // 0.25rem
  static const double sm = 8.0; // 0.5rem = $small
  static const double md = 12.0; // 0.75rem
  static const double lg = 16.0; // 1rem = $rounded
  static const double xl = 20.0; // 1.25rem = $rounded-lg
  static const double xxl = 24.0; // 1.5rem = $rounded-md
  static const double circular = 160.0; // 10rem = .circular
  static const double full = 9999.0;

  // Web client specific border radius values
  static const double progressBar = 5.0; // 5px from ProgressBar.scss
  static const double input = 3.0; // 3px from inputs.scss
  static const double scrollbar = 16.0; // 16px from scrollbars.scss
  static const double searchInput = 3.0; // 3px from inputs.scss
  static const double duration = 8.0; // 0.5rem from BottomBar.scss
  static const double dragImage = 4.0; // $smaller from basic.scss
  static const double badge = 4.0; // $smaller from basic.scss
  static const double explicitIcon = 4.0; // $smaller from basic.scss

  static BorderRadius circularXS = BorderRadius.circular(xs);
  static BorderRadius circularSM = BorderRadius.circular(sm);
  static BorderRadius circularMD = BorderRadius.circular(md);
  static BorderRadius circularLG = BorderRadius.circular(lg);
  static BorderRadius circularXL = BorderRadius.circular(xl);
  static BorderRadius circularXXL = BorderRadius.circular(xxl);
  static BorderRadius circularFull = BorderRadius.circular(full);
  static BorderRadius circularCircular = BorderRadius.circular(circular);
}
