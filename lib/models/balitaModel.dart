class BalitaModel {
  int? id;
  String nama;
  String nik;
  DateTime tanggalLahir;
  String alamat;
  String jenisKelamin;
  int posyanduId;
  String bukuKIA;
  BalitaModel({
    this.id,
    required this.nama,
    required this.nik,
    required this.tanggalLahir,
    required this.alamat,
    required this.jenisKelamin,
    required this.posyanduId,
    required this.bukuKIA,
  });

  BalitaModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      nama = json['nama'],
      nik = json['nik'],
      tanggalLahir = DateTime.parse(json['tanggal_lahir']),
      alamat = json['alamat'],
      jenisKelamin = json['jenis_kelamin'],
      posyanduId = json['posyandu_id'],
      bukuKIA = json['buku_kia'];
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nama'] = nama;
    data['nik'] = nik;
    data['tanggal_lahir'] = tanggalLahir.toIso8601String();
    data['alamat'] = alamat;
    data['jenis_kelamin'] = jenisKelamin;
    data['posyandu_id'] = posyanduId;
    data['buku_kia'] = bukuKIA;
    return data;
  }
}

List<BalitaModel> BalitaList = [];
