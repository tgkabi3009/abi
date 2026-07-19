import 'package:flutter/material.dart';
import '../models/admin.dart';
import '../models/admin_absensi.dart';
import '../services/admin_api_service.dart';
import '../services/api_service.dart' show ApiException;
import '../theme/app_theme.dart';

class AdminAbsensiEditSheet extends StatefulWidget {
  final AdminAbsensiRow row;
  final String tanggal; // yyyy-MM-dd
  final List<GuruRingkas> guruList;

  const AdminAbsensiEditSheet({super.key, required this.row, required this.tanggal, required this.guruList});

  @override
  State<AdminAbsensiEditSheet> createState() => _AdminAbsensiEditSheetState();
}

class _AdminAbsensiEditSheetState extends State<AdminAbsensiEditSheet> {
  late String? _status; // hadir | diganti | tidak_hadir
  late String? _subStatus; // izin | alpa
  late String? _penggantiId;
  late TextEditingController _keteranganController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _status = widget.row.statusGuru;
    _subStatus = widget.row.subStatus;
    _penggantiId = widget.row.guruPengganti?.id;
    _keteranganController = TextEditingController(text: widget.row.keterangan ?? '');
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_status == null) return;
    if (_status == 'diganti' && _penggantiId == null) {
      setState(() => _error = 'Pilih guru pengganti terlebih dahulu');
      return;
    }
    if (_status == 'tidak_hadir' && _subStatus == null) {
      setState(() => _error = 'Pilih Izin atau Alpa');
      return;
    }
    if (_status == 'tidak_hadir' && _subStatus == 'izin' && _keteranganController.text.trim().isEmpty) {
      setState(() => _error = 'Keterangan izin wajib diisi');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AdminApiService.instance.saveAbsensi(
        tanggal: widget.tanggal,
        jadwalId: widget.row.jadwalId,
        statusGuru: _status!,
        subStatus: _status == 'tidak_hadir' ? _subStatus : null,
        guruPenggantiId: _status == 'diganti' ? _penggantiId : null,
        keterangan: _keteranganController.text.trim().isNotEmpty ? _keteranganController.text.trim() : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetKeBelum() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AdminApiService.instance.deleteAbsensi(tanggal: widget.tanggal, jadwalId: widget.row.jadwalId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final penggantiOptions = widget.guruList.where((g) => g.id != widget.row.guruAsal.id).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 16),
              Text('${widget.row.mapelNama} — ${widget.row.kelasNama}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text('Jam ke-${widget.row.jamKe} • ${widget.row.guruAsal.kodeNama} (${widget.row.guruAsal.nama})',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              const Text('Status Kehadiran', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statusChip('hadir', 'Hadir', AppColors.success),
                  _statusChip('diganti', 'Diganti', AppColors.warning),
                  _statusChip('tidak_hadir', 'Tidak Hadir', AppColors.danger),
                ],
              ),
              if (_status == 'diganti') ...[
                const SizedBox(height: 16),
                const Text('Guru Pengganti', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _penggantiId,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.person_search_outlined)),
                  hint: const Text('Pilih guru pengganti'),
                  items: penggantiOptions
                      .map((g) => DropdownMenuItem(value: g.id, child: Text('${g.kodeNama} — ${g.nama}', overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _penggantiId = v),
                ),
              ],
              if (_status == 'tidak_hadir') ...[
                const SizedBox(height: 16),
                const Text('Alasan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _subStatusChip('izin', 'Izin', AppColors.warning),
                    _subStatusChip('alpa', 'Alpa', AppColors.danger),
                  ],
                ),
                if (_subStatus == 'izin') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keteranganController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Keterangan izin', hintText: 'Contoh: sakit, ada keperluan keluarga'),
                  ),
                ],
              ],
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5)),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  if (widget.row.sudahDiabsen)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _resetKeBelum,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Text('Reset ke Belum', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  if (widget.row.sudahDiabsen) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving || _status == null ? null : _save,
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                          : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String value, String label, Color color) {
    final selected = _status == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() {
        _status = value;
        _error = null;
        if (value != 'diganti') _penggantiId = null;
        if (value != 'tidak_hadir') _subStatus = null;
      }),
      selectedColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: selected ? color : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 12.5),
      side: BorderSide(color: selected ? color : const Color(0xFFE5E7EB)),
      backgroundColor: Colors.white,
    );
  }

  Widget _subStatusChip(String value, String label, Color color) {
    final selected = _subStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() {
        _subStatus = value;
        _error = null;
      }),
      selectedColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: selected ? color : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 12.5),
      side: BorderSide(color: selected ? color : const Color(0xFFE5E7EB)),
      backgroundColor: Colors.white,
    );
  }
}
