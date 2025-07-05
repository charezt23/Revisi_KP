class Kunjungan {
  int? id;
  final int anggotaId;
  final DateTime tanggalKunjungan;
  final String penyebab;

  Kunjungan({
    this.id,
    required this.anggotaId,
    required this.tanggalKunjungan,
    required this.penyebab,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anggotaId': anggotaId,
      'tanggalKunjungan': tanggalKunjungan.toIso8601String(),
      'penyebab': penyebab,
    };
  }

  factory Kunjungan.fromMap(Map<String, dynamic> map) {
    return Kunjungan(
      id: map['id'],
      anggotaId: map['anggotaId'],
      tanggalKunjungan: DateTime.parse(map['tanggalKunjungan']),
      penyebab: map['penyebab'],
    );
  }
}
