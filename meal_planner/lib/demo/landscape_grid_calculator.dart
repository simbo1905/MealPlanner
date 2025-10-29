/// Landscape Week Grid Layout Calculator
// ignore_for_file: avoid_print
/// 
/// Calculates optimal meal card dimensions for the landscape week view
/// across all iOS devices from iPhone SE to iPad Pro 12.9"
///
/// Requirements:
/// - 7 columns (Mon-Sun)
/// - 5 rows (3 meals + 1 overflow "..." + 1 "+" add card)
/// - Compact header with week navigation
/// - iOS HIG compliance: 44pt minimum touch targets, safe areas
///
/// Run: dart run lib/demo/landscape_grid_calculator.dart
library;

import 'dart:math';

void main() {
  print('═' * 80);
  print('LANDSCAPE WEEK GRID LAYOUT CALCULATOR');
  print('═' * 80);
  print('');

  final calculator = LandscapeGridCalculator();
  calculator.analyzeAllDevices();
  calculator.printRecommendations();
}

class DeviceSpec {
  final String name;
  final double logicalWidth; // landscape width (points)
  final double logicalHeight; // landscape height (points)
  final double safeAreaTop;
  final double safeAreaBottom;
  final double safeAreaLeading; // left in landscape
  final double safeAreaTrailing; // right in landscape

  DeviceSpec({
    required this.name,
    required this.logicalWidth,
    required this.logicalHeight,
    this.safeAreaTop = 0,
    this.safeAreaBottom = 0,
    this.safeAreaLeading = 0,
    this.safeAreaTrailing = 0,
  });

  double get usableWidth => logicalWidth - safeAreaLeading - safeAreaTrailing;
  double get usableHeight => logicalHeight - safeAreaTop - safeAreaBottom;
}

class LayoutConstants {
  // iOS HIG requirements
  static const double minTouchTarget = 44.0;
  static const double recommendedTouchTarget = 48.0;

  // Grid structure
  static const int columnCount = 7; // Mon-Sun
  static const int rowCount = 5; // 3 meals + overflow + add

  // Header (must meet iOS HIG 44pt minimum touch target)
  static const double headerHeightMin = 44.0; // iOS HIG: min 44pt for touch targets
  static const double headerHeightCompact = 44.0;
  static const double headerHeightComfortable = 56.0;

  // Spacing & margins
  static const double screenMarginMin = 4.0;
  static const double screenMarginComfortable = 12.0;
  static const double cardSpacingMin = 2.0;
  static const double cardSpacingComfortable = 6.0;
  static const double rowSpacingMin = 2.0;
  static const double rowSpacingComfortable = 6.0;

  // Day column header (Mon, Tue, etc.)
  static const double columnHeaderHeightMin = 20.0;
  static const double columnHeaderHeight = 24.0;

  // Card design constraints
  static const double cardBorderRadius = 12.0;
  static const double cardMinWidth = 80.0; // Absolute minimum for readability
  static const double cardMinHeight = 60.0; // Absolute minimum for touch target
  static const double cardMaxWidth = 200.0; // Prevents oversized on iPad
  static const double cardMaxHeight = 140.0; // Prevents oversized on iPad
  static const double cardPreferredAspectRatio = 1.0; // Square for compact grid
}

class GridLayout {
  final DeviceSpec device;
  final double headerHeight;
  final double screenMargin;
  final double cardSpacing;
  final double rowSpacing;

  late final double cardWidth;
  late final double cardHeight;
  late final bool isValid;
  late final String validationMessage;

  GridLayout({
    required this.device,
    required this.headerHeight,
    required this.screenMargin,
    required this.cardSpacing,
    required this.rowSpacing,
  }) {
    _calculateDimensions();
  }

  void _calculateDimensions() {
    // Calculate available width for grid
    final totalHorizontalMargin = screenMargin * 2;
    final totalCardSpacing =
        cardSpacing * (LayoutConstants.columnCount - 1);
    final availableWidth =
        device.usableWidth - totalHorizontalMargin - totalCardSpacing;

    // Card width = available width / 7 columns
    final calculatedCardWidth = availableWidth / LayoutConstants.columnCount;

    // Calculate available height for grid
    // FIX: device.usableHeight already excludes safe areas, so don't subtract them again
    final columnHeaderHeight = headerHeight <= LayoutConstants.headerHeightMin 
        ? LayoutConstants.columnHeaderHeightMin 
        : LayoutConstants.columnHeaderHeight;
    
    final reservedHeight = headerHeight + columnHeaderHeight;
    final totalRowSpacing = rowSpacing * (LayoutConstants.rowCount - 1);
    final availableHeight = device.usableHeight - reservedHeight - totalRowSpacing;

    // Card height = available height / 5 rows
    final calculatedCardHeight = availableHeight / LayoutConstants.rowCount;

    // Apply constraints
    cardWidth = calculatedCardWidth.clamp(
      LayoutConstants.cardMinWidth,
      LayoutConstants.cardMaxWidth,
    );

    cardHeight = calculatedCardHeight.clamp(
      LayoutConstants.cardMinHeight,
      LayoutConstants.cardMaxHeight,
    );

    // Validation
    isValid = _validate();
  }

  bool _validate() {
    final issues = <String>[];

    // Determine which header/column header height was used
    final columnHeaderHeight = headerHeight <= LayoutConstants.headerHeightMin 
        ? LayoutConstants.columnHeaderHeightMin 
        : LayoutConstants.columnHeaderHeight;

    // Check minimum touch target
    if (cardWidth < LayoutConstants.minTouchTarget) {
      issues.add('touch_target: width ${cardWidth.toStringAsFixed(1)}pt < ${LayoutConstants.minTouchTarget}pt');
    }
    if (cardHeight < LayoutConstants.minTouchTarget) {
      issues.add('touch_target: height ${cardHeight.toStringAsFixed(1)}pt < ${LayoutConstants.minTouchTarget}pt');
    }

    // Check minimum readable size
    if (cardWidth < LayoutConstants.cardMinWidth) {
      issues.add('readability: width ${cardWidth.toStringAsFixed(1)}pt < ${LayoutConstants.cardMinWidth}pt');
    }
    if (cardHeight < LayoutConstants.cardMinHeight) {
      issues.add('readability: height ${cardHeight.toStringAsFixed(1)}pt < ${LayoutConstants.cardMinHeight}pt');
    }

    // Check if grid fits on screen
    final totalWidth = (cardWidth * LayoutConstants.columnCount) +
        (cardSpacing * (LayoutConstants.columnCount - 1)) +
        (screenMargin * 2);
    if (totalWidth > device.usableWidth) {
      issues.add('width: ${totalWidth.toStringAsFixed(1)}pt > ${device.usableWidth.toStringAsFixed(1)}pt usable');
    }

    final totalHeight = (cardHeight * LayoutConstants.rowCount) +
        (rowSpacing * (LayoutConstants.rowCount - 1)) +
        headerHeight +
        columnHeaderHeight;
    if (totalHeight > device.usableHeight) {
      issues.add('height: ${totalHeight.toStringAsFixed(1)}pt > ${device.usableHeight.toStringAsFixed(1)}pt usable (${(totalHeight - device.usableHeight).toStringAsFixed(1)}pt over)');
    }

    validationMessage = issues.isEmpty ? 'VALID' : issues.join(' | ');
    return issues.isEmpty;
  }

  double get aspectRatio => cardWidth / cardHeight;

  double get totalGridWidth =>
      (cardWidth * LayoutConstants.columnCount) +
      (cardSpacing * (LayoutConstants.columnCount - 1)) +
      (screenMargin * 2);

  double get totalGridHeight {
    final columnHeaderHeight = headerHeight <= LayoutConstants.headerHeightMin 
        ? LayoutConstants.columnHeaderHeightMin 
        : LayoutConstants.columnHeaderHeight;
    return (cardHeight * LayoutConstants.rowCount) +
        (rowSpacing * (LayoutConstants.rowCount - 1)) +
        headerHeight +
        columnHeaderHeight;
  }

  double get leftoverWidth => device.usableWidth - totalGridWidth;
  double get leftoverHeight => device.usableHeight - totalGridHeight;
}

class LandscapeGridCalculator {
  final List<DeviceSpec> devices = [
    // iPhone SE - smallest device
    DeviceSpec(
      name: 'iPhone SE (3rd gen)',
      logicalWidth: 667,
      logicalHeight: 375,
      safeAreaLeading: 0,
      safeAreaTrailing: 0,
      safeAreaTop: 0,
      safeAreaBottom: 0,
    ),

    // iPhone 14 - standard modern iPhone
    DeviceSpec(
      name: 'iPhone 14',
      logicalWidth: 844,
      logicalHeight: 390,
      safeAreaLeading: 47,
      safeAreaTrailing: 47,
      safeAreaTop: 0,
      safeAreaBottom: 21,
    ),

    // iPhone 15 Pro - current generation standard
    DeviceSpec(
      name: 'iPhone 15 Pro',
      logicalWidth: 852,
      logicalHeight: 393,
      safeAreaLeading: 59,
      safeAreaTrailing: 59,
      safeAreaTop: 0,
      safeAreaBottom: 21,
    ),

    // iPhone 16 Pro Max - largest iPhone
    DeviceSpec(
      name: 'iPhone 16 Pro Max',
      logicalWidth: 956,
      logicalHeight: 440,
      safeAreaLeading: 59,
      safeAreaTrailing: 59,
      safeAreaTop: 0,
      safeAreaBottom: 21,
    ),

    // iPad mini - smallest iPad
    DeviceSpec(
      name: 'iPad mini (7th gen)',
      logicalWidth: 1133,
      logicalHeight: 744,
      safeAreaLeading: 0,
      safeAreaTrailing: 0,
      safeAreaTop: 24,
      safeAreaBottom: 20,
    ),

    // iPad Air 11" - mid-size iPad
    DeviceSpec(
      name: 'iPad Air (6th gen 11")',
      logicalWidth: 1180,
      logicalHeight: 820,
      safeAreaLeading: 0,
      safeAreaTrailing: 0,
      safeAreaTop: 24,
      safeAreaBottom: 20,
    ),

    // iPad Pro 12.9" - largest iPad
    DeviceSpec(
      name: 'iPad Pro (12.9")',
      logicalWidth: 1366,
      logicalHeight: 1024,
      safeAreaLeading: 0,
      safeAreaTrailing: 0,
      safeAreaTop: 24,
      safeAreaBottom: 20,
    ),
  ];

  void analyzeAllDevices() {
    print('DEVICE ANALYSIS\n');
    print('Testing 3 layout strategies:');
    print('  1. COMPACT: Minimal spacing, smallest header');
    print('  2. COMFORTABLE: Balanced spacing, medium header');
    print('  3. SPACIOUS: Maximum spacing, larger header\n');
    print('─' * 80);

    for (final device in devices) {
      _analyzeDevice(device);
      print('─' * 80);
    }
  }

  void _analyzeDevice(DeviceSpec device) {
    print('\n${device.name}');
    print('  Screen: ${device.logicalWidth} × ${device.logicalHeight} pt (landscape)');
    print('  Usable: ${device.usableWidth.toStringAsFixed(1)} × ${device.usableHeight.toStringAsFixed(1)} pt (after safe areas)');
    print('');

    // Test 3 layout strategies
    final strategies = [
      _createCompactLayout(device),
      _createComfortableLayout(device),
      _createSpaciousLayout(device),
    ];

    for (final layout in strategies) {
      _printLayoutAnalysis(layout);
    }
  }

  GridLayout _createCompactLayout(DeviceSpec device) {
    // Ultra-compact for small iPhones
    return GridLayout(
      device: device,
      headerHeight: LayoutConstants.headerHeightMin,
      screenMargin: LayoutConstants.screenMarginMin,
      cardSpacing: LayoutConstants.cardSpacingMin,
      rowSpacing: LayoutConstants.rowSpacingMin,
    );
  }

  GridLayout _createComfortableLayout(DeviceSpec device) {
    // Balanced for most devices
    return GridLayout(
      device: device,
      headerHeight: LayoutConstants.headerHeightCompact,
      screenMargin: LayoutConstants.screenMarginComfortable,
      cardSpacing: LayoutConstants.cardSpacingComfortable,
      rowSpacing: LayoutConstants.rowSpacingComfortable,
    );
  }

  GridLayout _createSpaciousLayout(DeviceSpec device) {
    // Generous spacing for larger devices
    return GridLayout(
      device: device,
      headerHeight: LayoutConstants.headerHeightComfortable,
      screenMargin: LayoutConstants.screenMarginComfortable,
      cardSpacing: LayoutConstants.cardSpacingComfortable,
      rowSpacing: LayoutConstants.rowSpacingComfortable,
    );
  }

  void _printLayoutAnalysis(GridLayout layout) {
    final strategyName = _getStrategyName(layout);
    final status = layout.isValid ? '✓' : '✗';
    
    print('  $status $strategyName:');
    print('      Card: ${layout.cardWidth.toStringAsFixed(1)} × ${layout.cardHeight.toStringAsFixed(1)} pt '
          '(aspect ${layout.aspectRatio.toStringAsFixed(2)})');
    print('      Grid: ${layout.totalGridWidth.toStringAsFixed(1)} × ${layout.totalGridHeight.toStringAsFixed(1)} pt');
    print('      Leftover: ${layout.leftoverWidth.toStringAsFixed(1)}w × ${layout.leftoverHeight.toStringAsFixed(1)}h pt');
    
    if (!layout.isValid) {
      print('      ⚠ Issues: ${layout.validationMessage}');
    }
    print('');
  }

  String _getStrategyName(GridLayout layout) {
    if (layout.headerHeight == LayoutConstants.headerHeightMin) {
      return 'COMPACT   ';
    } else if (layout.headerHeight == LayoutConstants.headerHeightCompact) {
      return 'COMFORTABLE';
    } else {
      return 'SPACIOUS  ';
    }
  }

  void printRecommendations() {
    print('\n');
    print('═' * 80);
    print('RECOMMENDATIONS');
    print('═' * 80);
    print('');

    // Find minimum viable card size across all devices using comfortable layout
    double minCardWidth = double.infinity;
    double minCardHeight = double.infinity;
    double maxCardWidth = 0;
    double maxCardHeight = 0;
    String? constrainingDevice;

    for (final device in devices) {
      final layout = _createComfortableLayout(device);
      if (layout.isValid) {
        if (layout.cardWidth < minCardWidth) {
          minCardWidth = layout.cardWidth;
          constrainingDevice = device.name;
        }
        minCardHeight = min(minCardHeight, layout.cardHeight);
        maxCardWidth = max(maxCardWidth, layout.cardWidth);
        maxCardHeight = max(maxCardHeight, layout.cardHeight);
      }
    }

    print('1. CARD DIMENSIONS (Comfortable Layout)');
    print('   ─────────────────────────────────────');
    print('   Minimum card size (constrained by $constrainingDevice):');
    print('     • Width:  ${minCardWidth.toStringAsFixed(1)} pt');
    print('     • Height: ${minCardHeight.toStringAsFixed(1)} pt');
    print('     • Aspect ratio: ${(minCardWidth / minCardHeight).toStringAsFixed(2)} (${_aspectRatioDescription(minCardWidth / minCardHeight)})');
    print('');
    print('   Maximum card size (on iPad Pro 12.9"):');
    print('     • Width:  ${maxCardWidth.toStringAsFixed(1)} pt (clamped to ${LayoutConstants.cardMaxWidth} pt)');
    print('     • Height: ${maxCardHeight.toStringAsFixed(1)} pt (clamped to ${LayoutConstants.cardMaxHeight} pt)');
    print('');

    // Recommended fixed sizes
    final recommendedWidth = (minCardWidth / 5).round() * 5; // Round to nearest 5
    final recommendedHeight = (minCardHeight / 5).round() * 5;

    // Also check compact layout for smallest devices
    double minCardWidthCompact = double.infinity;
    double minCardHeightCompact = double.infinity;
    String? compactConstrainingDevice;

    for (final device in devices) {
      final layout = _createCompactLayout(device);
      if (layout.isValid && layout.cardWidth < minCardWidthCompact) {
        minCardWidthCompact = layout.cardWidth;
        minCardHeightCompact = min(minCardHeightCompact, layout.cardHeight);
        compactConstrainingDevice = device.name;
      }
    }

    // Guard against infinity values (no valid compact layouts)
    final hasValidCompactLayout = minCardWidthCompact.isFinite && minCardHeightCompact.isFinite;
    final compactRecommendedWidth = hasValidCompactLayout ? (minCardWidthCompact / 5).round() * 5 : 100;
    final compactRecommendedHeight = hasValidCompactLayout ? (minCardHeightCompact / 5).round() * 5 : 60;
    final compactValidationNote = hasValidCompactLayout 
        ? "" 
        : " ⚠ (Fallback used; no valid compact layout found)";

    print('   📏 OPTION A: RESPONSIVE BY DEVICE CLASS');
    print('     iPhone (compact layout):');
    print('       • $compactRecommendedWidth × $compactRecommendedHeight pt$compactValidationNote');
    print('       • Aspect ratio: ${(compactRecommendedWidth / compactRecommendedHeight).toStringAsFixed(2)}');
    print('       • Header: $LayoutConstants.headerHeightMin pt, Spacing: $LayoutConstants.cardSpacingMin pt');
    print('     iPad (comfortable layout):');
    print('       • $recommendedWidth × $recommendedHeight pt (scales up, max ${LayoutConstants.cardMaxWidth.toInt()} × ${LayoutConstants.cardMaxHeight.toInt()})');
    print('       • Header: ${LayoutConstants.headerHeightCompact} pt, Spacing: ${LayoutConstants.cardSpacingComfortable} pt');
    print('     Pro: Optimized for each device class');
    print('     Con: More layout variants to maintain');
    print('');

    print('   📐 OPTION B: SINGLE FIXED SIZE');
    print('     All devices: $compactRecommendedWidth × $compactRecommendedHeight pt');
    print('     Pro: Simple, consistent UX');
    print('     Con: Cramped on iPhones, wasted space on iPads');
    print('');

    print('2. LAYOUT COMPARISON WITH INFINITE-SCROLL CALENDAR');
    print('   ───────────────────────────────────────────────');
    print('   Current infinite-scroll card (portrait):');
    print('     • 160 × ~100 pt (aspect 1.60, landscape "wide")');
    print('');
    print('   Landscape week grid card (recommended):');
    print('     • $recommendedWidth × $recommendedHeight pt (aspect ${(recommendedWidth / recommendedHeight).toStringAsFixed(2)}, ${_aspectRatioDescription(recommendedWidth / recommendedHeight)})');
    print('');
    print('   ⚠ REUSE ANALYSIS:');
    if (recommendedWidth == 160 && recommendedHeight == 100) {
      print('     ✓ Cards are IDENTICAL — full component reuse possible');
    } else {
      print('     ✗ Cards differ in size — create parameterized MealCard variant');
      print('       • Reuse: Layout structure, drag-drop logic, styling');
      print('       • Parameterize: Width, height, font sizes, icon sizes');
    }
    print('');

    print('3. CAROUSEL PANEL RECOMMENDATIONS');
    print('   ──────────────────────────────────');
    print('   Modal carousel (for viewing all meals in a day):');
    print('     • Card size: 160 × 100 pt (match infinite-scroll for consistency)');
    print('     • Orientation: Horizontal scroll');
    print('     • Snap behavior: Center-aligned cards');
    print('     • Panel size: 80% screen width × 60% screen height');
    print('');
    print('   Why keep 160×100 in carousel?');
    print('     ✓ Visual consistency with portrait infinite-scroll view');
    print('     ✓ Users recognize same card design across orientations');
    print('     ✓ Larger cards easier to read in modal context');
    print('');

    print('4. RESPONSIVE STRATEGY');
    print('   ────────────────────');
    print('   Option A: FIXED SIZE (Simpler)');
    print('     • Use $recommendedWidth × $recommendedHeight pt on all devices');
    print('     • Center grid with leftover space as margins');
    print('     • Pro: Consistent UX, simple code');
    print('     • Con: Wasted space on iPads');
    print('');
    print('   Option B: RESPONSIVE SCALING (Better iPad UX)');
    print('     • iPhone: $recommendedWidth × $recommendedHeight pt');
    print('     • iPad: Scale up to ${LayoutConstants.cardMaxWidth.toInt()} × ${LayoutConstants.cardMaxHeight.toInt()} pt max');
    print('     • Logic: Use GridLayout.cardWidth/cardHeight calculations');
    print('     • Pro: Optimizes for each device');
    print('     • Con: More complex layout code, font scaling needed');
    print('');
    print('   🎯 RECOMMENDED: Option A (Fixed Size) for v1');
    print('      Iterate to Option B if user feedback shows iPad experience needs improvement');
    print('');

    print('5. HEADER & SPACING SPECS');
    print('   ───────────────────────');
    print('   Header height: $LayoutConstants.headerHeightCompact pt (compact but readable)');
    print('   Column header: $LayoutConstants.columnHeaderHeight pt (day labels)');
    print('   Screen margin: ${LayoutConstants.screenMarginComfortable} pt horizontal');
    print('   Card spacing: ${LayoutConstants.cardSpacingComfortable} pt between columns');
    print('   Row spacing:  ${LayoutConstants.rowSpacingComfortable} pt between rows');
    print('');

    print('6. IMPLEMENTATION CODE SNIPPET');
    print('   ────────────────────────────');
    print('   ```dart');
    print('   // In week_grid_table.dart');
    print('   class WeekGridConstants {');
    print('     static const double cardWidth = $recommendedWidth;');
    print('     static const double cardHeight = $recommendedHeight;');
    print('     static const double cardSpacing = ${LayoutConstants.cardSpacingComfortable};');
    print('     static const double rowSpacing = ${LayoutConstants.rowSpacingComfortable};');
    print('     static const double headerHeight = ${LayoutConstants.headerHeightCompact};');
    print('     static const double columnHeaderHeight = ${LayoutConstants.columnHeaderHeight};');
    print('   }');
    print('   ```');
    print('');

    print('7. VALIDATION SUMMARY');
    print('   ──────────────────');
    int validCount = 0;
    for (final device in devices) {
      final layout = _createComfortableLayout(device);
      final status = layout.isValid ? '✓' : '✗';
      print('   $status ${device.name.padRight(30)} ${layout.cardWidth.toStringAsFixed(1)} × ${layout.cardHeight.toStringAsFixed(1)} pt');
      if (layout.isValid) validCount++;
    }
    print('');
    print('   Result: $validCount/${devices.length} devices pass with comfortable layout');
    print('');

    print('═' * 80);
    print('END OF ANALYSIS');
    print('═' * 80);
  }

  String _aspectRatioDescription(double ratio) {
    if (ratio > 1.4) return 'landscape/wide';
    if (ratio > 1.1) return 'slightly wide';
    if (ratio >= 0.9 && ratio <= 1.1) return 'square';
    if (ratio > 0.7) return 'slightly tall';
    return 'portrait/tall';
  }
}
