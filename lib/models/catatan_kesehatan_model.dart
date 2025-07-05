class CatatanKesehatan {
  int? id;
  int anggotaId;
  DateTime tanggalCatatan;
  double? beratBadan; // kg
  double? tinggiBadan; // cm
  int? tekananSistolik; // misal: 120
  int? tekananDiastolik; // misal: 80
  String keluhan;

  CatatanKesehatan({
    this.id,
    required this.anggotaId,
    required this.tanggalCatatan,
    this.beratBadan,
    this.tinggiBadan,
    this.tekananSistolik,
    this.tekananDiastolik,
    this.keluhan = '',
  });
}