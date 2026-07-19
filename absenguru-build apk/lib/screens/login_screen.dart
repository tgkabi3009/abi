import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _errorText;

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await ApiService.instance.login(
        _nikController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _errorText = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.gold, size: 44),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Absen Guru',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Portal Guru — Sistem Absensi & Penggajian',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'NIK',
                      hintText: 'Nomor Induk Kependudukan',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'NIK wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                    },
                    child: const Text(
                      'Masuk sebagai Admin / Staf',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
