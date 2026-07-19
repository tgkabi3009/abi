class PenggantiInfo {
  final String kodeNama;
  final String nama;

  PenggantiInfo({required this.kodeNama, required this.nama});

  factory PenggantiInfo.fromJson(Map<String, dynamic> json) {
    return PenggantiInfo(
      kodeNama: json['kodeNama'] ?? '',
      nama: json['nama'] ?? '',
    );
  }
}

class AbsensiInfo {
  final String id;
  final String status; // hadir, diganti, izin, alpa, pengganti
  final String role; // asal | pengganti
  final String? keterangan;
  final PenggantiInfo? pengganti;

  AbsensiInfo({
    required this.id,
    required this.status,
    required this.role,
    this.keterangan,
    this.pengganti,
  });

  factory AbsensiInfo.fromJson(Map<String, dynamic> json) {
    return AbsensiInfo(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? 'belum',
      role: json['role'] ?? 'asal',
      keterangan: json['keterangan'],
      pengganti: json['pengganti'] != null ? PenggantiInfo.fromJson(json['pengganti']) : null,
    );
  }
}

class AbsensiJadwalItem {
  final String jadwalId;
  final int jamKe;
  final String kelasNama;
  final String mapelNama;
  final AbsensiInfo? absensi;

  AbsensiJadwalItem({
    required this.jadwalId,
    required this.jamKe,
    required this.kelasNama,
    required this.mapelNama,
    this.absensi,
  });

  factory AbsensiJadwalItem.fromJson(Map<String, dynamic> json) {
    final j = json['jadwal'] ?? {};
    return AbsensiJadwalItem(
      jadwalId: j['id']?.toString() ?? '',
      jamKe: j['jamKe'] ?? 0,
      kelasNama: j['kelas']?['nama'] ?? '-',
      mapelNama: j['mapel']?['nama'] ?? '-',
      absensi: json['absensi'] != null ? AbsensiInfo.fromJson(json['absensi']) : null,
    );
  }
}

class AbsensiSummary {
  final int belum;
  final int hadir;
  final int diganti;
  final int izin;
  final int alpa;
  final int sebagaiPengganti;

  AbsensiSummary({
    required this.belum,
    required this.hadir,
    required this.diganti,
    required this.izin,
    required this.alpa,
    required this.sebagaiPengganti,
  });

  factory AbsensiSummary.fromJson(Map<String, dynamic> json) {
    return AbsensiSummary(
      belum: json['belum'] ?? 0,
      hadir: json['hadir'] ?? 0,
      diganti: json['diganti'] ?? 0,
      izin: json['izin'] ?? 0,
      alpa: json['alpa'] ?? 0,
      sebagaiPengganti: json['sebagaiPengganti'] ?? 0,
    );
  }
}

class AbsensiHarian {
  final String tanggal;
  final String tanggalLabel;
  final String hari;
  final AbsensiSummary summary;
  final List<AbsensiJadwalItem> list;

  AbsensiHarian({
    required this.tanggal,
    required this.tanggalLabel,
    required this.hari,
    required this.summary,
    required this.list,
  });

  factory AbsensiHarian.fromJson(Map<String, dynamic> json) {
    return AbsensiHarian(
      tanggal: json['tanggal'] ?? '',
      tanggalLabel: json['tanggalLabel'] ?? '',
      hari: json['hari'] ?? '',
      summary: AbsensiSummary.fromJson(json['summary'] ?? {}),
      list: (json['list'] as List<dynamic>? ?? [])
          .map((e) => AbsensiJadwalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
