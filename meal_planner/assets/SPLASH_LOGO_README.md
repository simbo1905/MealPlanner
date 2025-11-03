# Splash Logo Asset Required

The `flutter_native_splash` package requires a splash logo image at:

**Location**: `meal_planner/assets/splash_logo.png`

## Requirements

- **Format**: PNG
- **Dimensions**: Recommended 512x512 pixels or larger
- **Style**: Should match app branding (currently uses blue gradient theme)
- **Background**: The logo should work on white background (#FFFFFF) as configured in pubspec.yaml

## Current Splash Design

The existing Flutter splash screen uses:
- Blue gradient background (Color(0xFF0D47A1) to Color(0xFF1976D2))
- MealPlanner logo with restaurant menu icon
- Rotating emblem animation

## Next Steps

1. Create or obtain a splash logo PNG file
2. Place it at `meal_planner/assets/splash_logo.png`
3. Run `flutter pub get` to ensure package is installed
4. Run `dart run flutter_native_splash:create` to generate native splash files
5. Test on Android and iOS devices

## Alternative

If you don't have a logo ready, you can temporarily:
1. Use a simple white/transparent placeholder
2. Or adjust the `flutter_native_splash` color configuration to match the gradient background
3. Remove the `image:` line from pubspec.yaml configuration if you only want a colored background

