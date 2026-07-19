import 'package:flutter/material.dart';
import '../models/gaji.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'gaji_detail_screen.dart';

class GajiScreen extends StatefulWidget {
  const GajiScreen({super.key});

  @override
  State<GajiScreen> createState() => _GajiScreenState();
}

class _GajiScreenState extends State<GajiScreen> {
  bool _loading = true;
  String? _error;
  List<GajiSlipRingkas> _slips = [];

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
      final res = await ApiService.instance.fetchGajiList();
      final list = (res['slipGaji'] as List<dynamic>)
          .map((e) => GajiSlipRingkas.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _slips = list;
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
      appBar: AppBar(title: const Text('Slip Gaji')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: AsyncStateView(
          loading: _loading,
          error: _error,
          onRetry: _load,
          isEmpty: _slips.isEmpty,
          emptyMessage: 'Belum ada slip gaji',
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _slips.length,
            itemBuilder: (context, i) {
              final s = _slips[i];
              final isFinal = s.status == 'finalized';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => GajiDetailScreen(id: s.id)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEFF2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: AppColors.gold),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.periodeLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(s.tipeGuruLabel ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(s.totalGajiLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (isFinal ? AppColors.success : AppColors.warning).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isFinal ? 'Final' : 'Draft',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isFinal ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
