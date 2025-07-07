import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/ImunisasiService.dart';
import 'package:flutter_application_1/API/KunjunganBalitaService.dart';
import 'package:flutter_application_1/API/kematianService.dart';
import 'package:flutter_application_1/models/KunjunganBalitaModel.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/models/imunisasi.dart';
import 'package:flutter_application_1/models/kematian.dart';

enum JenisPemeriksaan { imunisasi, kunjungan, kematian }

class PemeriksaanItem {
  final DateTime tanggal;
  final String jenis;
  final dynamic data;

  PemeriksaanItem({
    required this.tanggal,
    required this.jenis,
    required this.data,
  });
}

// Wrapper class untuk menampung semua data yang di-fetch
class BalitaDetailData {
  final List<KunjunganModel> riwayatKunjungan;
  final List<Imunisasi> riwayatImunisasi;
  final Kematian? dataKematian;

  BalitaDetailData({
    required this.riwayatKunjungan,
    required this.riwayatImunisasi,
    this.dataKematian,
  });
}

class BalitaDetailScreen extends StatefulWidget {
  final BalitaModel balita;
  const BalitaDetailScreen({super.key, required this.balita});

  @override
  State<BalitaDetailScreen> createState() => _BalitaDetailScreenState();
}

class _BalitaDetailScreenState extends State<BalitaDetailScreen> {
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  final KematianService _kematianService = KematianService();
  final ImunisasiService _imunisasiService = ImunisasiService();
  late Future<BalitaDetailData> _detailData;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
