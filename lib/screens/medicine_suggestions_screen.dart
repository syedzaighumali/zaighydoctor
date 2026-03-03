import 'package:flutter/material.dart';
import '../widgets/top_nav_bar.dart';
import '../utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_localizations.dart';
import '../services/consultation_service.dart';
import '../providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicineSuggestionsScreen extends StatefulWidget {
  const MedicineSuggestionsScreen({super.key});

  @override
  State<MedicineSuggestionsScreen> createState() => _MedicineSuggestionsScreenState();
}

class _MedicineSuggestionsScreenState extends State<MedicineSuggestionsScreen> {
  List<dynamic> _suggestions = [];
  String? _consultationId;
  String? _categoryName;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeData();
      _initialized = true;
    }
  }

  void _initializeData() {
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is Map<String, dynamic>) {
      setState(() {
        _suggestions = args['suggestions'] ?? [];
        _consultationId = args['consultation_id'];
      });
    } else if (args is String) {
      _categoryName = args;
      _fetchByCategory(args);
    }
  }

  Future<void> _fetchByCategory(String categoryName) async {
    setState(() => _isLoading = true);
    final lang = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    final result = await ConsultationService.getMedicinesByCategory(categoryName, lang);
    
    if (mounted) {
      setState(() {
        if (result['success']) {
          _suggestions = result['data'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to fetch medicines'),
              backgroundColor: Colors.red,
            ),
          );
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
          const SnackBar(content: Text('Could not launch PDF download')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);
    bool isDesktop = Responsive.isDesktop(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final String title = _categoryName ?? l10n.translate('general_suggestions');

    return Scaffold(
      appBar: const TopNavBar(activeRoute: '/medicine-suggestions'),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.translate('general_recommendation_subtitle'),
                              style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop && _consultationId != null) ...[
                        ElevatedButton.icon(
                          onPressed: () => _downloadPdf(_consultationId!),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text(l10n.translate('download_pdf')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                          onPressed: () {},
                          icon: const Icon(Icons.alarm_add),
                          label: Text(l10n.translate('set_reminder')),
                        )
                      ]
                    ],
                  ),
                  if (!isDesktop && _consultationId != null) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(_consultationId!),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(l10n.translate('download_pdf')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.alarm_add),
                        label: Text(l10n.translate('set_reminder')),
                      ),
                    )
                  ],
                  const SizedBox(height: 48),
                  
                  if (_suggestions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(l10n.translate('no_suggestions'), 
                                 style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final med = _suggestions[index];
                        return _MedicineCard(
                          medicine: med,
                        ).animate()
                         .fadeIn(duration: 500.ms, delay: (index * 150).ms)
                         .slideX(begin: 0.1, curve: Curves.easeOutQuad, duration: 500.ms, delay: (index * 150).ms);
                      },
                    ),
                ],
              ),
            ),
          ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> medicine;

  const _MedicineCard({
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    bool isDesktop = Responsive.isDesktop(context);

    final String name = medicine['name'] ?? 'Unknown';
    final String content = medicine['description'] ?? '';
    final String dosageLabel = medicine['dosage'] ?? '';
    final bool isPrescription = medicine['is_prescription'] ?? false;

    return Card(
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dosageLabel,
                              style: GoogleFonts.outfit(
                                color: theme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 15, 
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDesktop) _buildActionBtn(context)
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (isPrescription) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF5350)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.translate('prescription_warning'),
                        style: GoogleFonts.inter(color: const Color(0xFFEF5350), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            if (!isDesktop) ...[
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: _buildActionBtn(context)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/medicine-detail', arguments: medicine),
      style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
      child: Text(l10n.translate('view_details')),
    );
  }
}
