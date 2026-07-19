import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotifikasiProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: Consumer<NotifikasiProvider>(
        builder: (context, p, _) {
          if (p.loading && p.list.isEmpty) {
            return const LoadingIndicator(label: 'Memuat notifikasi...');
          }
          if (p.error != null && p.list.isEmpty) {
            return ErrorState(message: p.error!, onRetry: p.refresh);
          }
          if (p.list.isEmpty) {
            return EmptyState(
              title: 'Tidak ada notifikasi',
              subtitle: 'Notifikasi slip gaji dan absensi akan muncul di sini.',
              icon: Icons.notifications_none_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () => p.refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: p.list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = p.list[i];
                return _notifCard(n);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _notifCard(Notifikasi n) {
    final color = AppTheme.priorityColor(n.prioritas);
    final iconData = _iconForJenis(n.jenis);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.judul,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.isi,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: AppTheme.neutral),
                    const SizedBox(width: 4),
                    Text(
                      n.tanggalLabel,
                      style: TextStyle(fontSize: 11, color: AppTheme.neutral),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForJenis(String jenis) {
    switch (jenis) {
      case 'slip_final':
        return Icons.account_balance_wallet;
      case 'slip_draft':
        return Icons.hourglass_empty;
      case 'absensi_belum':
        return Icons.fact_check_outlined;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }
}
