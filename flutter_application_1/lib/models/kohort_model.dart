class Kohort {
  int? id;
  String nama;
  String alamat;
  String deskripsi;
  DateTime tanggalDibuat;

  Kohort({
    this.id,
    required this.nama,
    this.alamat = '',
    this.deskripsi = '',
    required this.tanggalDibuat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'deskripsi': deskripsi,
      'tanggalDibuat': tanggalDibuat.toIso8601String(),
    };
  }

  factory Kohort.fromMap(Map<String, dynamic> map) {
    return Kohort(
      id: map['id'],
      nama: map['nama'],
      alamat: map['alamat'],
      deskripsi: map['deskripsi'],
      tanggalDibuat: DateTime.parse(map['tanggalDibuat']),
    );
  }
}