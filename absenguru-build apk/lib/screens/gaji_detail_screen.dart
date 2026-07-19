import 'package:flutter/material.dart';
import '../models/gaji.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class GajiDetailScreen extends StatefulWidget {
  final String id;
  const GajiDetailScreen({super.key, required this.id});

  @override
  State<GajiDetailScreen> createState() => _GajiDetailScreenState();
}

class _GajiDetailScreenState extends State<GajiDetailScreen> {
  bool _loading = true;
  String? _error;
  GajiSlipDetail? _slip;

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
      final res = await ApiService.instance.fetchGajiDetail(widget.id);
      setState(() {
        _slip = GajiSlipDetail.fromJson(res['slip'] as Map<String, dynamic>);
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
      appBar: AppBar(title: Text(_slip?.periodeLabel ?? 'Detail Slip Gaji')),
      body: AsyncStateView(
        loading: _loading,
        error: _error,
        onRetry: _load,
        child: _slip == null ? const SizedBox() : _buildContent(_slip!),
      ),
    );
  }

  Widget _buildContent(GajiSlipDetail s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.tipeGuruLabel ?? '', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5)),
              const SizedBox(height: 8),
              const Text('Total Diterima', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(s.totalGajiLabel, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.status == 'finalized' ? 'Final' : 'Draft',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Rincian Jam'),
        _infoCard([
          _row('Jam Hadir', '${s.jamHadir} jam'),
          _row('Jam Sebagai Pengganti', '${s.jamSebagaiPengganti} jam'),
          _row('Jam Digantikan', '${s.jamDiganti} jam'),
          _row('Jam Tidak Hadir', '${s.jamTidakHadir} jam'),
          _row('Tarif per Jam', s.tarifPerJamLabel),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Rincian Honor'),
        _infoCard([
          _row('Honor Mengajar', s.honorMengajarLabel),
          _row('Honor Sebagai Pengganti', s.honorSebagaiPenggantiLabel),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Kontribusi & Total'),
        _infoCard([
          _row('Kontribusi Madrasah', s.kontribusiMadrasahLabel),
          _row('Total Penghasilan', s.totalPenghasilanLabel),
          _row('Total Kewajiban', s.totalKewajibanLabel),
          _row('Total Gaji', s.totalGajiLabel, bold: true),
        ]),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary)),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 13.5,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: bold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
