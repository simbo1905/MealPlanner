import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum EntryMode {
  productionSplash,
  debugLauncher,
}

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const developerLauncher = '/dev/launcher';
  static const splashPreview = '/dev/splash-preview';
  static const rotateHint = '/rotate-hint';
}

class ProductionSplashScreen extends StatefulWidget {
  const ProductionSplashScreen({
    super.key,
    required this.nextRoute,
    this.minimumDisplayDuration = const Duration(seconds: 4),
  });

  final String nextRoute;
  final Duration minimumDisplayDuration;

  @override
  State<ProductionSplashScreen> createState() => _ProductionSplashScreenState();
}

class _ProductionSplashScreenState extends State<ProductionSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _timer = Timer(widget.minimumDisplayDuration, _navigateNext);
  }

  void _navigateNext() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SplashContent(
        controller: _controller,
        allowDismiss: false,
      ),
    );
  }
}

class SplashPreviewScreen extends StatefulWidget {
  const SplashPreviewScreen({super.key});

  @override
  State<SplashPreviewScreen> createState() => _SplashPreviewScreenState();
}

class _SplashPreviewScreenState extends State<SplashPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SplashContent(
        controller: _controller,
        allowDismiss: true,
        onDismiss: _dismiss,
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
  const _SplashContent({
    required this.controller,
    required this.allowDismiss,
    this.onDismiss,
  });

  final AnimationController controller;
  final bool allowDismiss;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget content = Stack(
      children: [
        const _SplashBackground(),
        Center(
          child: _RotatingEmblem(controller: controller),
        ),
        if (allowDismiss)
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap anywhere to dismiss',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );

    if (allowDismiss) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: content,
      );
    }

    return SafeArea(child: content);
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _RotatingEmblem extends StatelessWidget {
  const _RotatingEmblem({
    required this.controller,
    this.showRotation = true,
  });

  final AnimationController controller;
  final bool showRotation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget emblem = Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 72,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'MealPlanner',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );

    if (showRotation) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: controller.value * 2 * pi,
            child: child,
          );
        },
        child: emblem,
      );
    }

    return emblem;
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
    
    // Check orientation on build (handles initial state and changes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOrientation();
    });
    
    return Scaffold(
      body: Stack(
        children: [
          const _SplashBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Brand graphic (reuse splash emblem style)
                _RotatingEmblem(
                  controller: _rotationController,
                  showRotation: false,
                ),
                const SizedBox(height: 48),
                // Animated rotating phone icon
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
                // Instruction text
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
          // Continue button (appears after timeout)
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
