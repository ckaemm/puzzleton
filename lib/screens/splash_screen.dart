import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _titleController;
  late final AnimationController _subtitleController;
  late final AnimationController _fadeOutController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _titleOpacity = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeIn,
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeIn,
    );
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    await _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _subtitleController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    await _fadeOutController.forward();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOutAnimation,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceColor(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(
                  Icons.grid_on_rounded,
                  size: 96,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _titleOpacity,
                child: Text(
                  'PUZZLETON',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor(context),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _subtitleOpacity,
                child: Text(
                  'Türkçe Kelime Bul',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor(context),
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
