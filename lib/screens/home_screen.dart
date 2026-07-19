import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'gaji_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Consumer<DashboardProvider>(
                builder: (context, p, _) {
                  if (p.loading && p.data == null) {
                    return const SizedBox(
                      height: 400,
                      child: LoadingIndicator(label: 'Memuat dashboard...'),
                    );
                  }
                  if (p.error != null && p.data == null) {
                    return SizedBox(
                      height: 400,
                      child: ErrorState(message: p.error!, onRetry: p.refresh),
                    );
                  }
                  if (p.data == null) return const SizedBox.shrink();
                  return _buildContent(context, p.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, p, _) {
        final guru = p.data?.guru;
        final madrasah = p.data?.madrasah;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.brand, AppTheme.brandDark],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            madrasah?.namaMadrasah ?? 'MTs Fathin Al-Aziziyah',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Assalamu\'alaikum,',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          Text(
                            guru?.nama.split(',').first ?? 'Guru',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (guru?.mapelUtama != null)
                            Text(
                              guru!.mapelUtama!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          (guru?.kodeNama ?? '?').substring(0, 1),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brand,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, DashboardResponse data) {
    final hari = data.hariIni;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hari ini card
          _buildHariIniCard(context, hari),
          const SizedBox(height: 16),
          // Bulan ini summary
          _buildBulanIniCard(context, data.bulanIni),
          const SizedBox(height: 16),
          // Slip terbaru
          if (data.slipTerbaru != null)
            _buildSlipTerbaruCard(context, data.slipTerbaru!),
          if (data.slipTerbaru != null) const SizedBox(height: 16),
          // Madrasah info
          _buildMadrasahInfoCard(context, data.madrasah),
        ],
      ),
    );
  }

  Widget _buildHariIniCard(BuildContext context, DashboardHariIni hari) {
    final s = hari.summary;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, size: 18, color: AppTheme.brand),
              const SizedBox(width: 6),
              Text(
                'Hari Ini',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hari.tanggalLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (hari.jadwalPertama == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutral.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.beach_access, color: AppTheme.neutral, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tidak ada jadwal mengajar hari ini',
                      style: TextStyle(fontSize: 13, color: AppTheme.neutral),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _summaryChip('Hadir', s.hadir, AppTheme.brand),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryChip('Belum', s.belum, AppTheme.neutral),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _summaryChip('Diganti', s.diganti, AppTheme.warning)),
                const SizedBox(width: 8),
                Expanded(child: _summaryChip('Izin', s.izin, AppTheme.info)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _summaryChip('Alpa', s.alpa, AppTheme.error)),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryChip(
                    'Pengganti',
                    s.sebagaiPengganti,
                    const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.brand.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.brand.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal pertama',
                    style: TextStyle(fontSize: 11, color: AppTheme.neutral),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jam ${hari.jadwalPertama!.jamKe} — ${hari.jadwalPertama!.kelas} • ${hari.jadwalPertama!.mapel}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.neutral,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulanIniCard(BuildContext context, DashboardBulanIni bulan) {
    final s = bulan.summary;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18, color: AppTheme.brand),
              const SizedBox(width: 6),
              Text(
                'Rekap Bulan Ini'.toUpperCase(),
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
          Row(
            children: [
              Expanded(child: _monthStat('Jam Hadir', s.jamHadir, AppTheme.brand)),
              const SizedBox(width: 8),
              Expanded(child: _monthStat('Sebagai Pengganti', s.jamSebagaiPengganti, const Color(0xFF8B5CF6))),
              const SizedBox(width: 8),
              Expanded(child: _monthStat('Tidak Hadir', s.jamTidakHadir, AppTheme.error)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _monthStat('Diganti', s.jamDiganti, AppTheme.warning)),
              const SizedBox(width: 8),
              Expanded(child: _monthStat('Izin', s.izin, AppTheme.info)),
              const SizedBox(width: 8),
              Expanded(child: _monthStat('Alpa', s.alpa, AppTheme.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthStat(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.neutral, height: 1.2),
        ),
      ],
    );
  }

  Widget _buildSlipTerbaruCard(BuildContext context, SlipRingkas slip) {
    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SlipDetailScreen(slipId: slip.id),
          ),
        );
      },
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, size: 18, color: AppTheme.brand),
              const SizedBox(width: 6),
              Text(
                'Slip Gaji Terbaru'.toUpperCase(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slip.periodeLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: slip.status == 'finalized'
                      ? AppTheme.brand.withOpacity(0.12)
                      : AppTheme.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  slip.status == 'finalized' ? 'Final' : 'Draft',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: slip.status == 'finalized' ? AppTheme.brand : AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            slip.totalGajiLabel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.brandDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppTheme.neutral),
              const SizedBox(width: 4),
              Text(
                '${slip.jamHadir} jam hadir • ${slip.jamSebagaiPengganti} pengganti',
                style: TextStyle(fontSize: 12, color: AppTheme.neutral),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMadrasahInfoCard(BuildContext context, MadrasahInfo m) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 18, color: AppTheme.brand),
              const SizedBox(width: 6),
              Text(
                'Info Madrasah'.toUpperCase(),
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
          _infoRow('Nama', m.namaMadrasah),
          _infoRow('Kepala Madrasah', m.kepalaMadrasah),
          _infoRow('Tahun Ajaran', m.tahunAjaran),
          _infoRow('Semester', m.semester),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.neutral)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
