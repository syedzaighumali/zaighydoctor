import 'package:flutter/material.dart';
import '../widgets/top_nav_bar.dart';
import '../utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean modern background
      appBar: const TopNavBar(activeRoute: '/'),
      body: SingleChildScrollView(
        child: Column(
          children: [
             _buildHeroSection(context),
             _buildStatsSection(context),
             _buildCategoriesSection(context),
             _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    
    // Medical Color Palette requested
    const primaryColor = Color(0xFF3A8DFF); // Soft Blue
    const accentColor = Color(0xFF00B4D8); // Teal
    const textColor = Color(0xFF1C2833); // Dark Navy / Gray

    return Stack(
      children: [
        // 1) Lottie animated background isolated to Hero section
        Positioned.fill(
          child: RepaintBoundary(
            child: Lottie.network(
              'https://lottie.host/9e5c5ea7-1906-4cca-afdf-850ce56fbee9/Zp0493Ld5C.json', // AI Neural Network thematic animation
              fit: BoxFit.cover,
              repeat: true,
              animate: true,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE0F7FA), // Fallback soft blue/teal
              ),
            ),
          ),
        ),
        
        // 2) Semi-transparent overlay
        Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),

        // 3) Hero Content
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 80,
            vertical: isMobile ? 60 : 100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          // Trust badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '✨ TRUSTED BY 10,000+ USERS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
          const SizedBox(height: 32),
          
          // App Name
          Text(
            'Sehat Guide',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 48 : 72,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.1,
              letterSpacing: -1.5,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 12),
          
          // Tagline
          Text(
            'Your Smart Health Companion',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 800.ms),

          const SizedBox(height: 24),
          
          // Short description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'Get instant, AI-driven medical suggestions based on your symptoms. Experience a professional, trustworthy, and modern approach to preliminary healthcare right from your home.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 18 : 22,
                color: textColor.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 800.ms),

          const SizedBox(height: 48),

          // Action Buttons
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              // Primary Button
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/patient-details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  shadowColor: primaryColor.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Start Consultation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 12),
                    Icon(Icons.health_and_safety_rounded),
                  ],
                ),
              ),
              // Secondary Button
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/hospitals'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  side: const BorderSide(color: primaryColor, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  foregroundColor: primaryColor,
                ),
                child: const Text('Learn More', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms, duration: 800.ms).slideY(begin: 0.2),
        ],
      ),
    ),
  ],
);
  }

  Widget _buildStatsSection(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    const primaryColor = Color(0xFF3A8DFF); 

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
      child: Wrap(
        spacing: 40,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          _buildStatItem(context, '50+', 'Health Conditions', primaryColor),
          _buildStatItem(context, '100+', 'Verified Medicines', primaryColor),
          _buildStatItem(context, '10k+', 'Active Users', primaryColor),
        ],
      ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color primaryColor) {
    const textColor = Color(0xFF1C2833);
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: textColor.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    const primaryColor = Color(0xFF3A8DFF);
    const textColor = Color(0xFF1C2833);

    final categories = [
      {'name': 'Brain / Neuro', 'desc': 'Manage headaches, migraines, and nerve health issues.', 'icon': Icons.psychology_outlined},
      {'name': 'Heart & BP', 'desc': 'Monitor and manage high blood pressure and cardiac safety.', 'icon': Icons.favorite_border_rounded},
      {'name': 'Lungs', 'desc': 'Guidance for asthma, chronic cough, and respiratory wellness.', 'icon': Icons.air_rounded},
      {'name': 'Fever / Infections', 'desc': 'Smart help for common fevers, typhoid, and malaria.', 'icon': Icons.thermostat_outlined},
      {'name': 'Allergy', 'desc': 'Effective solutions for seasonal and skin allergic reactions.', 'icon': Icons.bug_report_outlined},
      {'name': 'Stomach / Digestive', 'desc': 'Relief for acidity, indigestion, and bloating issues.', 'icon': Icons.restaurant_menu_rounded},
      {'name': 'Bottom / Rectal', 'desc': 'Professional guidance for sensitive piles and rectal health.', 'icon': Icons.medical_services_outlined},
      {'name': 'Female Health', 'desc': 'Specialized support for PCOS, UTI, and feminine wellness.', 'icon': Icons.female_rounded},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 120,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 16),
              Text(
                'BROWSE BY SPECIALTY',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.5),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            'Explore Health Categories',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : (Responsive.isTablet(context) ? 2 : 4),
              childAspectRatio: isMobile ? 1.6 : 1.3,
              crossAxisSpacing: 32,
              mainAxisSpacing: 32,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () {
                   Navigator.pushNamed(
                    context, 
                    '/medicine-suggestions',
                    arguments: cat['name'],
                  );
                },
                child: _CategoryCard(
                  name: cat['name'] as String,
                  desc: cat['desc'] as String,
                  icon: cat['icon'] as IconData,
                ).animate()
                 .fadeIn(duration: 500.ms, delay: (index * 50).ms)
                 .slideY(begin: 0.1, curve: Curves.easeOutQuad),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    const textColor = Color(0xFF1C2833);
    const accentColor = Color(0xFF00B4D8);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.shield_rounded, size: 48, color: accentColor),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'Legal Disclaimer: Sehat Guide provides general health guidance and informational suggestions only. It is NOT a substitute for professional medical advice, diagnosis, or treatment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: textColor.withValues(alpha: 0.5), height: 1.6),
            ),
          ),
          const SizedBox(height: 48),
          Divider(color: textColor.withValues(alpha: 0.1)),
          const SizedBox(height: 48),
          isMobile
            ? Column(
                children: [
                  Text('© 2026 Sehat Guide. All rights reserved.', style: GoogleFonts.outfit(color: textColor)),
                  const SizedBox(height: 24),
                  _buildEmergencyButton(),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('© 2026 Sehat Guide. All rights reserved.', style: GoogleFonts.outfit(color: textColor)),
                   _buildEmergencyButton(),
                ],
              )
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.phone_in_talk_rounded, color: Color(0xFFE53935), size: 18),
          SizedBox(width: 12),
          Text('Emergency: 1122', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String name;
  final String desc;
  final IconData icon;

  const _CategoryCard({required this.name, required this.desc, required this.icon});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3A8DFF); 
    const textColor = Color(0xFF1C2833);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isHovered ? primaryColor.withValues(alpha: 0.02) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isHovered ? 0.08 : 0.04),
              blurRadius: isHovered ? 30 : 20,
              offset: Offset(0, isHovered ? 15 : 10),
            ),
          ],
          border: Border.all(
            color: isHovered ? primaryColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHovered ? primaryColor : primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: isHovered ? Colors.white : primaryColor, size: 32),
            ),
            const Spacer(),
            Text(
              widget.name,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
