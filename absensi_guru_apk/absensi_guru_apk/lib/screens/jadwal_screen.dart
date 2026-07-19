import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'main_shell.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  String _selectedHari = 'Semua';

  static const _hariList = ['Semua', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JadwalProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Mengajar')),
      body: Consumer<JadwalProvider>(
        builder: (context, p, _) {
          if (p.loading && p.jadwal.isEmpty) {
            return const LoadingIndicator(label: 'Memuat jadwal...');
          }
          if (p.error != null && p.jadwal.isEmpty) {
            return ErrorState(message: p.error!, onRetry: p.refresh);
          }

          // Build list of days to show
          final daysToShow = _selectedHari == 'Semua'
              ? _hariList.where((h) => h != 'Semua').where((h) => p.jadwal[h]?.isNotEmpty ?? false).toList()
              : [_selectedHari];

          if (daysToShow.isEmpty) {
            return EmptyState(
              title: 'Tidak ada jadwal',
              subtitle: 'Anda belum memiliki jadwal mengajar terdaftar.',
              icon: Icons.calendar_today_outlined,
            );
          }

          return Column(
            children: [
              // Day filter
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _hariList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final h = _hariList[i];
                    final active = h == _selectedHari;
                    final count = h == 'Semua'
                        ? p.jadwal.values.fold(0, (sum, l) => sum + l.length)
                        : p.jadwal[h]?.length ?? 0;
                    return ChoiceChip(
                      label: Text(count > 0 ? '$h ($count)' : h),
                      selected: active,
                      onSelected: (_) => setState(() => _selectedHari = h),
                      selectedColor: AppTheme.brand,
                      labelStyle: TextStyle(
                        color: active ? Colors.white : AppTheme.neutral,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    );
                  },
                ),
              ),
              // Schedule list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => p.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: daysToShow.length,
                    itemBuilder: (context, i) {
                      final hari = daysToShow[i];
                      final items = p.jadwal[hari] ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_selectedHari == 'Semua')
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
                              child: Text(
                                '$hari • ${items.length} slot',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.brandDark,
                                ),
                              ),
                            ),
                          ...items.map((j) => _jadwalCard(j, p.jamPelajaran)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _jadwalCard(JadwalItem j, List<JamPelajaran> jamList) {
    final jp = jamList.where((x) => x.jamKe == j.jamKe).firstOrNull;
    final timeLabel = jp != null ? '${jp.mulai} - ${jp.selesai}' : '';
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Jam ke indicator
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.brand.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Jam',
                  style: TextStyle(fontSize: 9, color: AppTheme.neutral),
                ),
                Text(
                  '${j.jamKe}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  j.mapelNama,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.class_outlined, size: 14, color: AppTheme.neutral),
                    const SizedBox(width: 4),
                    Text(
                      'Kelas ${j.kelasNama} (Tingkat ${j.kelasTingkat})',
                      style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                    ),
                  ],
                ),
                if (timeLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppTheme.neutral),
                      const SizedBox(width: 4),
                      Text(
                        timeLabel,
                        style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
