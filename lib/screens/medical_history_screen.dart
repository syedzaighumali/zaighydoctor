import 'package:flutter/material.dart';
import '../widgets/top_nav_bar.dart';
import '../utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/consultation_service.dart';
import '../providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../utils/app_localizations.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final result = await ConsultationService.getHistory();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _history = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPdf(String consultationId) async {
    final localeProv = Provider.of<LocaleProvider>(context, listen: false);
    final url = ConsultationService.getPdfUrl(consultationId, localeProv.locale.languageCode);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not launch PDF download. Please try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'N/A';
      
      DateTime dt;
      if (timestamp is Map && timestamp.containsKey('_seconds')) {
        dt = DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
      } else if (timestamp is String) {
        dt = DateTime.parse(timestamp);
      } else {
        return 'N/A';
      }
      
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const TopNavBar(activeRoute: '/history'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withValues(alpha: 0.03),
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withValues(alpha: 0.01),
            ],
          ),
        ),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : (isTablet ? 40 : 120),
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader(l10n, theme, isMobile),
                  const SizedBox(height: 48),
                  if (_history.isEmpty)
                    _buildEmptyState(theme, l10n)
                  else
                    _buildHistoryList(theme, l10n, isMobile),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.translate('medical_history').toUpperCase() ?? 'HISTORY',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
        const SizedBox(height: 16),
        Text(
          l10n.translate('medical_history_subtitle'),
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 28 : 40,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            height: 1.1,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
            child: Icon(Icons.history_outlined, size: 64, color: theme.disabledColor.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.translate('no_history'),
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/patient-details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.translate('start_consultation')),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildHistoryList(ThemeData theme, AppLocalizations l10n, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final h = _history[index];
        final symptoms = (h['selected_symptoms'] as List).join(', ');
        final suggestedDisease = h['suggested_disease'] ?? 'General Guidance';

        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(h['created_at']),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      suggestedDisease,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Symptoms: $symptoms',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    onPressed: () => _downloadPdf(h['id'] ?? h['_id']),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      foregroundColor: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Report',
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
         .fadeIn(delay: (index * 100).ms)
         .slideX(begin: 0.1, curve: Curves.easeOutQuad);
      },
    );
  }
}
