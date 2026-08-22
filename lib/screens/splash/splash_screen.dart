import 'package:flutter/material.dart';
import 'package:odomex/core/constants/app_assets.dart';
import 'package:odomex/core/theme/app_durations.dart';

/// Professional, minimal Odomex splash screen featuring the official logo
/// and subtle entrance animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.onAnimationComplete,
  });

  /// Optional callback invoked when the splash animation completes.
  final VoidCallback? onAnimationComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppDurations.defaultCurve,
      ),
    );

    _controller.forward().then((_) {
      if (mounted && widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final logoSize = (shortestSide * 0.30).clamp(90.0, 160.0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Official Odomex 3D Logo
                    Image.asset(
                      AppAssets.logo,
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    // Brand Title
                    Text(
                      'Odomex',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
