import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class GajiScreen extends StatefulWidget {
  const GajiScreen({super.key});

  @override
  State<GajiScreen> createState() => _GajiScreenState();
}

class _GajiScreenState extends State<GajiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GajiProvider>().loadList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slip Gaji')),
      body: Consumer<GajiProvider>(
        builder: (context, p, _) {
          if (p.loading && p.slipList.isEmpty) {
            return const LoadingIndicator(label: 'Memuat slip gaji...');
          }
          if (p.error != null && p.slipList.isEmpty) {
            return ErrorState(message: p.error!, onRetry: p.loadList);
          }
          if (p.slipList.isEmpty) {
            return EmptyState(
              title: 'Belum ada slip gaji',
              subtitle: 'Slip gaji akan muncul setelah admin memproses penggajian bulanan.',
              icon: Icons.account_balance_wallet_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => p.loadList(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: p.slipList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final slip = p.slipList[i];
                return _slipCard(slip, onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SlipDetailScreen(slipId: slip.id),
                    ),
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _slipCard(SlipRingkas slip, {required VoidCallback onTap}) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (slip.status == 'finalized' ? AppTheme.brand : AppTheme.warning).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  slip.status == 'finalized' ? Icons.check_circle : Icons.hourglass_empty,
                  color: slip.status == 'finalized' ? AppTheme.brand : AppTheme.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slip.periodeLabel,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${slip.jamHadir} hadir • ${slip.jamSebagaiPengganti} pengganti • ${slip.jamDiganti + slip.jamTidakHadir} tidak hadir',
                      style: TextStyle(fontSize: 11, color: AppTheme.neutral),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.neutral),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.brandLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slip.status == 'finalized' ? 'Total Diterima' : 'Estimasi (Draft)',
                  style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                ),
                Text(
                  slip.totalGajiLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slip gaji detail screen.
class SlipDetailScreen extends StatefulWidget {
  final String slipId;
  const SlipDetailScreen({super.key, required this.slipId});

  @override
  State<SlipDetailScreen> createState() => _SlipDetailScreenState();
}

class _SlipDetailScreenState extends State<SlipDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GajiProvider>().loadDetail(widget.slipId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Slip Gaji')),
      body: Consumer<GajiProvider>(
        builder: (context, p, _) {
          if (p.loading && p.detail == null) {
            return const LoadingIndicator(label: 'Memuat detail slip...');
          }
          if (p.error != null && p.detail == null) {
            return ErrorState(
              message: p.error!,
              onRetry: () => p.loadDetail(widget.slipId),
            );
          }
          final slip = p.detail!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _headerCard(slip),
              const SizedBox(height: 16),
              _sectionTitle('Jam Mengajar'),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Hadir', '${slip.jamHadir} jam'),
                    _divider(),
                    _row('Sebagai Pengganti', '${slip.jamSebagaiPengganti} jam'),
                    _divider(),
                    _row('Diganti', '${slip.jamDiganti} jam'),
                    _divider(),
                    _row('Tidak Hadir', '${slip.jamTidakHadir} jam'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Rincian Honor'),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Tarif per Jam', slip.tarifPerJamLabel),
                    _divider(),
                    _row('Honor Mengajar (${slip.jamHadir} jam)', slip.honorMengajarLabel),
                    _divider(),
                    _row('Honor Pengganti (${slip.jamSebagaiPengganti} jam)', slip.honorSebagaiPenggantiLabel),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Kontribusi Madrasah'),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Kontribusi (${slip.jamDiganti + slip.jamTidakHadir} jam)', slip.kontribusiMadrasahLabel),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Total'),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _row('Total Penghasilan', slip.totalPenghasilanLabel, valueColor: AppTheme.brand),
                    _divider(),
                    _row('Total Kewajiban', slip.totalKewajibanLabel, valueColor: AppTheme.error),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Diterima',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            slip.totalGajiLabel,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (slip.status == 'draft')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Slip ini masih berstatus draft. Nilai bisa berubah saat admin generate ulang. Tunggu status "Final" untuk nilai resmi.',
                          style: TextStyle(fontSize: 12, color: AppTheme.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(SlipDetail slip) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            slip.periodeLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            slip.tipeGuruLabel ?? slip.tipeGuru,
            style: TextStyle(fontSize: 12, color: AppTheme.neutral),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: slip.status == 'finalized'
                  ? AppTheme.brand.withOpacity(0.12)
                  : AppTheme.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              slip.status == 'finalized' ? 'FINAL' : 'DRAFT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: slip.status == 'finalized' ? AppTheme.brand : AppTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.neutral,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.neutral)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}
