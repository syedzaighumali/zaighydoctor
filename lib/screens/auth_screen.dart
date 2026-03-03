import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../widgets/top_nav_bar.dart';
import '../services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      Map<String, dynamic> result;
      if (isLogin) {
        result = await AuthService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        result = await AuthService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          int.tryParse(_ageController.text.trim()) ?? 0,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success']) {
          Navigator.pushReplacementNamed(
            context,
            '/auth-success',
            arguments: isLogin,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: const TopNavBar(activeRoute: '/login'),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : (isTablet ? 48 : 0),
            vertical: 40,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: !Responsive.isDesktop(context) 
                ? Column(
                    children: [
                      _buildAuthForm(),
                      const SizedBox(height: 40),
                      _buildAuthSidePanel(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 1, child: _buildAuthForm()),
                      const SizedBox(width: 80),
                      Expanded(flex: 1, child: _buildAuthSidePanel()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLogin ? 'Welcome Back' : 'Create Account',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isLogin 
                    ? 'Fill in your credentials to access your health assistant.' 
                    : 'Join Sehat Guide today for personalized health insights.',
                style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              if (!isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your age' : null,
                ),
                const SizedBox(height: 20),
              ],
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => (val == null || !val.contains('@')) ? 'Please enter a valid email' : null,
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (val) => (val == null || val.length < 6) ? 'Password must be at least 6 characters' : null,
              ),
              
              if (isLogin) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?', style: GoogleFonts.outfit(color: const Color(0xFF0D47A1))),
                  ),
                ),
              ] else 
                const SizedBox(height: 40),

              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isLogin ? 'Login Account' : 'Sign Up Now'),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? "Don't have an account? " : "Already have an account? ",
                    style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? 'Sign Up' : 'Login',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1)),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }

  Widget _buildAuthSidePanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.04),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.medical_services_outlined, size: 80, color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 32),
        Text(
          'Complete Health Guidance',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Join thousands of users who trust Sehat Guide for identifying symptoms and finding the right medical care.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            height: 1.6,
            color: const Color(0xFF64748B),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 40),
        _buildFeatureItem(Icons.verified_user_outlined, 'Secure personal health data'),
        _buildFeatureItem(Icons.history_outlined, 'Track medical consultation history'),
        _buildFeatureItem(Icons.notifications_active_outlined, 'Medicine intake reminders'),
      ].animate(interval: 50.ms).fadeIn(duration: 500.ms).slideX(begin: 0.1, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.outfit(color: const Color(0xFF475569))),
        ],
      ),
    );
  }
}
