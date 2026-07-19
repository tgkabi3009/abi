/// Semua model data aplikasi.
/// Pure Dart classes with fromJson/toJson — no codegen dependency.

// === Guru ===
class Guru {
  final String id;
  final String kodeNama;
  final String nama;
  final String? nik;
  final String tipeGuru;
  final String? tipeGuruLabel;
  final int tarifPerJam;
  final String? mapelUtama;
  final String? status;

  const Guru({
    required this.id,
    required this.kodeNama,
    required this.nama,
    this.nik,
    required this.tipeGuru,
    this.tipeGuruLabel,
    required this.tarifPerJam,
    this.mapelUtama,
    this.status,
  });

  factory Guru.fromJson(Map<String, dynamic> j) => Guru(
        id: j['id'] as String,
        kodeNama: j['kodeNama'] as String,
        nama: j['nama'] as String,
        nik: j['nik'] as String?,
        tipeGuru: j['tipeGuru'] as String,
        tipeGuruLabel: j['tipeGuruLabel'] as String?,
        tarifPerJam: (j['tarifPerJam'] as num).toInt(),
        mapelUtama: j['mapelUtama'] is Map ? (j['mapelUtama']['nama'] as String?) : null,
        status: j['status'] as String?,
      );
}

// === Auth Response ===
class AuthResponse {
  final String token;
  final Guru guru;

  const AuthResponse({required this.token, required this.guru});

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
        token: j['token'] as String,
        guru: Guru.fromJson(j['guru'] as Map<String, dynamic>),
      );
}

// === Jam Pelajaran ===
class JamPelajaran {
  final int jamKe;
  final String mulai;
  final String selesai;

  const JamPelajaran({required this.jamKe, required this.mulai, required this.selesai});

  factory JamPelajaran.fromJson(Map<String, dynamic> j) => JamPelajaran(
        jamKe: (j['jamKe'] as num).toInt(),
        mulai: j['mulai'] as String,
        selesai: j['selesai'] as String,
      );
}

// === Jadwal ===
class JadwalItem {
  final String id;
  final int jamKe;
  final String kelasNama;
  final String kelasTingkat;
  final String mapelNama;

  const JadwalItem({
    required this.id,
    required this.jamKe,
    required this.kelasNama,
    required this.kelasTingkat,
    required this.mapelNama,
  });

  factory JadwalItem.fromApi(Map<String, dynamic> j) {
    final kelas = j['kelas'] as Map<String, dynamic>;
    final mapel = j['mapel'] as Map<String, dynamic>;
    return JadwalItem(
      id: j['id'] as String,
      jamKe: (j['jamKe'] as num).toInt(),
      kelasNama: kelas['nama'] as String,
      kelasTingkat: kelas['tingkat'] as String,
      mapelNama: mapel['nama'] as String,
    );
  }
}

// === Absensi Harian ===
class AbsensiItem {
  final String? id;
  final String status; // hadir | diganti | izin | alpa | pengganti | belum
  final String role;   // asal | pengganti
  final String? keterangan;
  final Pengganti? pengganti;
  final JadwalItem jadwal;

  const AbsensiItem({
    this.id,
    required this.status,
    required this.role,
    this.keterangan,
    this.pengganti,
    required this.jadwal,
  });

  factory AbsensiItem.fromApi(Map<String, dynamic> j) {
    final jadwal = j['jadwal'] as Map<String, dynamic>;
    final absensi = j['absensi'] as Map<String, dynamic>?;
    return AbsensiItem(
      id: absensi?['id'] as String?,
      status: absensi?['status'] as String? ?? 'belum',
      role: absensi?['role'] as String? ?? 'asal',
      keterangan: absensi?['keterangan'] as String?,
      pengganti: absensi?['pengganti'] != null
          ? Pengganti.fromJson(absensi!['pengganti'] as Map<String, dynamic>)
          : null,
      jadwal: JadwalItem.fromApi(jadwal),
    );
  }
}

class Pengganti {
  final String kodeNama;
  final String nama;
  const Pengganti({required this.kodeNama, required this.nama});
  factory Pengganti.fromJson(Map<String, dynamic> j) => Pengganti(
        kodeNama: j['kodeNama'] as String,
        nama: j['nama'] as String,
      );
}

class AbsensiSummary {
  final int belum;
  final int hadir;
  final int diganti;
  final int izin;
  final int alpa;
  final int sebagaiPengganti;

  const AbsensiSummary({
    this.belum = 0,
    this.hadir = 0,
    this.diganti = 0,
    this.izin = 0,
    this.alpa = 0,
    this.sebagaiPengganti = 0,
  });

  factory AbsensiSummary.fromJson(Map<String, dynamic> j) => AbsensiSummary(
        belum: (j['belum'] as num?)?.toInt() ?? 0,
        hadir: (j['hadir'] as num?)?.toInt() ?? 0,
        diganti: (j['diganti'] as num?)?.toInt() ?? 0,
        izin: (j['izin'] as num?)?.toInt() ?? 0,
        alpa: (j['alpa'] as num?)?.toInt() ?? 0,
        sebagaiPengganti: (j['sebagaiPengganti'] as num?)?.toInt() ?? 0,
      );
}

class AbsensiHarianResponse {
  final String tanggal;
  final String tanggalLabel;
  final String hari;
  final AbsensiSummary summary;
  final List<AbsensiItem> list;

  const AbsensiHarianResponse({
    required this.tanggal,
    required this.tanggalLabel,
    required this.hari,
    required this.summary,
    required this.list,
  });

  factory AbsensiHarianResponse.fromJson(Map<String, dynamic> j) => AbsensiHarianResponse(
        tanggal: j['tanggal'] as String,
        tanggalLabel: j['tanggalLabel'] as String,
        hari: j['hari'] as String,
        summary: AbsensiSummary.fromJson(j['summary'] as Map<String, dynamic>),
        list: (j['list'] as List).map((e) => AbsensiItem.fromApi(e as Map<String, dynamic>)).toList(),
      );
}

// === Absensi Bulanan ===
class AbsensiBulananSummary {
  final int hadir;
  final int diganti;
  final int izin;
  final int alpa;
  final int sebagaiPengganti;
  final int total;

  const AbsensiBulananSummary({
    this.hadir = 0,
    this.diganti = 0,
    this.izin = 0,
    this.alpa = 0,
    this.sebagaiPengganti = 0,
    this.total = 0,
  });

  factory AbsensiBulananSummary.fromJson(Map<String, dynamic> j) => AbsensiBulananSummary(
        hadir: (j['hadir'] as num?)?.toInt() ?? 0,
        diganti: (j['diganti'] as num?)?.toInt() ?? 0,
        izin: (j['izin'] as num?)?.toInt() ?? 0,
        alpa: (j['alpa'] as num?)?.toInt() ?? 0,
        sebagaiPengganti: (j['sebagaiPengganti'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
      );
}

class AbsensiBulananResponse {
  final String bulan;
  final String bulanLabel;
  final AbsensiBulananSummary summary;
  final Map<String, dynamic> perTanggal; // raw — tampilkan sebagai list di UI

  const AbsensiBulananResponse({
    required this.bulan,
    required this.bulanLabel,
    required this.summary,
    required this.perTanggal,
  });

  factory AbsensiBulananResponse.fromJson(Map<String, dynamic> j) => AbsensiBulananResponse(
        bulan: j['bulan'] as String,
        bulanLabel: j['bulanLabel'] as String,
        summary: AbsensiBulananSummary.fromJson(j['summary'] as Map<String, dynamic>),
        perTanggal: (j['perTanggal'] as Map).cast<String, dynamic>(),
      );
}

// === Slip Gaji (list ringkas) ===
class SlipRingkas {
  final String id;
  final String periode;
  final String periodeLabel;
  final String status; // draft | finalized
  final int jamHadir;
  final int jamSebagaiPengganti;
  final int jamDiganti;
  final int jamTidakHadir;
  final int totalGaji;
  final String totalGajiLabel;

  const SlipRingkas({
    required this.id,
    required this.periode,
    required this.periodeLabel,
    required this.status,
    required this.jamHadir,
    required this.jamSebagaiPengganti,
    required this.jamDiganti,
    required this.jamTidakHadir,
    required this.totalGaji,
    required this.totalGajiLabel,
  });

  factory SlipRingkas.fromJson(Map<String, dynamic> j) => SlipRingkas(
        id: j['id'] as String,
        periode: j['periode'] as String,
        periodeLabel: j['periodeLabel'] as String,
        status: j['status'] as String,
        jamHadir: (j['jamHadir'] as num).toInt(),
        jamSebagaiPengganti: (j['jamSebagaiPengganti'] as num).toInt(),
        jamDiganti: (j['jamDiganti'] as num).toInt(),
        jamTidakHadir: (j['jamTidakHadir'] as num).toInt(),
        totalGaji: (j['totalGaji'] as num).toInt(),
        totalGajiLabel: j['totalGajiLabel'] as String,
      );
}

// === Slip Gaji (detail) ===
class SlipDetail {
  final String id;
  final String periode;
  final String periodeLabel;
  final String status;
  final String tipeGuru;
  final String? tipeGuruLabel;
  final int tarifPerJam;
  final String tarifPerJamLabel;
  final int jamHadir;
  final int jamSebagaiPengganti;
  final int jamDiganti;
  final int jamTidakHadir;
  final int honorMengajar;
  final String honorMengajarLabel;
  final int honorSebagaiPengganti;
  final String honorSebagaiPenggantiLabel;
  final int kontribusiMadrasah;
  final String kontribusiMadrasahLabel;
  final int totalPenghasilan;
  final String totalPenghasilanLabel;
  final int totalKewajiban;
  final String totalKewajibanLabel;
  final int totalGaji;
  final String totalGajiLabel;

  const SlipDetail({
    required this.id,
    required this.periode,
    required this.periodeLabel,
    required this.status,
    required this.tipeGuru,
    this.tipeGuruLabel,
    required this.tarifPerJam,
    required this.tarifPerJamLabel,
    required this.jamHadir,
    required this.jamSebagaiPengganti,
    required this.jamDiganti,
    required this.jamTidakHadir,
    required this.honorMengajar,
    required this.honorMengajarLabel,
    required this.honorSebagaiPengganti,
    required this.honorSebagaiPenggantiLabel,
    required this.kontribusiMadrasah,
    required this.kontribusiMadrasahLabel,
    required this.totalPenghasilan,
    required this.totalPenghasilanLabel,
    required this.totalKewajiban,
    required this.totalKewajibanLabel,
    required this.totalGaji,
    required this.totalGajiLabel,
  });

  factory SlipDetail.fromJson(Map<String, dynamic> j) => SlipDetail(
        id: j['id'] as String,
        periode: j['periode'] as String,
        periodeLabel: j['periodeLabel'] as String,
        status: j['status'] as String,
        tipeGuru: j['tipeGuru'] as String,
        tipeGuruLabel: j['tipeGuruLabel'] as String?,
        tarifPerJam: (j['tarifPerJam'] as num).toInt(),
        tarifPerJamLabel: j['tarifPerJamLabel'] as String,
        jamHadir: (j['jamHadir'] as num).toInt(),
        jamSebagaiPengganti: (j['jamSebagaiPengganti'] as num).toInt(),
        jamDiganti: (j['jamDiganti'] as num).toInt(),
        jamTidakHadir: (j['jamTidakHadir'] as num).toInt(),
        honorMengajar: (j['honorMengajar'] as num).toInt(),
        honorMengajarLabel: j['honorMengajarLabel'] as String,
        honorSebagaiPengganti: (j['honorSebagaiPengganti'] as num).toInt(),
        honorSebagaiPenggantiLabel: j['honorSebagaiPenggantiLabel'] as String,
        kontribusiMadrasah: (j['kontribusiMadrasah'] as num).toInt(),
        kontribusiMadrasahLabel: j['kontribusiMadrasahLabel'] as String,
        totalPenghasilan: (j['totalPenghasilan'] as num).toInt(),
        totalPenghasilanLabel: j['totalPenghasilanLabel'] as String,
        totalKewajiban: (j['totalKewajiban'] as num).toInt(),
        totalKewajibanLabel: j['totalKewajibanLabel'] as String,
        totalGaji: (j['totalGaji'] as num).toInt(),
        totalGajiLabel: j['totalGajiLabel'] as String,
      );
}

// === Notifikasi ===
class Notifikasi {
  final String id;
  final String jenis;       // slip_final | slip_draft | absensi_belum | info
  final String judul;
  final String isi;
  final String tanggal;     // ISO
  final String prioritas;   // tinggi | sedang | rendah
  final String tanggalLabel;

  const Notifikasi({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.isi,
    required this.tanggal,
    required this.prioritas,
    required this.tanggalLabel,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> j) => Notifikasi(
        id: j['id'] as String,
        jenis: j['jenis'] as String,
        judul: j['judul'] as String,
        isi: j['isi'] as String,
        tanggal: j['tanggal'] as String,
        prioritas: j['prioritas'] as String,
        tanggalLabel: j['tanggalLabel'] as String,
      );
}

// === Hari Efektif ===
class HariEfektif {
  final String id;
  final String tanggal;
  final String tanggalLabel;
  final bool isEfektif;
  final String? keterangan;

  const HariEfektif({
    required this.id,
    required this.tanggal,
    required this.tanggalLabel,
    required this.isEfektif,
    this.keterangan,
  });

  factory HariEfektif.fromJson(Map<String, dynamic> j) => HariEfektif(
        id: j['id'] as String,
        tanggal: j['tanggal'] as String,
        tanggalLabel: j['tanggalLabel'] as String,
        isEfektif: j['isEfektif'] as bool,
        keterangan: j['keterangan'] as String?,
      );
}

// === Dashboard ===
class DashboardResponse {
  final String serverTime;
  final Guru guru;
  final DashboardHariIni hariIni;
  final DashboardBulanIni bulanIni;
  final SlipRingkas? slipTerbaru;
  final List<String> hariAktif;
  final MadrasahInfo madrasah;

  const DashboardResponse({
    required this.serverTime,
    required this.guru,
    required this.hariIni,
    required this.bulanIni,
    this.slipTerbaru,
    required this.hariAktif,
    required this.madrasah,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> j) => DashboardResponse(
        serverTime: j['serverTime'] as String,
        guru: Guru.fromJson(j['guru'] as Map<String, dynamic>),
        hariIni: DashboardHariIni.fromJson(j['hariIni'] as Map<String, dynamic>),
        bulanIni: DashboardBulanIni.fromJson(j['bulanIni'] as Map<String, dynamic>),
        slipTerbaru: j['slipTerbaru'] != null
            ? SlipRingkas.fromJson(j['slipTerbaru'] as Map<String, dynamic>)
            : null,
        hariAktif: (j['hariAktif'] as List).map((e) => e as String).toList(),
        madrasah: MadrasahInfo.fromJson(j['madrasah'] as Map<String, dynamic>),
      );
}

class DashboardHariIni {
  final String tanggal;
  final String tanggalLabel;
  final String hari;
  final AbsensiSummary summary;
  final JadwalRingkas? jadwalPertama;
  final JadwalRingkas? jadwalTerakhir;

  const DashboardHariIni({
    required this.tanggal,
    required this.tanggalLabel,
    required this.hari,
    required this.summary,
    this.jadwalPertama,
    this.jadwalTerakhir,
  });

  factory DashboardHariIni.fromJson(Map<String, dynamic> j) => DashboardHariIni(
        tanggal: j['tanggal'] as String,
        tanggalLabel: j['tanggalLabel'] as String,
        hari: j['hari'] as String,
        summary: AbsensiSummary.fromJson(j['summary'] as Map<String, dynamic>),
        jadwalPertama: j['jadwalPertama'] != null
            ? JadwalRingkas.fromJson(j['jadwalPertama'] as Map<String, dynamic>)
            : null,
        jadwalTerakhir: j['jadwalTerakhir'] != null
            ? JadwalRingkas.fromJson(j['jadwalTerakhir'] as Map<String, dynamic>)
            : null,
      );
}

class JadwalRingkas {
  final int jamKe;
  final String kelas;
  final String mapel;
  const JadwalRingkas({required this.jamKe, required this.kelas, required this.mapel});
  factory JadwalRingkas.fromJson(Map<String, dynamic> j) => JadwalRingkas(
        jamKe: (j['jamKe'] as num).toInt(),
        kelas: j['kelas'] as String,
        mapel: j['mapel'] as String,
      );
}

class DashboardBulanIni {
  final String bulan;
  final AbsensiBulananSummary summary;
  const DashboardBulanIni({required this.bulan, required this.summary});
  factory DashboardBulanIni.fromJson(Map<String, dynamic> j) => DashboardBulanIni(
        bulan: j['bulan'] as String,
        summary: AbsensiBulananSummary.fromJson(j['summary'] as Map<String, dynamic>),
      );
}

class MadrasahInfo {
  final String namaMadrasah;
  final String kepalaMadrasah;
  final String tahunAjaran;
  final String semester;

  const MadrasahInfo({
    required this.namaMadrasah,
    required this.kepalaMadrasah,
    required this.tahunAjaran,
    required this.semester,
  });

  factory MadrasahInfo.fromJson(Map<String, dynamic> j) => MadrasahInfo(
        namaMadrasah: j['namaMadrasah'] as String? ?? '',
        kepalaMadrasah: j['kepalaMadrasah'] as String? ?? '',
        tahunAjaran: j['tahunAjaran'] as String? ?? '',
        semester: j['semester'] as String? ?? '',
      );
}

// === Profil Madrasah (extended) ===
class ProfilMadrasah {
  final MadrasahInfo madrasah;
  final String jenjang;
  final String hariLiburPekanan;
  final List<String> hariOperasional;
  final String? jamPertama;
  final String? jamTerakhir;
  final int totalJamPelajaran;
  final HonorTarif honor;
  final List<JamPelajaran> jamPelajaran;

  const ProfilMadrasah({
    required this.madrasah,
    required this.jenjang,
    required this.hariLiburPekanan,
    required this.hariOperasional,
    this.jamPertama,
    this.jamTerakhir,
    required this.totalJamPelajaran,
    required this.honor,
    required this.jamPelajaran,
  });

  factory ProfilMadrasah.fromJson(Map<String, dynamic> j) {
    final m = j['madrasah'] as Map<String, dynamic>;
    return ProfilMadrasah(
      madrasah: MadrasahInfo.fromJson(m),
      jenjang: m['jenjang'] as String? ?? 'MTs',
      hariLiburPekanan: m['hariLiburPekanan'] as String? ?? 'Jumat',
      hariOperasional: (m['hariOperasional'] as List).map((e) => e as String).toList(),
      jamPertama: m['jamPertama'] as String?,
      jamTerakhir: m['jamTerakhir'] as String?,
      totalJamPelajaran: (m['totalJamPelajaran'] as num?)?.toInt() ?? 0,
      honor: HonorTarif.fromJson(j['honor'] as Map<String, dynamic>),
      jamPelajaran: (j['jamPelajaran'] as List)
          .map((e) => JamPelajaran.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HonorTarif {
  final int satminkalSertifikasi;
  final int satminkalNonSertifikasi;
  final int nonSatminkalSertifikasi;
  final int nonSatminkalNonSertifikasi;
  final int pengganti;

  const HonorTarif({
    required this.satminkalSertifikasi,
    required this.satminkalNonSertifikasi,
    required this.nonSatminkalSertifikasi,
    required this.nonSatminkalNonSertifikasi,
    required this.pengganti,
  });

  factory HonorTarif.fromJson(Map<String, dynamic> j) => HonorTarif(
        satminkalSertifikasi: (j['satminkal_sertifikasi'] as num).toInt(),
        satminkalNonSertifikasi: (j['satminkal_non_sertifikasi'] as num).toInt(),
        nonSatminkalSertifikasi: (j['non_satminkal_sertifikasi'] as num).toInt(),
        nonSatminkalNonSertifikasi: (j['non_satminkal_non_sertifikasi'] as num).toInt(),
        pengganti: (j['pengganti'] as num).toInt(),
      );
}

// === Ping / Health Check ===
class PingResponse {
  final String serverTime;
  final String timezone;
  final String minApkVersion;
  final String latestApkVersion;
  final bool maintenance;
  final String maintenanceMessage;

  const PingResponse({
    required this.serverTime,
    required this.timezone,
    required this.minApkVersion,
    required this.latestApkVersion,
    required this.maintenance,
    required this.maintenanceMessage,
  });

  factory PingResponse.fromJson(Map<String, dynamic> j) => PingResponse(
        serverTime: j['serverTime'] as String,
        timezone: j['timezone'] as String,
        minApkVersion: j['minApkVersion'] as String,
        latestApkVersion: j['latestApkVersion'] as String,
        maintenance: j['maintenance'] as bool,
        maintenanceMessage: j['maintenanceMessage'] as String? ?? '',
      );
}
