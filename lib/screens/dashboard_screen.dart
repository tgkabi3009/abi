import 'package:flutter/material.dart';
import '../models/guru.dart';
import '../models/absensi.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'notifikasi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  Guru? _guru;
  AbsensiHarian? _absensiHariIni;
  String _namaMadrasah = '';

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
      final results = await Future.wait([
        ApiService.instance.fetchMe(),
        ApiService.instance.fetchAbsensi(),
        ApiService.instance.fetchPengaturan(),
      ]);
      final guru = Guru.fromJson((results[0] as Map<String, dynamic>)['guru']);
      final absensi = AbsensiHarian.fromJson(results[1] as Map<String, dynamic>);
      final pengaturan = results[2] as Map<String, dynamic>;
      setState(() {
        _guru = guru;
        _absensiHariIni = absensi;
        _namaMadrasah = pengaturan['namaMadrasah'] ?? '';
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
      appBar: AppBar(
        title: Text(_namaMadrasah.isNotEmpty ? _namaMadrasah : 'Absen Guru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotifikasiScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: AsyncStateView(
          loading: _loading,
          error: _error,
          onRetry: _load,
          child: _guru == null
              ? const SizedBox()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _greetingCard(),
                    const SizedBox(height: 16),
                    if (_absensiHariIni != null) _summaryGrid(_absensiHariIni!.summary),
                    const SizedBox(height: 16),
                    if (_absensiHariIni != null) _jadwalHariIniCard(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _greetingCard() {
    final g = _guru!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.gold,
            child: Text(
              g.kodeNama.isNotEmpty ? g.kodeNama.substring(0, g.kodeNama.length > 2 ? 2 : g.kodeNama.length) : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.nama, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  g.tipeGuruLabel ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5),
                ),
                if (g.mapelUtama != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    g.mapelUtama!,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid(AbsensiSummary s) {
    final items = [
      _StatItem('Hadir', s.hadir, AppColors.success, Icons.check_circle_outline),
      _StatItem('Belum', s.belum, AppColors.textSecondary, Icons.hourglass_empty_rounded),
      _StatItem('Diganti', s.diganti, AppColors.warning, Icons.swap_horiz_rounded),
      _StatItem('Alpa', s.alpa, AppColors.danger, Icons.cancel_outlined),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: items
          .map((it) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEDEFF2)),
                ),
                child: Row(
                  children: [
                    Icon(it.icon, color: it.color, size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${it.value}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: it.color)),
                        Text(it.label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _jadwalHariIniCard() {
    final a = _absensiHariIni!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Jadwal Hari Ini — ${a.hari}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: AppColors.textPrimary),
            ),
          ),
          if (a.list.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text('Tidak ada jadwal mengajar hari ini', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: a.list.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, i) {
                final item = a.list[i];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text('${item.jamKe}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text('${item.mapelNama} — ${item.kelasNama}', style: const TextStyle(fontSize: 13.5)),
                  trailing: _statusChip(item.absensi?.status ?? 'belum'),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    late Color color;
    late String label;
    switch (status) {
      case 'hadir':
        color = AppColors.success;
        label = 'Hadir';
        break;
      case 'diganti':
        color = AppColors.warning;
        label = 'Diganti';
        break;
      case 'izin':
        color = AppColors.warning;
        label = 'Izin';
        break;
      case 'alpa':
        color = AppColors.danger;
        label = 'Alpa';
        break;
      case 'pengganti':
        color = AppColors.primary;
        label = 'Pengganti';
        break;
      default:
        color = AppColors.textSecondary;
        label = 'Belum';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  _StatItem(this.label, this.value, this.color, this.icon);
}
