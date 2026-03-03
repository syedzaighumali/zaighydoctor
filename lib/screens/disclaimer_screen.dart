import 'package:flutter/material.dart';
import '../widgets/top_nav_bar.dart';
import '../utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: const TopNavBar(activeRoute: '/disclaimer'),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
            vertical: 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
               Container(
                  padding: EdgeInsets.all(isMobile ? 24 : 48),
                  decoration: BoxDecoration(
                    color: const Color(0xFFffebee),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.gpp_maybe_rounded, color: Color(0xFFEF4444), size: 100),
                      const SizedBox(height: 32),
                      Text(
                        'Important Medical Disclaimer',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 28 : 36,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'This app provides general health guidance only. It is NOT a substitute for professional medical advice, diagnosis or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/hospitals'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        ),
                        icon: const Icon(Icons.local_hospital),
                        label: const Text('Consult a Doctor', style: TextStyle(fontSize: 18)),
                      )
                    ],
                  ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
