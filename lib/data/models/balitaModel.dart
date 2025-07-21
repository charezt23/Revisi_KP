import 'package:flutter_application_1/data/models/posyanduModel.dart';

class BalitaModel {
  int? id;
  String nama;
  String nik;
  DateTime tanggalLahir;
  String alamat;
  String jenisKelamin;
  String namaIbu;
  int posyanduId;
  String bukuKIA;
  PosyanduModel? posyandu;
  final DateTime? tanggalKematian;
  int? userId;
  bool? sudahImunisasi; // status imunisasi

  BalitaModel({
    this.id,
    required this.nama,
    required this.nik,
    required this.tanggalLahir,
    required this.alamat,
    required this.jenisKelamin,
    required this.namaIbu,
    required this.posyanduId,
    required this.bukuKIA,
    this.posyandu,
    this.tanggalKematian, // <-- TAMBAHKAN INI DI CONSTRUCTOR
    this.sudahImunisasi,
    this.userId,
  });

  factory BalitaModel.fromJson(Map<String, dynamic> json) {
    return BalitaModel(
      id: json['id'],
      nama: json['nama'],
      nik: json['nik'],
      namaIbu: json['nama_ibu'] ?? '',
      tanggalLahir: DateTime.parse(json['tanggal_lahir']),
      alamat: json['alamat'],
      jenisKelamin: json['jenis_kelamin'],
      posyanduId: json['posyandu_id'],
      bukuKIA: json['Buku_KIA'],
      posyandu:
          json['posyandu'] != null
              ? PosyanduModel.fromJson(json['posyandu'])
              : null,
      tanggalKematian:
          json['tanggal_kematian'] != null
              ? DateTime.parse(json['tanggal_kematian'])
              : null,
      userId: json['user_id'],
      sudahImunisasi:
          json['sudah_imunisasi'] == true || json['sudah_imunisasi'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama'] = nama;
    data['nik'] = nik;
    data['nama_ibu'] = namaIbu;
    data['tanggal_lahir'] = tanggalLahir.toIso8601String();
    data['alamat'] = alamat;
    data['jenis_kelamin'] = jenisKelamin;
    data['posyandu_id'] = posyanduId;
    data['Buku_KIA'] = bukuKIA;
    if (tanggalKematian != null) {
      data['tanggal_kematian'] = tanggalKematian!.toIso8601String();
    }
    if (userId != null) {
      data['user_id'] = userId;
    }
    data['sudah_imunisasi'] = sudahImunisasi;
    return data;
  }
}
