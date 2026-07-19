class AdminUser {
  final String id;
  final String username;
  final String name;
  final String role; // super_admin | admin

  AdminUser({required this.id, required this.username, required this.name, required this.role});

  bool get isSuperAdmin => role == 'super_admin';

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'admin',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'username': username, 'name': name, 'role': role};
}

/// Guru versi ringkas, dipakai untuk dropdown "guru pengganti".
class GuruRingkas {
  final String id;
  final String kodeNama;
  final String nama;

  GuruRingkas({required this.id, required this.kodeNama, required this.nama});

  factory GuruRingkas.fromJson(Map<String, dynamic> json) {
    return GuruRingkas(
      id: json['id']?.toString() ?? '',
      kodeNama: json['kodeNama'] ?? '',
      nama: json['nama'] ?? '',
    );
  }
}
