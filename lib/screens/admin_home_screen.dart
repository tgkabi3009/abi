import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin.dart';
import '../models/admin_absensi.dart';
import '../services/admin_api_service.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';
import 'admin_absensi_edit_sheet.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  String? _error;
  String _hari = '';
  List<AdminAbsensiRow> _rows = [];
  List<GuruRingkas> _guruList = [];
  AdminUser? _user;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _user = await AdminApiService.instance.loadSavedUser();
    await Future.wait([_loadRows(), _loadGuruList()]);
  }

  Future<void> _loadGuruList() async {
    try {
      final list = await AdminApiService.instance.fetchGuruList();
      if (mounted) setState(() => _guruList = list);
    } catch (_) {
      // daftar guru gagal dimuat — dropdown pengganti nanti kosong, tidak fatal
    }
  }

  Future<void> _loadRows() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final result = await AdminApiService.instance.fetchAbsensiByDate(tanggal);
      setState(() {
        _hari = result.hari;
        _rows = result.rows;
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
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadRows();
    }
  }

  Future<void> _openEditSheet(AdminAbsensiRow row) async {
    final tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminAbsensiEditSheet(row: row, tanggal: tanggal, guruList: _guruList),
    );
    if (changed == true) _loadRows();
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm == true) {
      await AdminApiService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final belum = _rows.where((r) => !r.sudahDiabsen).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.name ?? 'Input Absensi'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month_outlined), onPressed: _pickDate),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _confirmLogout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRows,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          OutlinedButton(onPressed: _loadRows, child: const Text('Coba Lagi')),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_formatTanggalIndo(_selectedDate)} ($_hari)',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                            ),
                            if (belum > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                                child: Text('$belum belum', style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: Text('Tidak ada jadwal pada tanggal ini', style: TextStyle(color: AppColors.textSecondary))),
                        )
                      else
                        ..._rows.map((row) => _rowCard(row)),
                    ],
                  ),
      ),
    );
  }

  Widget _rowCard(AdminAbsensiRow row) {
    final info = _statusInfo(row.statusGuru, row.subStatus);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openEditSheet(row),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEDEFF2))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('${row.jamKe}', style: TextStyle(color: info.color, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${row.mapelNama} — ${row.kelasNama}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                      const SizedBox(height: 3),
                      Text('${row.guruAsal.kodeNama} — ${row.guruAsal.nama}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      if (row.guruPengganti != null) ...[
                        const SizedBox(height: 3),
                        Text('Pengganti: ${row.guruPengganti!.nama}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(info.label, style: TextStyle(color: info.color, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({Color color, String label}) _statusInfo(String? status, String? subStatus) {
    switch (status) {
      case 'hadir':
        return (color: AppColors.success, label: 'Hadir');
      case 'diganti':
        return (color: AppColors.warning, label: 'Diganti');
      case 'tidak_hadir':
        return (color: AppColors.danger, label: subStatus == 'izin' ? 'Izin' : 'Alpa');
      default:
        return (color: AppColors.textSecondary, label: 'Belum');
    }
  }

  static const _bulanIndo = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatTanggalIndo(DateTime d) => '${d.day} ${_bulanIndo[d.month]} ${d.year}';
}
