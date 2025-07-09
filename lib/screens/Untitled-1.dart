import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/BalitaService.dart';
import 'package:flutter_application_1/API/ImunisasiService.dart';
import 'package:flutter_application_1/API/KunjunganBalitaService.dart';
import 'package:flutter_application_1/API/kematianService.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/models/imunisasi.dart';
import 'package:flutter_application_1/models/KunjunganBalitaModel.dart';
import 'package:flutter_application_1/models/kematian.dart';

class BalitaDetailProvider with ChangeNotifier {
  // Services
  final Balitaservice _balitaService = Balitaservice();
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  final ImunisasiService _imunisasiService = ImunisasiService();
  final KematianService _kematianService = KematianService();

  // State
  late BalitaModel _balita;
  List<KunjunganModel> _riwayatKunjungan = [];
  List<Imunisasi> _riwayatImunisasi = [];
  Kematian? _dataKematian;

  bool _isLoading = true; // Start with loading true
  String? _error;

  // Constructor
  BalitaDetailProvider(BalitaModel initialBalita) {
    _balita = initialBalita;
    fetchDetailData(); // Fetch data on initialization
  }

  // Getters
  BalitaModel get balita => _balita;
  List<KunjunganModel> get riwayatKunjungan => _riwayatKunjungan;
  List<Imunisasi> get riwayatImunisasi => _riwayatImunisasi;
  Kematian? get dataKematian => _dataKematian;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDeceased => _dataKematian != null;

  // --- LOGIC ---
  Future<void> fetchDetailData() async {
    _isLoading = true;
    _error = null;
    // Notify listeners at the start to show loading indicator
    notifyListeners();

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _balitaService.GetBalitaData(_balita.id!),
        _kunjunganService.GetKunjunganbalitaByBalita(_balita.id!),
        _imunisasiService.getImunisasiByBalita(_balita.id!),
        _kematianService.getKematian(_balita.id!),
      ]);

      // Update all state variables at once
      _balita = results[0] as BalitaModel;
      _riwayatKunjungan =
          (results[1] as List<KunjunganModel>)
            ..sort((a, b) => b.tanggalKunjungan.compareTo(a.tanggalKunjungan));
      _riwayatImunisasi =
          (results[2] as List<Imunisasi>)
            ..sort((a, b) => b.tanggalImunisasi.compareTo(a.tanggalImunisasi));
      _dataKematian = results[3] as Kematian?;
    } catch (e) {
      _error = "Gagal memuat detail data: $e";
      print(_error);
    } finally {
      _isLoading = false;
      // Notify listeners at the end to show the data or error
      notifyListeners();
    }
  }
}
