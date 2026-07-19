import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class TentangScreen extends StatefulWidget {
  const TentangScreen({super.key});

  @override
  State<TentangScreen> createState() => _TentangScreenState();
}

class _TentangScreenState extends State<TentangScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MadrasahProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Madrasah')),
      body: Consumer<MadrasahProvider>(
        builder: (context, p, _) {
          if (p.loading && p.profil == null) {
            return const LoadingIndicator(label: 'Memuat info madrasah...');
          }
          if (p.error != null && p.profil == null) {
            return ErrorState(message: p.error!, onRetry: p.load);
          }
          final profil = p.profil!;
          final m = profil.madrasah;
          return RefreshIndicator(
            onRefresh: () => p.load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header card
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.brand, AppTheme.brandDark],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.school, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        m.namaMadrasah,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profil.jenjang,
                        style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Identitas
                const SectionTitle(text: 'Identitas'),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row('Kepala Madrasah', m.kepalaMadrasah),
                      _divider(),
                      _row('Tahun Ajaran', m.tahunAjaran),
                      _divider(),
                      _row('Semester', m.semester),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Jadwal operasional
                const SectionTitle(text: 'Jadwal Operasional'),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Hari Libur Pekanan', profil.hariLiburPekanan),
                      _divider(),
                      _row(
                        'Hari Operasional',
                        profil.hariOperasional.join(', '),
                      ),
                      _divider(),
                      _row(
                        'Jam Pelajaran',
                        profil.jamPertama != null && profil.jamTerakhir != null
                            ? '${profil.jamPertama} - ${profil.jamTerakhir}'
                            : '-',
                      ),
                      _divider(),
                      _row('Total Jam/Hari', '${profil.totalJamPelajaran} jam'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Honor tarif (transparansi)
                const SectionTitle(text: 'Tarif Honor per Jam'),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _tarifRow('Satminkal + Sertifikasi', profil.honor.satminkalSertifikasi),
                      _divider(),
                      _tarifRow('Satminkal + Non-Sertifikasi', profil.honor.satminkalNonSertifikasi),
                      _divider(),
                      _tarifRow('Non-Satminkal + Sertifikasi', profil.honor.nonSatminkalSertifikasi),
                      _divider(),
                      _tarifRow('Non-Satminkal + Non-Sertifikasi', profil.honor.nonSatminkalNonSertifikasi),
                      _divider(),
                      _tarifRow('Honor Pengganti (flat)', profil.honor.pengganti, highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Daftar jam pelajaran
                const SectionTitle(text: 'Daftar Jam Pelajaran'),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: profil.jamPelajaran.map((jp) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.brand.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${jp.jamKe}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.brandDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${jp.mulai} - ${jp.selesai}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.neutral)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarifRow(String label, int value, {bool highlight = false}) {
    final formatted = 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.neutral,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: highlight ? AppTheme.brand : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}
