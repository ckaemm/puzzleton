import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/score_service.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _checkExistingPlayer();
  }

  Future<void> _checkExistingPlayer() async {
    final name = await ScoreService.getPlayerName();
    if (name != null && name.isNotEmpty && mounted) {
      // Daha önce isim girilmiş, direkt ana menüye git
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(playerName: name),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _slideController.forward();
      });
    }
  }

  void _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    await ScoreService.savePlayerName(name);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomeScreen(playerName: name),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _fadeController,
              curve: Curves.easeOut,
            ),
            child: Column(
              children: [
                const Spacer(flex: 3),
                // ── Logo ──
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.grid_on_rounded,
                    size: 48,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'PUZZLETON',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Türkçe Kelime Bul',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(flex: 2),
                // ── İsim Giriş Formu ──
                SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const Text(
                        'Oyuncu Adını Gir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Adın...',
                            hintStyle: TextStyle(
                              color: AppTheme.textSecondary.withValues(alpha: 0.5),
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_rounded,
                              color: AppTheme.primaryTeal,
                            ),
                            filled: true,
                            fillColor: AppTheme.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryTeal,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.errorRed,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Lütfen adını gir';
                            }
                            if (value.trim().length < 2) {
                              return 'En az 2 karakter olmalı';
                            }
                            if (value.trim().length > 15) {
                              return 'En fazla 15 karakter olabilir';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _onContinue(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onContinue,
                          child: const Text('BAŞLA'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
