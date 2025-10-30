import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Root splash screen used in production builds.
///
/// Displays a looping animation encouraging the user to rotate their device
/// and automatically transitions to the app's home screen after a short delay.
class ProductionSplashScreen extends StatefulWidget {
  const ProductionSplashScreen({super.key});

  /// Duration before the splash screen automatically dismisses.
  static const Duration defaultDisplayDuration = Duration(seconds: 5);

  @override
  State<ProductionSplashScreen> createState() => _ProductionSplashScreenState();
}

class _ProductionSplashScreenState extends State<ProductionSplashScreen> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _scheduleDismissal();
  }

  void _scheduleDismissal() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(ProductionSplashScreen.defaultDisplayDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const _SplashScaffold(
      child: SplashAnimation(
        showDismissHint: false,
      ),
    );
  }
}

/// A reusable scaffold used by both production and debug splash flows so we
/// keep the presentation consistent across entry points.
class _SplashScaffold extends StatelessWidget {
  final Widget child;
  final Widget? footer;

  const _SplashScaffold({
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1B4D), Color(0xFF1C3B73)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              const _LogoBadge(),
              const SizedBox(height: 48),
              Expanded(
                child: Center(child: child),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: footer,
                )
              else
                const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple MealPlanner brand treatment used at the top of the splash screen.
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'MealPlanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Plan. Cook. Enjoy.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The core splash screen animation that can be embedded in both production
/// and preview screens.
class SplashAnimation extends StatefulWidget {
  const SplashAnimation({
    super.key,
    this.showDismissHint = true,
  });

  /// When true, a "Tap to dismiss" footer hint is rendered below the
  /// animation. This is used in the debug preview, but hidden in production.
  final bool showDismissHint;

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _arrowOpacity;
  late final Animation<double> _arrowSlide;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -math.pi / 2),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -math.pi / 2, end: 0.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 20,
      ),
    ]).animate(curved);

    _arrowOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(curved);

    _arrowSlide = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 18.0, end: -6.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -6.0, end: 18.0),
        weight: 50,
      ),
    ]).animate(curved);

    _glowPulse = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.6),
        weight: 50,
      ),
    ]).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3 * _glowPulse.value),
                        blurRadius: 64 * _glowPulse.value,
                        spreadRadius: 12 * _glowPulse.value,
                      ),
                    ],
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: _rotation.value,
                  child: Container(
                    width: 120,
                    height: 200,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.smartphone,
                      size: 120,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 60 + _arrowSlide.value,
                  child: Opacity(
                    opacity: _arrowOpacity.value,
                    child: Icon(
                      Icons.screen_rotation,
                      size: 48,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              'Rotate to landscape',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Landscape view unlocks the full weekly planner.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (widget.showDismissHint) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.touch_app, color: Colors.white54, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tap anywhere to return',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Debug-only splash preview which keeps the animation looping until the user
/// taps to dismiss it.
class SplashPreviewScreen extends StatelessWidget {
  const SplashPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: const _SplashScaffold(
        footer: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Tap anywhere to dismiss the preview',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              letterSpacing: 0.4,
            ),
          ),
        ),
        child: SplashAnimation(),
      ),
    );
  }
}

