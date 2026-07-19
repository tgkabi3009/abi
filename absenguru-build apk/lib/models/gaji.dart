class GajiSlipRingkas {
  final String id;
  final String periode;
  final String periodeLabel;
  final int bulan;
  final int tahun;
  final String status; // draft | finalized
  final String tipeGuru;
  final String? tipeGuruLabel;
  final num totalGaji;
  final String totalGajiLabel;

  GajiSlipRingkas({
    required this.id,
    required this.periode,
    required this.periodeLabel,
    required this.bulan,
    required this.tahun,
    required this.status,
    required this.tipeGuru,
    this.tipeGuruLabel,
    required this.totalGaji,
    required this.totalGajiLabel,
  });

  factory GajiSlipRingkas.fromJson(Map<String, dynamic> json) {
    return GajiSlipRingkas(
      id: json['id']?.toString() ?? '',
      periode: json['periode'] ?? '',
      periodeLabel: json['periodeLabel'] ?? '',
      bulan: json['bulan'] ?? 0,
      tahun: json['tahun'] ?? 0,
      status: json['status'] ?? 'draft',
      tipeGuru: json['tipeGuru'] ?? '',
      tipeGuruLabel: json['tipeGuruLabel'],
      totalGaji: json['totalGaji'] ?? 0,
      totalGajiLabel: json['totalGajiLabel'] ?? 'Rp 0',
    );
  }
}

class GajiSlipDetail {
  final String id;
  final String periodeLabel;
  final String status;
  final String? tipeGuruLabel;
  final num tarifPerJam;
  final String tarifPerJamLabel;
  // Jam
  final num jamHadir;
  final num jamSebagaiPengganti;
  final num jamDiganti;
  final num jamTidakHadir;
  // Honor
  final String honorMengajarLabel;
  final String honorSebagaiPenggantiLabel;
  // Kontribusi
  final String kontribusiMadrasahLabel;
  // Total
  final String totalPenghasilanLabel;
  final String totalKewajibanLabel;
  final String totalGajiLabel;

  GajiSlipDetail({
    required this.id,
    required this.periodeLabel,
    required this.status,
    this.tipeGuruLabel,
    required this.tarifPerJam,
    required this.tarifPerJamLabel,
    required this.jamHadir,
    required this.jamSebagaiPengganti,
    required this.jamDiganti,
    required this.jamTidakHadir,
    required this.honorMengajarLabel,
    required this.honorSebagaiPenggantiLabel,
    required this.kontribusiMadrasahLabel,
    required this.totalPenghasilanLabel,
    required this.totalKewajibanLabel,
    required this.totalGajiLabel,
  });

  factory GajiSlipDetail.fromJson(Map<String, dynamic> json) {
    return GajiSlipDetail(
      id: json['id']?.toString() ?? '',
      periodeLabel: json['periodeLabel'] ?? '',
      status: json['status'] ?? 'draft',
      tipeGuruLabel: json['tipeGuruLabel'],
      tarifPerJam: json['tarifPerJam'] ?? 0,
      tarifPerJamLabel: json['tarifPerJamLabel'] ?? 'Rp 0',
      jamHadir: json['jamHadir'] ?? 0,
      jamSebagaiPengganti: json['jamSebagaiPengganti'] ?? 0,
      jamDiganti: json['jamDiganti'] ?? 0,
      jamTidakHadir: json['jamTidakHadir'] ?? 0,
      honorMengajarLabel: json['honorMengajarLabel'] ?? 'Rp 0',
      honorSebagaiPenggantiLabel: json['honorSebagaiPenggantiLabel'] ?? 'Rp 0',
      kontribusiMadrasahLabel: json['kontribusiMadrasahLabel'] ?? 'Rp 0',
      totalPenghasilanLabel: json['totalPenghasilanLabel'] ?? 'Rp 0',
      totalKewajibanLabel: json['totalKewajibanLabel'] ?? 'Rp 0',
      totalGajiLabel: json['totalGajiLabel'] ?? 'Rp 0',
    );
  }
}
