class KunjunganModel {
  int? id;
  int balitaId;
  DateTime tanggalKunjungan;
  double beratBadan;
  double tinggiBadan;
  String statusGizi;
  String rambuGizi;

  KunjunganModel({
    this.id,
    required this.balitaId,
    required this.tanggalKunjungan,
    required this.beratBadan,
    required this.tinggiBadan,
    required this.statusGizi,
    required this.rambuGizi,
  });

  factory KunjunganModel.fromJson(Map<String, dynamic> json) {
    return KunjunganModel(
      id: json['id'],
      balitaId: json['balita_id'],
      tanggalKunjungan: DateTime.parse(json['tanggal_kunjungan']),
      // Parse double values from String
      beratBadan: double.parse(json['berat_badan']),
      tinggiBadan: double.parse(json['tinggi_badan']),
      statusGizi: json['Status_gizi'],
      rambuGizi: json['rambu_gizi'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['balita_id'] = balitaId;
    data['tanggal_kunjungan'] = tanggalKunjungan.toIso8601String();
    data['berat_badan'] = beratBadan.toStringAsFixed(
      2,
    ); // Keep two decimal places
    data['tinggi_badan'] = tinggiBadan.toStringAsFixed(
      2,
    ); // Keep two decimal places
    data['Status_gizi'] = statusGizi;
    data['rambu_gizi'] = rambuGizi;
    return data;
  }
}

List<KunjunganModel> KunjunganList = [];
