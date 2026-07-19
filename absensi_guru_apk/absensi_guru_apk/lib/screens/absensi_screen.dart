import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class AbsensiScreen extends StatelessWidget {
  const AbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Absensi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Harian', icon: Icon(Icons.today_outlined)),
              Tab(text: 'Bulanan', icon: Icon(Icons.calendar_month_outlined)),
            ],
            labelColor: AppTheme.brand,
            unselectedLabelColor: AppTheme.neutral,
            indicatorColor: AppTheme.brand,
          ),
        ),
        body: const TabBarView(
          children: [
            AbsensiHarianTab(),
            AbsensiBulananTab(),
          ],
        ),
      ),
    );
  }
}

// ===== HARIAN =====
class AbsensiHarianTab extends StatefulWidget {
  const AbsensiHarianTab({super.key});

  @override
  State<AbsensiHarianTab> createState() => _AbsensiHarianTabState();
}

class _AbsensiHarianTabState extends State<AbsensiHarianTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final dateStr = _selectedDate.toIso8601String().substring(0, 10);
    context.read<AbsensiProvider>().loadHarian(tanggal: dateStr);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AbsensiProvider>(
      builder: (context, p, _) {
        return Column(
          children: [
            // Date picker bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppTheme.brand),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.harian?.tanggalLabel ?? 'Pilih tanggal',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppTheme.neutral),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _selectedDate = DateTime.now());
                      _load();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      minimumSize: const Size(48, 48),
                    ),
                    child: const Icon(Icons.today),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _load(),
                child: _buildBody(context, p),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AbsensiProvider p) {
    if (p.loading && p.harian == null) {
      return const LoadingIndicator(label: 'Memuat absensi...');
    }
    if (p.error != null && p.harian == null) {
      return ErrorState(message: p.error!, onRetry: _load);
    }
    final h = p.harian!;
    if (h.list.isEmpty) {
      return EmptyState(
        title: 'Tidak ada jadwal',
        subtitle: 'Anda tidak memiliki jadwal mengajar pada ${h.tanggalLabel} (${h.hari}).',
        icon: Icons.event_busy,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: h.list.length + 1,  // +1 for summary
      itemBuilder: (context, i) {
        if (i == 0) return _buildSummaryCard(h.summary, h.tanggalLabel, h.hari);
        final item = h.list[i - 1];
        return _buildAbsensiCard(item);
      },
    );
  }

  Widget _buildSummaryCard(s, String tanggal, String hari) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, size: 16, color: AppTheme.brand),
              const SizedBox(width: 6),
              Text(
                'Ringkasan'.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('Hadir', s.hadir, AppTheme.brand),
              _chip('Belum', s.belum, AppTheme.neutral),
              _chip('Diganti', s.diganti, AppTheme.warning),
              _chip('Izin', s.izin, AppTheme.info),
              _chip('Alpa', s.alpa, AppTheme.error),
              _chip('Pengganti', s.sebagaiPengganti, const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.neutral)),
        ],
      ),
    );
  }

  Widget _buildAbsensiCard(item) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.brand.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${item.jadwal.jamKe}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.brandDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.jadwal.mapelNama,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Kelas ${item.jadwal.kelasNama}',
                      style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                    ),
                  ],
                ),
              ),
              StatusChip(status: item.status, compact: true),
            ],
          ),
          if (item.keterangan != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neutral.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppTheme.neutral),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.keterangan!,
                      style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===== BULANAN =====
class AbsensiBulananTab extends StatefulWidget {
  const AbsensiBulananTab({super.key});

  @override
  State<AbsensiBulananTab> createState() => _AbsensiBulananTabState();
}

class _AbsensiBulananTabState extends State<AbsensiBulananTab> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final monthStr = '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
    context.read<AbsensiProvider>().loadBulanan(bulan: monthStr);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Pilih bulan',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AbsensiProvider>(
      builder: (context, p, _) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickMonth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 18, color: AppTheme.brand),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.bulanan?.bulanLabel ?? 'Pilih bulan',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppTheme.neutral),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _load(),
                child: _buildBody(context, p),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AbsensiProvider p) {
    if (p.loading && p.bulanan == null) {
      return const LoadingIndicator(label: 'Memuat rekap bulanan...');
    }
    if (p.error != null && p.bulanan == null) {
      return ErrorState(message: p.error!, onRetry: _load);
    }
    final b = p.bulanan!;
    final s = b.summary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart, size: 18, color: AppTheme.brand),
                  const SizedBox(width: 6),
                  Text(
                    'Rekap ${b.bulanLabel}'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neutral,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _statRow('Total Absensi', s.total, AppTheme.brandDark),
              _divider(),
              _statRow('Hadir', s.hadir, AppTheme.brand),
              _divider(),
              _statRow('Sebagai Pengganti', s.sebagaiPengganti, const Color(0xFF8B5CF6)),
              _divider(),
              _statRow('Diganti', s.diganti, AppTheme.warning),
              _divider(),
              _statRow('Izin', s.izin, AppTheme.info),
              _divider(),
              _statRow('Alpa', s.alpa, AppTheme.error),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Hari efektif / libur
        if (p.hariEfektif.isNotEmpty) ...[
          const SectionTitle(text: 'Hari Libur / Tidak Efektif'),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: p.hariEfektif.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.event_busy, size: 16, color: AppTheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.tanggalLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          if (h.keterangan != null)
                            Text(h.keterangan!, style: TextStyle(fontSize: 11, color: AppTheme.neutral)),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}
