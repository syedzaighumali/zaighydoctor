import 'package:flutter/material.dart';
import '../widgets/top_nav_bar.dart';
import '../utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_localizations.dart';

class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Receive medicine data from arguments
    final Map<String, dynamic>? medicine = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String name = medicine?['name'] ?? 'Medicine Detail';
    final String description = medicine?['description'] ?? 'No description available.';
    final String dosage = medicine?['dosage'] ?? 'Please consult a doctor for dosage.';
    final String warning = medicine?['warning'] ?? 'Keep out of reach of children.';
    final String sideEffects = medicine?['side_effects'] ?? 'Side effects vary by individual.';

    return Scaffold(
      appBar: const TopNavBar(activeRoute: '/medicine-detail'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  l10n.translate('back_to_suggestions'), 
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 36 : 48,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            if (medicine?['category_name'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  medicine!['category_name'],
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)
                ),
              ),
            const SizedBox(height: 48),
            
            _buildSection(
              context: context,
              title: l10n.translate('description'),
              icon: Icons.info,
              content: description,
            ),
            
            _buildSection(
              context: context,
              title: l10n.translate('dosage'),
              icon: Icons.medication,
              content: dosage,
            ),
            
            _buildSection(
              context: context,
              title: l10n.translate('side_effects'),
              icon: Icons.sick,
              content: sideEffects,
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                   Icon(Icons.warning, color: const Color(0xFFEF5350), size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('warnings'), 
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFEF5350))
                        ),
                        const SizedBox(height: 8),
                        Text(
                          warning, 
                          style: TextStyle(color: theme.colorScheme.onSurface, height: 1.5)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(Icons.local_hospital, color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('consultation_notice'), 
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('consultation_notice_subtitle'), 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/hospitals'),
                    style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                    child: Text(l10n.translate('find_nearby_doctor')),
                  )
                ],
              ),
            ),
          ].animate(interval: 50.ms).fadeIn(duration: 600.ms).slideX(begin: 0.05, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required IconData icon, required String content}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor),
              const SizedBox(width: 12),
              Text(
                title, 
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content, 
            style: TextStyle(fontSize: 16, height: 1.6, color: theme.colorScheme.onSurface.withValues(alpha: 0.8))
          ),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor.withValues(alpha: 0.1), thickness: 1),
        ],
      ),
    );
  }
}
