import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Balitaservice {
  CreateBalita(
    nama,
    nik,
    tanggalLahir,
    alamat,
    jenisKelamin,
    posyanduId,
    bukuKIA,
  ) async {
    try {
      var request = http.Request('POST', Uri.parse(base_url + '/balita'));
      request.body = json.encode({
        "nama": nama,
        "nik": nik,
        "tanggal_lahir": tanggalLahir.toIso8601String(),
        "alamat": alamat,
        "jenis_kelamin": jenisKelamin,
        "posyandu_id": posyanduId,
        "Buku_KIA": bukuKIA,
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

  GetBalitaData(id) async {
    try {
      var request = http.Request('GET', Uri.parse(base_url + '/balita/${id}'));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> responDecode = json.decode(responseData);
        BalitaList.clear();
        BalitaList.add(BalitaModel.fromJson(responDecode['data']));
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print(e);
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
        print("Data: $data");

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

  DeleteBalita(id) async {
    try {
      var request = http.Request(
        'DELETE',
        Uri.parse(base_url + '/balita/${id}'),
      );
      print("Request URL: ${request.url}");

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

  UpdateBalita(
    id,
    nama,
    nik,
    tanggalLahir,
    alamat,
    jenisKelamin,
    posyanduId,
    bukuKIA,
  ) async {
    try {
      var request = http.Request('PUT', Uri.parse(base_url + '/balita/${id}'));
      request.body = json.encode({
        "nama": nama,
        "nik": nik,
        "tanggal_lahir": tanggalLahir.toIso8601String(),
        "alamat": alamat,
        "jenis_kelamin": jenisKelamin,
        "posyandu_id": posyanduId,
        "Buku_KIA": bukuKIA,
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
}
