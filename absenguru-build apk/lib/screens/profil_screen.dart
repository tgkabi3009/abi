import 'package:flutter/material.dart';
import '../models/guru.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'tentang_madrasah_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Guru? _guru;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.instance.fetchMe();
      setState(() {
        _guru = Guru.fromJson(res['guru']);
        _loading = false;
      });
    } catch (_) {
      final cached = await ApiService.instance.loadSavedGuru();
      setState(() {
        _guru = cached;
        _loading = false;
      });
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _guru == null
              ? const Center(child: Text('Data tidak tersedia', style: TextStyle(color: AppColors.textSecondary)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              _guru!.kodeNama.isNotEmpty
                                  ? _guru!.kodeNama.substring(0, _guru!.kodeNama.length > 2 ? 2 : _guru!.kodeNama.length)
                                  : '?',
                              style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(_guru!.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 3),
                          Text('Kode: ${_guru!.kodeNama}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _infoTile(Icons.school_outlined, 'Tipe Guru', _guru!.tipeGuruLabel ?? '-'),
                    if (_guru!.mapelUtama != null) _infoTile(Icons.menu_book_outlined, 'Mata Pelajaran Utama', _guru!.mapelUtama!),
                    if (_guru!.nik != null && _guru!.nik!.isNotEmpty) _infoTile(Icons.badge_outlined, 'NIK', _guru!.nik!),
                    _infoTile(Icons.payments_outlined, 'Tarif per Jam', 'Rp ${_guru!.tarifPerJam}'),
                    const SizedBox(height: 20),
                    _menuButton(
                      icon: Icons.lock_reset_outlined,
                      label: 'Ganti Password',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                    ),
                    _menuButton(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang Madrasah',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TentangMadrasahScreen())),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                      label: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _menuButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEDEFF2))),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500))),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
