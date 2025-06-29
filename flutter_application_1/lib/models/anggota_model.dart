class Anggota {
  int? id;
  int kohortId;
  String nama;
  String? nik;
  DateTime? tanggalLahir;
  String? jenisKelamin;
  String? namaOrangTua;
  String? alamat;
  String keterangan;
  String riwayatPenyakit;

  Anggota({
    this.id,
    required this.kohortId,
    required this.nama,
    this.nik,
    this.tanggalLahir,
    this.jenisKelamin,
    this.namaOrangTua,
    this.alamat,
    this.keterangan = '',
    this.riwayatPenyakit = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kohortId': kohortId,
      'nama': nama,
      'nik': nik,
      'tanggalLahir': tanggalLahir?.toIso8601String(),
      'jenisKelamin': jenisKelamin,
      'namaOrangTua': namaOrangTua,
      'alamat': alamat,
      'keterangan': keterangan,
      'riwayatPenyakit': riwayatPenyakit,
    };
  }

  factory Anggota.fromMap(Map<String, dynamic> map) {
    return Anggota(
      id: map['id'],
      kohortId: map['kohortId'],
      nama: map['nama'],
      nik: map['nik'],
      tanggalLahir: map['tanggalLahir'] != null
          ? DateTime.parse(map['tanggalLahir'])
          : null,
      jenisKelamin: map['jenisKelamin'],
      namaOrangTua: map['namaOrangTua'],
      alamat: map['alamat'],
      keterangan: map['keterangan'],
      riwayatPenyakit: map['riwayatPenyakit'] ?? '',
    );
  }
}
