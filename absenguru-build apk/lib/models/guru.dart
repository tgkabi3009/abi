class Guru {
  final String id;
  final String kodeNama;
  final String nama;
  final String? nik;
  final String? mapelUtama;
  final String tipeGuru;
  final String? tipeGuruLabel;
  final num tarifPerJam;
  final String? status;

  Guru({
    required this.id,
    required this.kodeNama,
    required this.nama,
    this.nik,
    this.mapelUtama,
    required this.tipeGuru,
    this.tipeGuruLabel,
    required this.tarifPerJam,
    this.status,
  });

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      id: json['id']?.toString() ?? '',
      kodeNama: json['kodeNama'] ?? '',
      nama: json['nama'] ?? '',
      nik: json['nik'],
      mapelUtama: json['mapelUtama'] != null ? json['mapelUtama']['nama'] : null,
      tipeGuru: json['tipeGuru'] ?? '',
      tipeGuruLabel: json['tipeGuruLabel'],
      tarifPerJam: json['tarifPerJam'] ?? 0,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kodeNama': kodeNama,
      'nama': nama,
      'nik': nik,
      'mapelUtama': mapelUtama != null ? {'nama': mapelUtama} : null,
      'tipeGuru': tipeGuru,
      'tipeGuruLabel': tipeGuruLabel,
      'tarifPerJam': tarifPerJam,
      'status': status,
    };
  }
}
