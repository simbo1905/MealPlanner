import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _splashLogoAsset = 'assets/splash_logo.png';

enum EntryMode {
  productionSplash,
  debugLauncher,
}

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const developerLauncher = '/dev/launcher';
  static const splashPreview = '/dev/splash-preview';
  static const splashDemoFinished = '/dev/splash-demo-finished';
  static const rotateHint = '/rotate-hint';
}

class ProductionSplashScreen extends StatefulWidget {
  const ProductionSplashScreen({
    super.key,
    required this.nextRoute,
    this.minimumDisplayDuration = const Duration(seconds: 2),
  });

  final String nextRoute;
  final Duration minimumDisplayDuration;

  @override
  State<ProductionSplashScreen> createState() => _ProductionSplashScreenState();
}

class _ProductionSplashScreenState extends State<ProductionSplashScreen> {
  late final Timer _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.minimumDisplayDuration, _navigateNext);
    debugPrint('[Splash] Production splash started with duration ${widget.minimumDisplayDuration.inMilliseconds}ms');
  }

  void _navigateNext() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    debugPrint('[Splash] Navigating to ${widget.nextRoute}');
    Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _SplashContent(),
    );
  }
}

class SplashPreviewScreen extends StatefulWidget {
  const SplashPreviewScreen({super.key});

  @override
  State<SplashPreviewScreen> createState() => _SplashPreviewScreenState();
}

class _SplashPreviewScreenState extends State<SplashPreviewScreen> {
  void _dismiss() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: Stack(
          children: [
            const _SplashContent(),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap anywhere to dismiss',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeveloperLauncherScreen extends StatelessWidget {
  const DeveloperLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final experimentalDestinations = _experimentalDestinations(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Launcher'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Chip(
              label: Text('DEBUG MODE'),
              backgroundColor: Color(0xFFE3F2FD),
              labelStyle: TextStyle(
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Jump directly to app surfaces for QA and experimentation.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _LauncherTile(
              icon: Icons.home_outlined,
              label: 'Go to Home Screen',
              description: 'Open the production calendar experience.',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.home),
            ),
            const SizedBox(height: 12),
            _LauncherTile(
              icon: Icons.movie_filter_outlined,
              label: 'Preview Splash Animation',
              description: 'Play the production splash animation in a loop.',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.splashPreview),
            ),
            const SizedBox(height: 12),
            _LauncherTile(
              icon: Icons.play_circle_outline,
              label: 'Test Splash Flow',
              description: 'Run full 2-second splash flow ending at demo finished screen.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProductionSplashScreen(
                    nextRoute: AppRoutes.splashDemoFinished,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Experimental destinations',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final destination in experimentalDestinations) ...[
              _LauncherTile(
                icon: destination.icon,
                label: destination.label,
                description: destination.description,
                onTap: destination.onTap,
                isPlaceholder: destination.isPlaceholder,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  List<_ExperimentalDestination> _experimentalDestinations(BuildContext context) {
    return [
      _ExperimentalDestination(
        icon: Icons.restaurant_menu_outlined,
        label: 'Recipe Picker (Placeholder)',
        description: 'Prototype entry for recipe picker flow.',
        isPlaceholder: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PlaceholderDestinationScreen(
                title: 'Recipe Picker',
                message: 'Coming soon. The recipe picker flow is not implemented yet.',
              ),
            ),
          );
        },
      ),
      _ExperimentalDestination(
        icon: Icons.shopping_bag_outlined,
        label: 'Shopping List (Placeholder)',
        description: 'Stub destination for shopping list experiments.',
        isPlaceholder: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PlaceholderDestinationScreen(
                title: 'Shopping List',
                message: 'Placeholder only. No implementation is wired yet.',
              ),
            ),
          );
        },
      ),
    ];
  }
}

class PlaceholderDestinationScreen extends StatelessWidget {
  const PlaceholderDestinationScreen({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Not yet available',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2F2F2F),
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide * 0.6;
          final clampedSize = size.clamp(200.0, 360.0);
          return SvgPicture.asset(
            'assets/merged20.svg',
            width: clampedSize,
            height: clampedSize,
          );
        },
      ),
    );
  }
}

class SplashDemoFinishedScreen extends StatelessWidget {
  const SplashDemoFinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('splash demo finished'),
      ),
    );
  }
}

class _LauncherTile extends StatelessWidget {
  const _LauncherTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(description),
        trailing: isPlaceholder
            ? Chip(
                label: const Text('Placeholder'),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class RotateHintScreen extends StatefulWidget {
  const RotateHintScreen({super.key});

  @override
  State<RotateHintScreen> createState() => _RotateHintScreenState();
}

class _RotateHintScreenState extends State<RotateHintScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Timer _timeoutTimer;
  bool _navigated = false;
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Rotation animation for phone icon (2-3 seconds loop)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Timeout after 3 seconds if no orientation change
    _timeoutTimer = Timer(const Duration(seconds: 3), _onTimeout);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rotationController.dispose();
    _timeoutTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) {
      _checkOrientation();
    }
  }

  void _checkOrientation() {
    if (!mounted || _navigated) return;
    
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!mounted || _navigated) return;
    _navigated = true;
    _timeoutTimer.cancel();
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _onTimeout() {
    if (!mounted || _navigated) return;
    setState(() {
      _showContinueButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOrientation();
    });
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipOval(
                      child: Image.asset(
                        _splashLogoAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: const Icon(
                        Icons.screen_rotation,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Rotate your phone to landscape to access week view.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            if (_showContinueButton)
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExperimentalDestination {
  _ExperimentalDestination({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    required this.isPlaceholder,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isPlaceholder;
}
