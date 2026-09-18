import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:futdraw/views/auth/login_view.dart';
import 'package:futdraw/views/home_view.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // O acento nao fica cravado aqui: vem do tema, em `build`. O fundo sim, e
  // de proposito -- ele continua a splash nativa (#060606, no pubspec), e
  // trocar por `colorScheme.surface` piscaria na passagem de uma para a outra.
  static const _bgColor = Color(0xFF0A0A0A);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    Future.delayed(400.ms, () {
      if (mounted) _pulseController.forward();
    });

    Future.delayed(2800.ms, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: 400.ms,
          pageBuilder: (_, __, ___) =>
              widget.isLoggedIn ? const HomeView() : const LoginView(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A cor que o usuario escolheu no drawer. Esta tela fica 2,8 s no ar em
    // toda abertura: se ignorasse o tema, o app pareceria esquecer a escolha
    // a cada restart.
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _bgColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => CustomPaint(
                size: const Size(300, 300),
                painter: _PulseRingsPainter(
                  progress: _pulseController.value,
                  color: accent,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
                const Text(
                  'FutDraw',
                  style: TextStyle(
                    fontFamily: 'PervitinaDex',
                    fontSize: 38,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                )
                    .animate(delay: 650.ms)
                    .slideY(
                      begin: 0.4,
                      end: 0.0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Sorteie. Jogue. Vença.',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14,
                    color: accent,
                    letterSpacing: 1.5,
                  ),
                )
                    .animate(delay: 950.ms)
                    .fadeIn(duration: 500.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseRingsPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _PulseRingsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 2; i++) {
      final delay = i * 0.3;
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final radius = 80.0 + t * 120.0;
      final opacity = (1.0 - t) * 0.6;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_PulseRingsPainter old) => old.progress != progress;
}
