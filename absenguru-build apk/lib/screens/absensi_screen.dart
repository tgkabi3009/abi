import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/absensi.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  bool _loading = true;
  String? _error;
  AbsensiHarian? _data;
  DateTime _selectedDate = DateTime.now();

  bool _loadingBulanan = true;
  Map<String, dynamic>? _bulanan;

  @override
  void initState() {
    super.initState();
    _load();
    _loadBulanan();
  }

  Future<void> _loadBulanan() async {
    setState(() => _loadingBulanan = true);
    try {
      final res = await ApiService.instance.fetchAbsensiBulanan();
      setState(() {
        _bulanan = res;
        _loadingBulanan = false;
      });
    } catch (_) {
      setState(() => _loadingBulanan = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final res = await ApiService.instance.fetchAbsensi(tanggal: tanggal);
      setState(() {
        _data = AbsensiHarian.fromJson(res);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('ApiException: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month_outlined), onPressed: _pickDate),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: AsyncStateView(
          loading: _loading,
          error: _error,
          onRetry: _load,
          child: _data == null
              ? const SizedBox()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!_loadingBulanan && _bulanan != null) _bulananCard(),
                    if (!_loadingBulanan && _bulanan != null) const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_data!.tanggalLabel} (${_data!.hari})',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_data!.list.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: Text('Tidak ada jadwal pada tanggal ini', style: TextStyle(color: AppColors.textSecondary))),
                      )
                    else
                      ..._data!.list.map((item) => _absensiCard(item)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _bulananCard() {
    final summary = _bulanan!['summary'] as Map<String, dynamic>;
    final bulanLabel = _bulanan!['bulanLabel'] as String? ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan $bulanLabel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 14),
          Row(
            children: [
              _bulananStat('Hadir', summary['hadir']),
              _bulananStat('Diganti', summary['diganti']),
              _bulananStat('Izin', summary['izin']),
              _bulananStat('Alpa', summary['alpa']),
              _bulananStat('Pengganti', summary['sebagaiPengganti']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bulananStat(String label, dynamic value) {
    return Expanded(
      child: Column(
        children: [
          Text('${value ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _absensiCard(AbsensiJadwalItem item) {
    final statusInfo = _statusInfo(item.absensi?.status ?? 'belum');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: statusInfo.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('${item.jamKe}', style: TextStyle(color: statusInfo.color, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.mapelNama} — ${item.kelasNama}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                if (item.absensi?.keterangan != null) ...[
                  const SizedBox(height: 3),
                  Text(item.absensi!.keterangan!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
                if (item.absensi?.pengganti != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Digantikan oleh: ${item.absensi!.pengganti!.nama}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusInfo.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(statusInfo.label, style: TextStyle(color: statusInfo.color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  ({Color color, String label}) _statusInfo(String status) {
    switch (status) {
      case 'hadir':
        return (color: AppColors.success, label: 'Hadir');
      case 'diganti':
        return (color: AppColors.warning, label: 'Diganti');
      case 'izin':
        return (color: AppColors.warning, label: 'Izin');
      case 'alpa':
        return (color: AppColors.danger, label: 'Alpa');
      case 'pengganti':
        return (color: AppColors.primary, label: 'Pengganti');
      default:
        return (color: AppColors.textSecondary, label: 'Belum Diisi');
    }
  }
}
