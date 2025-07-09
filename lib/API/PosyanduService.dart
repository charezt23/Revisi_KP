import 'dart:convert';
import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/API/authservice.dart';
import 'package:flutter_application_1/models/posyanduModel.dart';
import 'package:http/http.dart' as http;

class Posyanduservice {
  Future<void> CreatePosyandu(String namaPosyandu, String namaDesa) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('Sesi pengguna tidak valid. Silakan login ulang.');
      }

      final response = await http.post(
        Uri.parse('$base_url/posyandu'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_posyandu': namaPosyandu,
          'nama_desa': namaDesa,
          'user_id': userId,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // Lemparkan exception dengan pesan error dari server jika ada
        throw Exception(
          'Gagal membuat Posyandu. Status: ${response.statusCode}, Pesan: ${response.body}',
        );
      }
    } catch (e) {
      print(e);
      // Lemparkan kembali error agar bisa ditangkap oleh UI
      rethrow;
    }
  }

  Future<List<PosyanduModel>> GetPosyanduByUser() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User tidak ditemukan, silakan login ulang.');
      }
      final response = await http.get(
        Uri.parse(base_url + '/posyandu/user/${userId}'),
      );

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        final Map<String, dynamic> responDecode = json.decode(response.body);
        final List<dynamic> data = responDecode['data'];
        print("Data: $data");

        // Konversi list json menjadi list PosyanduModel dan kembalikan
        return data.map((item) => PosyanduModel.fromJson(item)).toList();
      } else {
        print('Error: ${response.reasonPhrase}');
        // Lemparkan exception agar bisa ditangani oleh UI
        throw Exception(
          'Gagal mengambil data Posyandu: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print(e);
      // Lemparkan kembali exception agar UI tahu ada error
      rethrow;
    }
  }

  UpdatePosyandu(int id, String namaPosyandu, String namaDesa) async {
    try {
      var request = http.Request(
        'PUT',
        Uri.parse(base_url + '/posyandu/${id}'),
      );
      request.body = json.encode({
        'nama_posyandu': namaPosyandu,
        'nama_desa': namaDesa,
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
    }
  }

  DeletePosyandu(id) async {
    try {
      var request = http.Request(
        'DELETE',
        Uri.parse(base_url + '/posyandu/${id}'),
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
    }
  }
}
