import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Balitaservice {
  Future<void> CreateBalita(
    String nama,
    String nik,
    DateTime tanggalLahir,
    String alamat,
    String jenisKelamin,
    int posyanduId,
    String namaIbu,
    String bukuKIA,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/balita'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "nama": nama,
          "nik": nik,
          "tanggal_lahir": tanggalLahir.toIso8601String().split('T')[0],
          "alamat": alamat,
          "jenis_kelamin": jenisKelamin,
          "posyandu_id": posyanduId,
          "nama_ibu": namaIbu,
          "Buku_KIA": bukuKIA,
        }),
      );

      // HTTP 201 Created adalah standar untuk POST yang berhasil
      if (response.statusCode != 201 && response.statusCode != 200) {
        print('Error Body: ${response.body}');
        throw Exception('Gagal membuat data balita: ${response.reasonPhrase}');
      }
      print('Data balita berhasil dibuat.');
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<BalitaModel> GetBalitaData(int id) async {
    try {
      final response = await http.get(Uri.parse('$base_url/balita/$id'));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseDecode = json.decode(response.body);
        return BalitaModel.fromJson(responseDecode['data']);
      } else {
        throw Exception('Gagal memuat data balita: ${response.reasonPhrase}');
      }
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<List<BalitaModel>> GetBalitaByPosyandu(id) async {
    try {
      final response = await http
          .get(Uri.parse(base_url + '/balita/posyandu/${id}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        Map<String, dynamic> responDecode = json.decode(response.body);
        List<dynamic> data = responDecode['data'];

        // Buat list dari data response dan kembalikan
        List<BalitaModel> balitaList =
            data.map((item) => BalitaModel.fromJson(item)).toList();
        return balitaList;
      } else {
        print('Error: ${response.reasonPhrase}');
        throw Exception('Gagal memuat data balita: ${response.reasonPhrase}');
      }
    } catch (e) {
      print(e);
      // Lempar kembali exception agar bisa ditangani oleh FutureBuilder
      throw Exception('Gagal memuat data balita: $e');
    }
  }

  Future<void> DeleteBalita(int id) async {
    try {
      final response = await http.delete(Uri.parse('$base_url/balita/$id'));

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal menghapus data balita: ${response.reasonPhrase}',
        );
      }
      print('Data balita berhasil dihapus.');
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<void> UpdateBalita(
    int id,
    String nama,
    String nik,
    DateTime tanggalLahir,
    String alamat,
    String jenisKelamin,
    int posyanduId,
    String namaIbu,
    String bukuKIA,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/balita/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "nama": nama,
          "nik": nik,
          "tanggal_lahir": tanggalLahir.toIso8601String().split('T')[0],
          "alamat": alamat,
          "jenis_kelamin": jenisKelamin,
          "posyandu_id": posyanduId,
          "nama_ibu": namaIbu,
          "Buku_KIA": bukuKIA,
        }),
      );

      if (response.statusCode != 200) {
        print('Error Body: ${response.body}');
        throw Exception(
          'Gagal memperbarui data balita: ${response.reasonPhrase}',
        );
      }
      print('Data balita berhasil diperbarui.');
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}
