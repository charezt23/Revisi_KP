class Pemeriksaan {
  int? id;
  int anggotaId;
  DateTime tanggalPemeriksaan;
  double beratBadan;
  double tinggiBadan;
  String keterangan;

  Pemeriksaan({
    this.id,
    required this.anggotaId,
    required this.tanggalPemeriksaan,
    required this.beratBadan,
    required this.tinggiBadan,
    this.keterangan = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anggotaId': anggotaId,
      'tanggalPemeriksaan': tanggalPemeriksaan.toIso8601String(),
      'beratBadan': beratBadan,
      'tinggiBadan': tinggiBadan,
      'keterangan': keterangan,
    };
  }

  factory Pemeriksaan.fromMap(Map<String, dynamic> map) {
    return Pemeriksaan(
      id: map['id'],
      anggotaId: map['anggotaId'],
      tanggalPemeriksaan: DateTime.parse(map['tanggalPemeriksaan']),
      beratBadan: map['beratBadan'],
      tinggiBadan: map['tinggiBadan'],
      keterangan: map['keterangan'],
    );
  }
}
