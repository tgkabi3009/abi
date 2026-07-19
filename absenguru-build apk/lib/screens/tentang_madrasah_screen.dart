import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class TentangMadrasahScreen extends StatefulWidget {
  const TentangMadrasahScreen({super.key});

  @override
  State<TentangMadrasahScreen> createState() => _TentangMadrasahScreenState();
}

class _TentangMadrasahScreenState extends State<TentangMadrasahScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

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
      final res = await ApiService.instance.fetchProfilMadrasah();
      setState(() {
        _data = res;
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
      appBar: AppBar(title: const Text('Tentang Madrasah')),
      body: AsyncStateView(
        loading: _loading,
        error: _error,
        onRetry: _load,
        child: _data == null ? const SizedBox() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final m = _data!['madrasah'] as Map<String, dynamic>? ?? {};
    final honor = _data!['honor'] as Map<String, dynamic>? ?? {};
    final hariOperasional = (m['hariOperasional'] as List<dynamic>? ?? []).join(', ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m['namaMadrasah']?.toString() ?? '-', style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(m['jenjang']?.toString() ?? '', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _infoTile(Icons.person_outline, 'Kepala Madrasah', m['kepalaMadrasah']?.toString() ?? '-'),
        _infoTile(Icons.school_outlined, 'Tahun Ajaran', m['tahunAjaran']?.toString() ?? '-'),
        _infoTile(Icons.calendar_view_month_outlined, 'Semester', m['semester']?.toString() ?? '-'),
        _infoTile(Icons.event_busy_outlined, 'Hari Libur Pekanan', m['hariLiburPekanan']?.toString() ?? '-'),
        _infoTile(Icons.event_available_outlined, 'Hari Operasional', hariOperasional),
        _infoTile(Icons.access_time_outlined, 'Jam Belajar',
            '${m['jamPertama'] ?? '-'} — ${m['jamTerakhir'] ?? '-'} (${m['totalJamPelajaran'] ?? 0} jam pelajaran)'),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.only(bottom: 10, left: 2),
          child: Text('Tarif Honor per Jam', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEDEFF2))),
          child: Column(
            children: [
              _honorRow('Satminkal + Sertifikasi', honor['satminkal_sertifikasi']),
              _honorRow('Satminkal + Non-Sertifikasi', honor['satminkal_non_sertifikasi']),
              _honorRow('Non-Satminkal + Sertifikasi', honor['non_satminkal_sertifikasi']),
              _honorRow('Non-Satminkal + Non-Sertifikasi', honor['non_satminkal_non_sertifikasi']),
              _honorRow('Sebagai Pengganti', honor['pengganti'], isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEDEFF2))),
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

  Widget _honorRow(String label, dynamic value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEDEFF2)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Text('Rp ${value ?? 0}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}
