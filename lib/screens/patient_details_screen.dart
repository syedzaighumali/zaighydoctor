import 'package:flutter/material.dart';
import '../widgets/top_nav_bar.dart';
import '../utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_localizations.dart';
import '../services/consultation_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedSymptoms = [];
  
  // Categorized symptoms for better UI organization
  final Map<String, List<String>> _categorizedSymptoms = {
    'Brain & Neuro': ['Headache (Tension type)', 'Migraine', 'Sinusitis', 'Vertigo'],
    'Heart & Blood Pressure': ['High Blood Pressure (Hypertension)', 'Angina (Chest pain due to heart)', 'High Cholesterol', 'Heart Failure'],
    'Respiratory (Lungs)': ['Asthma', 'Bronchitis', 'Pneumonia'],
    'Fever & Infections': ['Common Fever', 'Typhoid', 'Dengue (Supportive care only)', 'Malaria'],
    'Allergies': ['Allergic Rhinitis', 'Skin Allergy'],
    'Digestive (Stomach)': ['Acidity / GERD', 'Gastritis', 'Diarrhea', 'Constipation', 'Stomach Ulcer', 'Food Poisoning'],
    'Rectal Issues': ['Piles (Hemorrhoids)', 'Anal Fissure', 'Anal Infection'],
    'Women\'s Health': ['Vaginal Yeast Infection', 'Bacterial Vaginosis', 'Urinary Tract Infection (UTI)', 'PCOS', 'Painful Periods (Dysmenorrhea)']
  };

  bool _isTakingMedicines = false;

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Responsive.isDesktop(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const TopNavBar(activeRoute: '/patient-details'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withValues(alpha: 0.05),
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isMobile(context) ? 20 : (Responsive.isTablet(context) ? 40 : 120),
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              isDesktop 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildFormCard()),
                      const SizedBox(width: 40),
                      Expanded(flex: 2, child: _buildInfoPanel()),
                    ],
                  )
                : Column(
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 30),
                      _buildInfoPanel(),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
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
            l10n.translate('consultation_form').toUpperCase(),
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
          l10n.translate('consultation_subtitle'),
          style: GoogleFonts.outfit(
            fontSize: Responsive.isMobile(context) ? 28 : 40,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            height: 1.1,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
      ],
    );
  }

  Widget _buildFormCard() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(Icons.person_outline, l10n.translate('personal_info')),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.translate('full_name'),
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              validator: (val) => val == null || val.isEmpty ? l10n.translate('required') : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.translate('age'),
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.isEmpty ? l10n.translate('required') : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: theme.cardColor,
                    decoration: InputDecoration(
                      labelText: l10n.translate('gender'),
                      prefixIcon: const Icon(Icons.people_outline),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    items: ['male', 'female', 'other'].map((e) => DropdownMenuItem(value: e, child: Text(l10n.translate(e) ?? e))).toList(),
                    onChanged: (val) {},
                    validator: (val) => val == null ? l10n.translate('required') : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildSectionTitle(Icons.medical_services, l10n.translate('symptoms')),
            const SizedBox(height: 24),
            Text(
              "Select all that apply to your current condition:",
              style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            ..._categorizedSymptoms.entries.map((category) => _buildSymptomCategory(category.key, category.value)),
            
            if (_selectedSymptoms.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.translate('select_at_least_one'), 
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
              
            const SizedBox(height: 48),
            _buildSectionTitle(Icons.history_edu, 'Additional Details'),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.translate('duration'),
                prefixIcon: const Icon(Icons.timer_outlined),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              validator: (val) => val == null || val.isEmpty ? l10n.translate('required') : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.translate('allergies'),
                prefixIcon: const Icon(Icons.warning_amber_rounded),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(l10n.translate('taking_medicines'), 
                style: GoogleFonts.outfit(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              value: _isTakingMedicines,
              onChanged: (val) => setState(() => _isTakingMedicines = val),
              activeThumbColor: theme.primaryColor,
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.medication_outlined, color: _isTakingMedicines ? theme.primaryColor : theme.dividerColor),
            ),
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.translate('get_suggestions'),
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomCategory(String category, List<String> symptoms) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            category,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: symptoms.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom);
            return FilterChip(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              label: Text(
                symptom,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
              selectedColor: theme.primaryColor,
              checkmarkColor: Colors.white,
              backgroundColor: theme.scaffoldBackgroundColor,
              side: BorderSide(
                color: isSelected ? theme.primaryColor : theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              pressElevation: 4,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildStatCard(
          Icons.security_rounded,
          'Encrypted & Private',
          'Your health data is processed securely and is only used to provide general guidance.',
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 20),
        _buildStatCard(
          Icons.info_outline_rounded,
          'General Guidance',
          'This tool provides informational suggestions. Always consult a certified doctor for medical advice.',
          theme.primaryColor,
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.emergency_outlined, size: 48, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'Emergency?',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'If you are experiencing severe symptoms or a life-threatening emergency, please visit the nearest hospital immediately.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), height: 1.5),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/hospitals'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Find Nearby Hospitals', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideX(begin: 0.1);
  }

  Widget _buildStatCard(IconData icon, String title, String desc, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.outfit(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedSymptoms.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text('Analyzing Symptoms...', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );

      final result = await ConsultationService.createConsultation(_selectedSymptoms);
      
      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      if (result['success']) {
        Navigator.pushNamed(
          context, 
          '/medicine-suggestions', 
          arguments: result['data'],
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
