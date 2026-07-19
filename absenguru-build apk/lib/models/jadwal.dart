class JadwalItem {
  final String id;
  final int jamKe;
  final String kelasNama;
  final String? kelasTingkat;
  final String mapelNama;

  JadwalItem({
    required this.id,
    required this.jamKe,
    required this.kelasNama,
    this.kelasTingkat,
    required this.mapelNama,
  });

  factory JadwalItem.fromJson(Map<String, dynamic> json) {
    return JadwalItem(
      id: json['id']?.toString() ?? '',
      jamKe: json['jamKe'] ?? 0,
      kelasNama: json['kelas']?['nama'] ?? '-',
      kelasTingkat: json['kelas']?['tingkat']?.toString(),
      mapelNama: json['mapel']?['nama'] ?? '-',
    );
  }
}
