import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

import 'screens/home_screen.dart';
import 'screens/patient_details_screen.dart';
import 'screens/medicine_suggestions_screen.dart';
import 'screens/medicine_detail_screen.dart';
import 'screens/nearby_hospitals_screen.dart';
import 'screens/medical_history_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/auth_success_screen.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'utils/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const SehatGuideApp());
}

class SehatGuideApp extends StatelessWidget {
  const SehatGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProv, localeProv, _) {
          return MaterialApp(
            title: 'Sehat Guide',
            debugShowCheckedModeBanner: false,
            theme: themeProv.themeData.copyWith(
              textTheme: GoogleFonts.outfitTextTheme(
                themeProv.themeData.textTheme,
              ).copyWith(
                displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
            locale: localeProv.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ur'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
            routes: <String, WidgetBuilder>{
              '/home': (context) => const HomeScreen(),
              '/patient-details': (context) => const AuthGuard(child: PatientDetailsScreen()),
              '/medicine-suggestions': (context) => const MedicineSuggestionsScreen(),
              '/medicine-detail': (context) => const MedicineDetailScreen(),
              '/hospitals': (context) => const NearbyHospitalsScreen(),
              '/history': (context) => const AuthGuard(child: MedicalHistoryScreen()),
              '/disclaimer': (context) => const DisclaimerScreen(),
              '/auth': (context) => const AuthScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/auth-success') {
                final bool isLogin = settings.arguments as bool? ?? true;
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => AuthSuccessScreen(isLogin: isLogin),
                  transitionDuration: const Duration(milliseconds: 300),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _redirected = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return widget.child;
        }

        if (!_redirected) {
          _redirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please login to access this feature'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
              Navigator.pushReplacementNamed(context, '/auth');
            }
          });
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
