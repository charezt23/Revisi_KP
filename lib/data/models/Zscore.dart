class Zscore {
  int? usia;
  String? zScore;
  String? statusGizi;

  Zscore({this.usia, this.zScore, this.statusGizi});

  Zscore.fromJson(Map<String, dynamic> json) {
    usia = json['usia'];
    zScore = json['z_score'];
    statusGizi = json['status_gizi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['usia'] = this.usia;
    data['z_score'] = this.zScore;
    data['status_gizi'] = this.statusGizi;
    return data;
  }
}

List<Zscore> ZcoreList = [];
