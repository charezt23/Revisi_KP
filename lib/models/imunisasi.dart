import 'dart:convert';

// Fungsi untuk decode list dari JSON
List<Imunisasi> imunisasiFromJson(String str) =>
    List<Imunisasi>.from(json.decode(str).map((x) => Imunisasi.fromJson(x)));

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
    // Format tanggal sesuai standar ISO 8601 (YYYY-MM-DD)
    "tanggal_imunisasi":
        "${tanggalImunisasi.year.toString().padLeft(4, '0')}-${tanggalImunisasi.month.toString().padLeft(2, '0')}-${tanggalImunisasi.day.toString().padLeft(2, '0')}",
  };
}
