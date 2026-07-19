import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/push_notification_service.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';
import 'notifikasi_screen.dart';
import 'tentang_screen.dart';
import 'ubah_password_screen.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final guru = auth.guru;
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<NotifikasiProvider>().refresh();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profil card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.brand, AppTheme.brandDark],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (guru?.kodeNama ?? '?').substring(0, 1),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guru?.nama ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              guru?.kodeNama ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.neutral,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (guru?.tipeGuruLabel != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.brand.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  guru!.tipeGuruLabel!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.brand,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _infoTile(context, 'NIK', guru?.nik ?? '-'),
                _infoTile(context, 'Mapel Utama', guru?.mapelUtama ?? '-'),
                _infoTile(context, 'Tarif per Jam', 'Rp ${guru?.tarifPerJam ?? 0}'),
                const SizedBox(height: 24),

                // Menu
                const SectionTitle(text: 'Menu'),
                _menuTile(
                  context,
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  badge: context.select<NotifikasiProvider, int>((p) => p.list.length),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                    );
                  },
                ),
                _menuTile(
                  context,
                  icon: Icons.lock_outline,
                  label: 'Ubah Password',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UbahPasswordScreen()),
                    );
                  },
                ),
                _menuTile(
                  context,
                  icon: Icons.school_outlined,
                  label: 'Tentang Madrasah',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TentangScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, color: AppTheme.error),
                    label: const Text('Keluar', style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.neutral)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.brand),
        title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: AppTheme.neutral),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda akan keluar dari akun ini. Notifikasi push akan dinonaktifkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Unregister FCM
              await PushNotificationService.instance.unregister();
              // Logout
              if (!context.mounted) return;
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
