import 'admin.dart';

class AdminAbsensiRow {
  final String jadwalId;
  final int jamKe;
  final String kelasNama;
  final String mapelNama;
  final GuruRingkas guruAsal;

  // Status saat ini (null kalau belum diabsen)
  final String? statusGuru; // hadir | diganti | tidak_hadir
  final String? subStatus; // izin | alpa
  final String? keterangan;
  final GuruRingkas? guruPengganti;

  AdminAbsensiRow({
    required this.jadwalId,
    required this.jamKe,
    required this.kelasNama,
    required this.mapelNama,
    required this.guruAsal,
    this.statusGuru,
    this.subStatus,
    this.keterangan,
    this.guruPengganti,
  });

  bool get sudahDiabsen => statusGuru != null;

  factory AdminAbsensiRow.fromJson(Map<String, dynamic> json) {
    final absensi = json['absensi'] as Map<String, dynamic>?;
    return AdminAbsensiRow(
      jadwalId: json['id']?.toString() ?? '',
      jamKe: json['jamKe'] ?? 0,
      kelasNama: json['kelas']?['nama'] ?? '-',
      mapelNama: json['mapel']?['nama'] ?? '-',
      guruAsal: GuruRingkas.fromJson(json['guru'] as Map<String, dynamic>? ?? {}),
      statusGuru: absensi?['statusGuru'],
      subStatus: absensi?['subStatus'],
      keterangan: absensi?['keterangan'],
      guruPengganti: absensi?['guruPengganti'] != null ? GuruRingkas.fromJson(absensi!['guruPengganti']) : null,
    );
  }
}
