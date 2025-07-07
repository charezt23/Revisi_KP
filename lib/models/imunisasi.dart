import 'dart:convert';

import 'package:flutter_application_1/models/balitaModel.dart';

// Fungsi untuk decode list dari JSON (Sudah diperbarui dan aman dari null)
List<Imunisasi> imunisasiFromJson(String? str, {required BalitaModel balita}) {
  // Jika string JSON null, kosong, atau berisi 'null', kembalikan list kosong.
  if (str == null || str.isEmpty || str == 'null') {
    return [];
  }

  final data = json.decode(str);

  // Jika hasil decode adalah null (bisa terjadi jika JSON adalah string "null"),
  // kembalikan juga list kosong.
  if (data == null) {
    return [];
  }

  // Jika semua aman, lanjutkan proses parsing seperti biasa.
  return List<Imunisasi>.from(data.map((x) => Imunisasi.fromJson(x)));
}

// Fungsi untuk encode objek tunggal ke JSON
String imunisasiToJson(Imunisasi data) => json.encode(data.toJson());

class Imunisasi {
  final int id;
  final int balitaId;
  final String jenisImunisasi;
  final DateTime tanggalImunisasi;

  Imunisasi({
    required this.id,
    required this.balitaId,
    required this.jenisImunisasi,
    required this.tanggalImunisasi,
  });

  factory Imunisasi.fromJson(Map<String, dynamic> json) => Imunisasi(
    id: json["id"],
    balitaId: int.parse(json["balita_id"].toString()), // Konversi aman
    jenisImunisasi: json["jenis_imunisasi"],
    tanggalImunisasi: DateTime.parse(json["tanggal_imunisasi"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "balita_id": balitaId,
    "jenis_imunisasi": jenisImunisasi,
    "tanggal_imunisasi":
        "${tanggalImunisasi.year.toString().padLeft(4, '0')}-${tanggalImunisasi.month.toString().padLeft(2, '0')}-${tanggalImunisasi.day.toString().padLeft(2, '0')}",
  };
}
