import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import '../services/mobile_api_service.dart';
import '../widgets/widgets.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lamaCtrl = TextEditingController();
  final _baruCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _obscure3 = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _lamaCtrl.dispose();
    _baruCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final msg = await MobileApiService.instance.changePassword(
            passwordLama: _lamaCtrl.text,
            passwordBaru: _baruCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.brand,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Navigate back to login
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Setelah password diubah, Anda akan diminta login ulang dengan password baru.',
                        style: TextStyle(fontSize: 12, color: AppTheme.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _passwordField(
                controller: _lamaCtrl,
                label: 'Password Lama',
                obscure: _obscure1,
                toggle: () => setState(() => _obscure1 = !_obscure1),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password lama wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: _baruCtrl,
                label: 'Password Baru',
                obscure: _obscure2,
                toggle: () => setState(() => _obscure2 = !_obscure2),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password baru wajib diisi';
                  if (v.length < 4) return 'Password baru minimal 4 karakter';
                  if (v == _lamaCtrl.text) return 'Password baru tidak boleh sama dengan password lama';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _passwordField(
                controller: _konfirmasiCtrl,
                label: 'Konfirmasi Password Baru',
                obscure: _obscure3,
                toggle: () => setState(() => _obscure3 = !_obscure3),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                  if (v != _baruCtrl.text) return 'Konfirmasi tidak cocok dengan password baru';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan Password Baru'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: toggle,
        ),
      ),
      validator: validator,
    );
  }
}
