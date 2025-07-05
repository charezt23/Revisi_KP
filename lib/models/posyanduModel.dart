class PosyanduModel {
  int? id;
  int? userId;
  String namaPosyandu;
  String namaDesa;
  DateTime? createdAt;
  DateTime? updatedAt;

  PosyanduModel({
    this.id,
    this.userId,
    required this.namaPosyandu,
    required this.namaDesa,
    this.createdAt,
    this.updatedAt,
  });

  PosyanduModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      userId = json['user_id'],
      namaPosyandu = json['nama_posyandu'],
      namaDesa = json['nama_desa'],
      createdAt =
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt =
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['nama_posyandu'] = namaPosyandu;
    data['nama_desa'] = namaDesa;
    data['created_at'] = createdAt?.toIso8601String();
    data['updated_at'] = updatedAt?.toIso8601String();
    return data;
  }
}
