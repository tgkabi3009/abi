import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/mobile_api_service.dart';

/// Provider untuk data dashboard (home screen).
class DashboardProvider extends ChangeNotifier {
  DashboardResponse? _data;
  bool _loading = false;
  String? _error;

  DashboardResponse? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await MobileApiService.instance.getDashboard();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Dashboard] refresh error: $e');
    }
    _loading = false;
    notifyListeners();
  }
}

/// Provider untuk jadwal mengajar.
class JadwalProvider extends ChangeNotifier {
  Map<String, List<JadwalItem>> _jadwal = {};
  List<JamPelajaran> _jamPelajaran = [];
  bool _loading = false;
  String? _error;

  Map<String, List<JadwalItem>> get jadwal => _jadwal;
  List<JamPelajaran> get jamPelajaran => _jamPelajaran;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        MobileApiService.instance.getJadwal(),
        MobileApiService.instance.getJamPelajaran(),
      ]);
      _jadwal = results[0] as Map<String, List<JadwalItem>>;
      _jamPelajaran = results[1] as List<JamPelajaran>;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Jadwal] refresh error: $e');
    }
    _loading = false;
    notifyListeners();
  }
}

/// Provider untuk absensi (harian & bulanan).
class AbsensiProvider extends ChangeNotifier {
  AbsensiHarianResponse? _harian;
  AbsensiBulananResponse? _bulanan;
  List<HariEfektif> _hariEfektif = [];
  bool _loading = false;
  String? _error;

  AbsensiHarianResponse? get harian => _harian;
  AbsensiBulananResponse? get bulanan => _bulanan;
  List<HariEfektif> get hariEfektif => _hariEfektif;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadHarian({String? tanggal}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _harian = await MobileApiService.instance.getAbsensiHarian(tanggal: tanggal);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Absensi] harian error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadBulanan({String? bulan}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _bulanan = await MobileApiService.instance.getAbsensiBulanan(bulan: bulan);
      _hariEfektif = await MobileApiService.instance.getHariEfektif(bulan: bulan);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Absensi] bulanan error: $e');
    }
    _loading = false;
    notifyListeners();
  }
}

/// Provider untuk slip gaji (list + detail).
class GajiProvider extends ChangeNotifier {
  List<SlipRingkas> _slipList = [];
  SlipDetail? _detail;
  bool _loading = false;
  String? _error;

  List<SlipRingkas> get slipList => _slipList;
  SlipDetail? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadList() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _slipList = await MobileApiService.instance.getPeriodeGaji();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Gaji] list error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadDetail(String id) async {
    _loading = true;
    _error = null;
    _detail = null;
    notifyListeners();
    try {
      _detail = await MobileApiService.instance.getSlipDetail(id);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Gaji] detail error: $e');
    }
    _loading = false;
    notifyListeners();
  }
}

/// Provider untuk notifikasi.
class NotifikasiProvider extends ChangeNotifier {
  List<Notifikasi> _list = [];
  bool _loading = false;
  String? _error;

  List<Notifikasi> get list => _list;
  bool get loading => _loading;
  String? get error => _error;

  int get unreadCount => _list.length; // tidak ada ack state — anggap semua "baru"

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _list = await MobileApiService.instance.getNotifikasi();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Notifikasi] refresh error: $e');
    }
    _loading = false;
    notifyListeners();
  }
}

/// Provider untuk profil madrasah (cached, jarang berubah).
class MadrasahProvider extends ChangeNotifier {
  ProfilMadrasah? _profil;
  MadrasahInfo? _infoBasic;
  bool _loading = false;
  String? _error;

  ProfilMadrasah? get profil => _profil;
  MadrasahInfo? get infoBasic => _infoBasic;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profil = await MobileApiService.instance.getProfilMadrasah();
      _infoBasic = _profil!.madrasah;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) debugPrint('[Madrasah] load error: $e');
    }
    _loading = false;
    notifyListeners();
  }
}
