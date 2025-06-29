import 'package:flutter_application_1/models/anggota_model.dart';
import 'package:flutter_application_1/models/kohort_model.dart';
import '../models/pemeriksaan_model.dart';

// Menggunakan pola Singleton agar state (data dummy) konsisten di seluruh aplikasi.
class DummyDataService {
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;

  DummyDataService._internal();

  final List<Kohort> _dummyKohorts = [
    Kohort(
      id: 1,
      nama: 'Kohort Balita Melati',
      tanggalDibuat: DateTime(2024, 1, 1),
    ),
    Kohort(
      id: 2,
      nama: 'Kohort Lansia Sehat',
      tanggalDibuat: DateTime(2024, 2, 15),
    ),
  ];

  final List<Anggota> _dummyAnggota = [
    // Anggota untuk Kohort 1 (Balita)
    Anggota(
      id: 1,
      kohortId: 1,
      nama: 'Budi Santoso',
      nik: '3201011204230001',
      tanggalLahir: DateTime(2023, 4, 12),
      jenisKelamin: 'L',
      namaOrangTua: 'Bapak Santoso',
      alamat: 'Jl. Merdeka No. 10',
      riwayatPenyakit: 'Batuk pilek ringan',
    ),
    Anggota(
      id: 2,
      kohortId: 1,
      nama: 'Sinta Putri',
      nik: '3201012508220002',
      tanggalLahir: DateTime(2022, 8, 25),
      jenisKelamin: 'P',
      namaOrangTua: 'Ibu Putri',
      alamat: 'Jl. Pahlawan No. 5',
      riwayatPenyakit: '',
    ),
    Anggota(
      id: 3,
      kohortId: 1,
      nama: 'Ahmad Riyadi',
      nik: '3201010101240003',
      tanggalLahir: DateTime(2024, 1, 1),
      jenisKelamin: 'L',
      namaOrangTua: 'Bapak Riyadi',
      alamat: 'Jl. Kemerdekaan No. 17',
      riwayatPenyakit: 'Asma',
    ),

    // Anggota untuk Kohort 2 (Lansia)
    Anggota(
      id: 4,
      kohortId: 2,
      nama: 'Eko Prasetyo',
      nik: '3201011005600004',
      tanggalLahir: DateTime(1960, 5, 10),
      jenisKelamin: 'L',
      alamat: 'Jl. Sejahtera No. 1',
      riwayatPenyakit: 'Hipertensi',
    ),
    Anggota(
      id: 5,
      kohortId: 2,
      nama: 'Wati Susanti',
      nik: '3201011507620005',
      tanggalLahir: DateTime(1962, 7, 15),
      jenisKelamin: 'P',
      alamat: 'Jl. Makmur No. 2',
      riwayatPenyakit: 'Diabetes',
    ),
  ];

  final List<Pemeriksaan> _dummyPemeriksaan = [
    // Data untuk Budi Santoso (anggotaId: 1)
    Pemeriksaan(
      id: 101,
      anggotaId: 1,
      tanggalPemeriksaan: DateTime(2024, 5, 15),
      beratBadan: 9.5,
      tinggiBadan: 75.0,
      keterangan: 'Sehat',
    ),
    Pemeriksaan(
      id: 102,
      anggotaId: 1,
      tanggalPemeriksaan: DateTime(2024, 6, 15),
      beratBadan: 9.8,
      tinggiBadan: 76.5,
      keterangan: 'Nafsu makan baik',
    ),

    // Data untuk Sinta Putri (anggotaId: 2)
    Pemeriksaan(
      id: 201,
      anggotaId: 2,
      tanggalPemeriksaan: DateTime(2024, 5, 15),
      beratBadan: 12.1,
      tinggiBadan: 87.0,
      keterangan: 'Aktif',
    ),
    Pemeriksaan(
      id: 202,
      anggotaId: 2,
      tanggalPemeriksaan: DateTime(2024, 6, 15),
      beratBadan: 12.3,
      tinggiBadan: 88.0,
      keterangan: 'Imunisasi lengkap',
    ),
  ];

  // --- METHOD YANG MENIRU DATABASEHELPER ---
  // --- FUNGSI UNTUK KOHORT ---
  Future<List<Kohort>> getKohortList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyKohorts;
  }

  Future<void> insertKohort(Kohort kohort) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId =
        (_dummyKohorts.isNotEmpty
            ? _dummyKohorts.map((k) => k.id!).reduce((a, b) => a > b ? a : b)
            : 0) +
        1;
    kohort.id = newId;
    _dummyKohorts.add(kohort);
    print('DUMMY: Menambahkan kohort baru -> ${kohort.nama}');
  }

  // --- FUNGSI UNTUK ANGGOTA ---
  Future<List<Anggota>> getAnggotaList(int kohortId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyAnggota.where((a) => a.kohortId == kohortId).toList();
  }

  Future<int> getAnggotaCount(int kohortId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummyAnggota.where((a) => a.kohortId == kohortId).length;
  }

  Future<void> insertAnggota(Anggota anggota) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId =
        (_dummyAnggota.isNotEmpty
            ? _dummyAnggota.map((a) => a.id!).reduce((a, b) => a > b ? a : b)
            : 0) +
        1;
    anggota.id = newId;
    _dummyAnggota.add(anggota);
    print('DUMMY: Menambahkan anggota baru -> ${anggota.nama}');
  }

  Future<void> deleteAnggota(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Hapus juga data pemeriksaan yang terkait untuk menjaga integritas data
    _dummyPemeriksaan.removeWhere((p) => p.anggotaId == id);
    _dummyAnggota.removeWhere((a) => a.id == id);
    print('DUMMY: Menghapus anggota dengan id -> $id');
  }

  // --- FUNGSI UNTUK PEMERIKSAAN ---
  Future<List<Pemeriksaan>> getPemeriksaanList(int anggotaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = _dummyPemeriksaan
        .where((p) => p.anggotaId == anggotaId)
        .toList();
    // Urutkan dari yang terbaru
    results.sort(
      (a, b) => b.tanggalPemeriksaan.compareTo(a.tanggalPemeriksaan),
    );
    return results;
  }

  Future<void> insertPemeriksaan(Pemeriksaan pemeriksaan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId =
        (_dummyPemeriksaan.isNotEmpty
            ? _dummyPemeriksaan
                  .map((p) => p.id!)
                  .reduce((a, b) => a > b ? a : b)
            : 0) +
        1;
    pemeriksaan.id = newId;
    _dummyPemeriksaan.add(pemeriksaan);
    print(
      'DUMMY: Menambahkan pemeriksaan baru untuk anggotaId -> ${pemeriksaan.anggotaId}',
    );
  }
}
