import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthSuccessScreen extends StatefulWidget {
  final bool isLogin;

  const AuthSuccessScreen({super.key, required this.isLogin});

  @override
  State<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends State<AuthSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate to home after animation completes
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isLogin ? 'Welcome Back!' : 'Account Created!';
    final String subtitle = widget.isLogin
        ? 'You are now logged in to your health assistant.'
        : 'Your Sehat Guide account is ready to use.';

    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: Center(
                // Inner circle
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 300.ms),

            const SizedBox(height: 40),

            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutQuad),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutQuad),

            const SizedBox(height: 56),

            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .fadeOut(
                  delay: (300 + i * 200).ms,
                  duration: 500.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .fadeIn(duration: 500.ms, curve: Curves.easeInOut);
              }),
            )
            .animate()
            .fadeIn(delay: 900.ms, duration: 400.ms),

            const SizedBox(height: 24),

            Text(
              'Redirecting you now...',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
