import 'dart:convert';

import 'package:flutter_application_1/data/API/BaseURL.dart';
import 'package:http/http.dart' as http;

// Fungsi untuk encode objek tunggal ke JSON
String kematianToJson(Kematian data) => json.encode(data.toJson());

class Kematian {
  final int id;
  final int balitaId;
  final DateTime tanggalKematian;
  final String penyebabKematian;

  Kematian({
    required this.id,
    required this.balitaId,
    required this.tanggalKematian,
    required this.penyebabKematian,
  });

  factory Kematian.fromJson(Map<String, dynamic> json) => Kematian(
    id: json["id"],
    balitaId: int.parse(json["balita_id"].toString()),
    tanggalKematian: DateTime.parse(json["tanggal_kematian"]),
    penyebabKematian: json["penyebab_kematian"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "balita_id": balitaId,
    "tanggal_kematian":
        "${tanggalKematian.year.toString().padLeft(4, '0')}-${tanggalKematian.month.toString().padLeft(2, '0')}-${tanggalKematian.day.toString().padLeft(2, '0')}",
    "penyebab_kematian": penyebabKematian,
  };
}

Future<List<Kematian>> getAllKematian() async {
  final response = await http.get(
    Uri.parse('$base_url/kematian'),
    headers: {'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final List data = decoded['data'];
    return data.map((e) => Kematian.fromJson(e)).toList();
  }
  return [];
}
