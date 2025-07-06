import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/imunisasi.dart'; // Pastikan path ini benar
import '../API/BaseURL.dart'; // Pastikan path ini benar

// Asumsi Anda memiliki list global seperti di Kunjunganbalitaservice
// Jika tidak, bagian ini bisa dihapus atau disesuaikan.
List<Imunisasi> daftarImunisasiGlobal = [];

class ImunisasiService {
  // --- CREATE ---
  // Mengembalikan true jika sukses, false jika gagal.
  Future<bool> createImunisasi(Map<String, dynamic> data) async {
    try {
      var request = http.Request(
        'POST',
        Uri.parse('$base_url/imunisasi'), // Menggunakan base_url dari file Anda
      );
      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      });
      request.body = json.encode(data);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        // Kode 201 untuk 'Created'
        print('Imunisasi berhasil dibuat. Status: ${response.statusCode}');
        return true;
      } else {
        // Membaca detail error dari body jika ada
        final responseBody = await response.stream.bytesToString();
        print(
          'Gagal membuat imunisasi. Status: ${response.statusCode}, Body: $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat membuat imunisasi: $e');
      return false;
    }
  }

  // --- GET ---
  // Mengambil data dan menyimpannya ke list global.
  // Mengembalikan list tersebut.
  Future<List<Imunisasi>> getImunisasiByBalita(int balitaId) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse('$base_url/imunisasi/balita/$balitaId'),
      );
      request.headers.addAll({'Accept': 'application/json'});

      http.StreamedResponse streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        var responseBody = await streamedResponse.stream.bytesToString();
        Map<String, dynamic> decodedResponse = json.decode(responseBody);

        if (decodedResponse['success'] == true) {
          List<dynamic> data = decodedResponse['data'];
          // Mengisi list global, mirip seperti KunjunganList
          daftarImunisasiGlobal =
              data.map((json) => Imunisasi.fromJson(json)).toList();
          return daftarImunisasiGlobal;
        } else {
          print('Gagal mengambil data: ${decodedResponse['message']}');
          return []; // Kembalikan list kosong jika API mengembalikan success: false
        }
      } else {
        print('Error server: ${streamedResponse.reasonPhrase}');
        return []; // Kembalikan list kosong jika status code bukan 200
      }
    } catch (e) {
      print('Terjadi exception saat mengambil imunisasi: $e');
      return []; // Kembalikan list kosong jika terjadi exception
    }
  }

  // --- UPDATE ---
  // Mengembalikan true jika sukses, false jika gagal.
  Future<bool> updateImunisasi(int id, Map<String, dynamic> data) async {
    try {
      var request = http.Request('PUT', Uri.parse('$base_url/imunisasi/$id'));
      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      });
      request.body = json.encode(data);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print('Imunisasi berhasil diperbarui. Status: ${response.statusCode}');
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
          'Gagal memperbarui imunisasi. Status: ${response.statusCode}, Body: $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat memperbarui imunisasi: $e');
      return false;
    }
  }

  // --- DELETE ---
  // Mengembalikan true jika sukses, false jika gagal.
  Future<bool> deleteImunisasi(int id) async {
    try {
      var request = http.Request(
        'DELETE',
        Uri.parse('$base_url/imunisasi/$id'),
      );
      request.headers.addAll({'Accept': 'application/json'});

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print('Imunisasi berhasil dihapus. Status: ${response.statusCode}');
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
          'Gagal menghapus imunisasi. Status: ${response.statusCode}, Body: $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat menghapus imunisasi: $e');
      return false;
    }
  }
}
