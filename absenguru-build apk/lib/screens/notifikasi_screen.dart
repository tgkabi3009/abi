import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.instance.fetchNotifikasi();
      setState(() {
        _list = data['list'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('ApiException: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: AsyncStateView(
          loading: _loading,
          error: _error,
          onRetry: _load,
          isEmpty: _list.isEmpty,
          emptyMessage: 'Tidak ada notifikasi',
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = _list[i] as Map<String, dynamic>;
              final info = _prioritasInfo(n['prioritas']?.toString() ?? 'rendah', n['jenis']?.toString() ?? '');
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEDEFF2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(info.icon, color: info.color, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['judul']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          const SizedBox(height: 3),
                          Text(n['isi']?.toString() ?? '', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(n['tanggalLabel']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  ({Color color, IconData icon}) _prioritasInfo(String prioritas, String jenis) {
    if (jenis == 'slip_final') return (color: AppColors.success, icon: Icons.receipt_long_rounded);
    if (jenis == 'absensi_belum') return (color: AppColors.warning, icon: Icons.warning_amber_rounded);
    if (prioritas == 'tinggi') return (color: AppColors.danger, icon: Icons.priority_high_rounded);
    return (color: AppColors.primary, icon: Icons.info_outline_rounded);
  }
}
