import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../utils/responsive.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_localizations.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String activeRoute;

  const TopNavBar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 32 : 80),
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  _buildLogo(context, isMobile),

                  if (Responsive.isDesktop(context)) ...[
                    // Desktop Links and Actions
                    Row(
                      children: [
                        _navBarLink(l10n.translate('home'), '/', activeRoute, context),
                        _navBarLink(l10n.translate('nearby_hospitals'), '/hospitals', activeRoute, context),
                        _navBarLink(l10n.translate('medical_history'), '/history', activeRoute, context),
                        _navBarLink(l10n.translate('disclaimer'), '/disclaimer', activeRoute, context),
                        const SizedBox(width: 32),
                        
                        // Theme selector - Modern Rounded
                        _buildThemeSelector(context, theme, l10n),
                        const SizedBox(width: 16),
                        
                        // Language selector - Modern Rounded
                        _buildLanguageSelector(context, theme),
                        const SizedBox(width: 24),

                        // Auth and New Consultation
                        _buildAuthAndActions(context, theme, l10n),
                      ],
                    ),
                  ] else ...[
                    // Mobile Menu Toggle
                    _buildMobileActions(context, theme),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, '/'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.translate('app_title'),
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProv, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<AppTheme>(
            value: themeProv.theme,
            underline: const SizedBox(),
            icon: Icon(Icons.palette_outlined, size: 18, color: theme.primaryColor),
            dropdownColor: theme.cardColor,
            items: AppTheme.values.map((t) {
              String label;
              switch (t) {
                case AppTheme.light: label = l10n.translate('light'); break;
                case AppTheme.dark: label = l10n.translate('dark'); break;
                case AppTheme.night: label = l10n.translate('night'); break;
              }
              return DropdownMenuItem(
                value: t, 
                child: Text(label, style: GoogleFonts.outfit(fontSize: 14))
              );
            }).toList(),
            onChanged: (t) => themeProv.setTheme(t!),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context, ThemeData theme) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProv, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<Locale>(
            value: localeProv.locale,
            underline: const SizedBox(),
            icon: Icon(Icons.language_rounded, size: 18, color: theme.primaryColor),
            dropdownColor: theme.cardColor,
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('EN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              DropdownMenuItem(value: Locale('ur'), child: Text('اردو', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
            ],
            onChanged: (loc) => localeProv.setLocale(loc!),
          ),
        );
      },
    );
  }

  Widget _buildAuthAndActions(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        final bool loggedIn = snapshot.data ?? false;
        
        return Row(
          children: [
            if (loggedIn)
              _buildAuthButton(
                context, 
                Icons.logout_rounded, 
                l10n.translate('logout'), 
                theme.colorScheme.error,
                () async {
                  await AuthService.logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/');
                }
              )
            else
              _buildAuthButton(
                context, 
                Icons.login_rounded, 
                l10n.translate('login'), 
                theme.primaryColor,
                () => Navigator.pushNamed(context, '/auth')
              ),
              
            const SizedBox(width: 16),
            
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/patient-details'),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(l10n.translate('new_consultation')),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w600)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMobileActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () {}, // Theme/Lang could go here if needed
          icon: Icon(Icons.palette_outlined, color: theme.primaryColor),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.menu_rounded, color: theme.primaryColor),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _navBarLink(String title, String route, String activeRoute, BuildContext context) {
    bool isActive = route == activeRoute;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          if (route != activeRoute) Navigator.pushReplacementNamed(context, route);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 0.2,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: isActive ? 20 : 0,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
