import 'dart:convert';
import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/models/KunjunganBalitaModel.dart';
import 'package:http/http.dart' as http;

class Kunjunganbalitaservice {
  Future<void> CreateKunjunganBalita(
    int balitaId,
    DateTime tanggalKunjungan,
    double beratBadan,
    double tinggiBadan,
    String statusGizi,
    String rambuGizi,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/kunjungan-balita'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'balita_id': balitaId,
          'tanggal_kunjungan': tanggalKunjungan.toIso8601String().split('T')[0],
          'berat_badan': beratBadan,
          'tinggi_badan': tinggiBadan,
          'Status_gizi': statusGizi,
          'rambu_gizi': rambuGizi,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        print('Error Body: ${response.body}');
        throw Exception(
          'Gagal membuat data kunjungan: ${response.reasonPhrase}',
        );
      }
      print('Data kunjungan berhasil dibuat.');
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<List<KunjunganModel>> GetKunjunganbalitaByBalita(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/kunjungan-balita/$id'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseDecode = json.decode(response.body);
        List<dynamic> data = responseDecode['data'];
        return data.map((item) => KunjunganModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Gagal memuat riwayat kunjungan: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<void> UpdateKunjunganBalita(
    int id,
    int balitaId,
    DateTime tanggalKunjungan,
    double beratBadan,
    double tinggiBadan,
    String statusGizi,
    String rambuGizi,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/kunjungan-balita/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'balita_id': balitaId,
          'tanggal_kunjungan': tanggalKunjungan.toIso8601String().split('T')[0],
          'berat_badan': beratBadan,
          'tinggi_badan': tinggiBadan,
          'Status_gizi': statusGizi,
          'rambu_gizi': rambuGizi,
        }),
      );

      if (response.statusCode != 200) {
        print('Error Body: ${response.body}');
        throw Exception(
          'Gagal memperbarui data kunjungan: ${response.reasonPhrase}',
        );
      }
      print('Data kunjungan berhasil diperbarui.');
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<void> DeleteKunjunganBalita(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$base_url/kunjungan-balita/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal menghapus data kunjungan: ${response.reasonPhrase}',
        );
      }
      print('Data kunjungan berhasil dihapus.');
    } catch (e) {
      print(e);
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}
