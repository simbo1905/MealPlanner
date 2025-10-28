import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Shared helpers for meal card sizing across portrait and landscape layouts.
///
/// Dimension strategy is based on the validation scripts:
/// - `specs/calc_landscape_cards.dart`
/// - `meal_planner/lib/demo/landscape_grid_calculator.dart`
///
/// Key goals:
/// 1. Respect iOS HIG minimum touch target of 44×44pt.
/// 2. Maintain ~2.5–3.5 cards visible in landscape carousel by clamping width.
/// 3. Scale row heights by device class (phones vs tablets).
///
/// This helper centralizes constants so MealCard, AddMealCard, DayRow, and any
/// future landscape grid can derive consistent sizes.
/// Centralized sizing utilities for meal planner cards.
class CardDimensions {
  CardDimensions._();

  // Aspect ratios explored during validation. We currently ship the 1.6:1 ratio
  // for phones and allow tablets to expand up to the 1.78:1 cap when width permits.
  static const double aspectRatioPhone = 1.6;
  static const double aspectRatioTabletCap = 1.78;

  // Row height tiers determined from specs/calc_landscape_cards.dart.
  static const double _rowHeightPhoneSmall = 96;
  static const double _rowHeightPhoneLarge = 108;
  static const double _rowHeightTablet = 132;

  // Carousel layout paddings.
  static const double leftRailWidth = 56;
  static const double listPaddingLeft = 8;
  static const double listPaddingRight = 16;
  static const double interCardGapDefault = 12;
  static const double interCardGapNarrow = 8;

  /// Returns row height for the day carousel based on device width.
  static double rowHeightFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).shortestSide;
    if (width >= 900) {
      return _rowHeightTablet;
    }
    if (width >= 400) {
      return _rowHeightPhoneLarge;
    }
    return _rowHeightPhoneSmall;
  }

  /// Computes the preferred card width given a row height and device class.
  /// Width is rounded to the nearest whole point to avoid sub-pixel blur.
  static double cardWidthFor({
    required BuildContext context,
    required double rowHeight,
  }) {
    final width = MediaQuery.sizeOf(context).shortestSide;
    final isTablet = width >= 900;
    final ratio = isTablet ? aspectRatioTabletCap : aspectRatioPhone;
    final computed = rowHeight * ratio;
    final capped = isTablet ? math.min(computed, 200) : math.min(computed, 176);
    return capped.roundToDouble();
  }

  /// Width used when showing the dragged feedback card (same as main width).
  static double dragFeedbackWidth({
    required BuildContext context,
    required double rowHeight,
  }) {
    return cardWidthFor(context: context, rowHeight: rowHeight);
  }

  /// Returns the inter-card gap, shrinking slightly for very narrow phones.
  static double interCardGap(BuildContext context) {
    final width = MediaQuery.sizeOf(context).shortestSide;
    if (width < 360) {
      return interCardGapNarrow;
    }
    return interCardGapDefault;
  }

  /// Horizontal padding applied to the carousel list.
  static EdgeInsets carouselPadding(BuildContext context) {
    return const EdgeInsets.only(left: listPaddingLeft, right: listPaddingRight);
  }
}
