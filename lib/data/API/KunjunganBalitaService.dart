import 'dart:convert';
import 'package:flutter_application_1/data/API/BaseURL.dart';
import 'package:flutter_application_1/data/models/KunjunganBalitaModel.dart';
import 'package:flutter_application_1/data/models/Zscore.dart';
import 'package:http/http.dart' as http;

class Kunjunganbalitaservice {
  Future<KunjunganModel> CreateKunjunganBalita(
    int balitaId,
    DateTime tanggalKunjungan,
    double beratBadan,
    double tinggiBadan,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/kunjungan-balita'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'balita_id': balitaId,
          // Menggunakan split('T')[0] untuk memastikan format tanggal YYYY-MM-DD
          'tanggal_kunjungan': tanggalKunjungan.toIso8601String().split('T')[0],
          'berat_badan': beratBadan.toStringAsFixed(2),
          'tinggi_badan': tinggiBadan.toStringAsFixed(2),
        }),
      );

      // Kode status 201 (Created) adalah standar untuk POST yang berhasil.
      // Kita juga cek 200 untuk kompatibilitas.
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Kunjungan berhasil dicatat. Status: ${response.statusCode}');
        // API yang baik akan mengembalikan data yang baru dibuat.
        // Kita parse dan kembalikan data tersebut.
        final responseData = json.decode(response.body);
        return KunjunganModel.fromJson(responseData['data']);
      } else {
        // Jika gagal, lemparkan Exception dengan pesan error dari server.
        throw Exception(
          'Gagal menyimpan kunjungan: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Lemparkan kembali exception agar bisa ditangani di UI.
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  Future<List<KunjunganModel>> GetKunjunganbalitaByBalita(id) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/kunjungan-balita/balita/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responDecode = json.decode(response.body);

        // Secara aman menangani 'data' yang bisa jadi List atau Map
        final dynamic dataValue = responDecode['data'];
        List<dynamic> dataList;

        if (dataValue is List) {
          dataList = dataValue;
        } else if (dataValue is Map<String, dynamic>) {
          // Jika API salah mengembalikan objek tunggal, bungkus dalam list.
          dataList = [dataValue];
        } else {
          // Jika data null atau bukan list/map, kembalikan list kosong agar aman.
          return [];
        }

        List<KunjunganModel> kunjunganList =
            dataList.map((item) => KunjunganModel.fromJson(item)).toList();

        // Kembalikan list secara langsung, jangan gunakan variabel global
        return kunjunganList;
      } else {
        print('Error: ${response.reasonPhrase}');
        // Lemparkan exception agar bisa ditangani oleh FutureBuilder di UI
        throw Exception(
          'Gagal memuat riwayat kunjungan: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print(e);
      throw Exception('Gagal memuat riwayat kunjungan: $e');
    }
  }

  UpdateKunjunganBalita(
    int id,
    int balitaId,
    DateTime tanggalKunjungan,
    double beratBadan,
    double tinggiBadan,
    String statusGizi,
    String rambuGizi,
  ) async {
    try {
      var request = http.Request(
        'PUT',
        Uri.parse(base_url + '/kunjungan-balita/${id}'),
      );
      request.body = json.encode({
        'balita_id': balitaId,
        'tanggal_kunjungan': tanggalKunjungan.toIso8601String(),
        'berat_badan': beratBadan.toStringAsFixed(2),
        'tinggi_badan': tinggiBadan.toStringAsFixed(2),
        'Status_gizi': statusGizi,
        'rambu_gizi': rambuGizi,
      });
      request.headers.addAll({'Content-Type': 'application/json'});
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        return true;
      } else {
        print('Error: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteKunjungan(int id) async {
    try {
      var request = http.Request(
        'DELETE',
        Uri.parse(base_url + '/kunjungan-balita/${id}'),
      );
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        return true;
      } else {
        print('Error: ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Zscore>> getZscore(int balitaId) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/kunjungan-balita/zcore/$balitaId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responDecode = json.decode(response.body);

        final dynamic dataValue = responDecode['data'];

        List<dynamic> dataList;

        if (dataValue is List) {
          dataList = dataValue;
        } else if (dataValue is Map<String, dynamic>) {
          // Jika API salah mengembalikan objek tunggal, bungkus dalam list.
          dataList = [dataValue];
        } else {
          // Jika data null atau bukan list/map, kembalikan list kosong agar aman.
          return [];
        }

        ZcoreList = dataList.map((item) => Zscore.fromJson(item)).toList();

        // Kembalikan list secara langsung, jangan gunakan variabel global
        return ZcoreList;
      } else {
        print('Error: ${response.reasonPhrase}');
        // Lemparkan exception agar bisa ditangani oleh FutureBuilder di UI
        throw Exception('Gagal memuat Z-score: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}
