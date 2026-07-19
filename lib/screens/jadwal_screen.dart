import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

const List<String> kHariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  bool _loading = true;
  String? _error;
  Map<String, List<JadwalItem>> _grouped = {};

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
      final res = await ApiService.instance.fetchJadwal();
      final jadwalMap = res['jadwal'] as Map<String, dynamic>;
      final grouped = <String, List<JadwalItem>>{};
      jadwalMap.forEach((hari, list) {
        grouped[hari] = (list as List<dynamic>)
            .map((e) => JadwalItem.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      setState(() {
        _grouped = grouped;
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
    final totalJadwal = _grouped.values.fold<int>(0, (a, b) => a + b.length);
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Mengajar')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: AsyncStateView(
          loading: _loading,
          error: _error,
          onRetry: _load,
          isEmpty: totalJadwal == 0,
          emptyMessage: 'Belum ada jadwal mengajar',
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: kHariList.where((h) => (_grouped[h]?.isNotEmpty ?? false)).map((hari) {
              final items = _grouped[hari]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
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
                        child: Row(
                          children: [
                            Text(hari, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                            const SizedBox(width: 8),
                            Text('${items.length} jam', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.gold.withOpacity(0.15),
                              child: Text('${item.jamKe}', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(item.mapelNama, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
                            subtitle: Text(item.kelasNama, style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
