import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kematian.dart'; // Pastikan path ini benar
import '../API/BaseURL.dart'; // Pastikan path ini benar

// Anda bisa menambahkan list global jika diperlukan, seperti pada contoh Kunjungan
// List<Kematian> daftarKematianGlobal = [];

class KematianService {
  // --- CREATE ---
  // Mengembalikan true jika sukses, false jika gagal.
  Future<bool> createKematian(Map<String, dynamic> data) async {
    try {
      var request = http.Request(
        'POST',
        Uri.parse('$base_url/kematian'), // Menggunakan base_url
      );
      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      });
      request.body = json.encode(data);

      http.StreamedResponse response = await request.send();

      // API Resource Controller biasanya mengembalikan 201 untuk create
      if (response.statusCode == 201) {
        print('Data kematian berhasil dibuat. Status: ${response.statusCode}');
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
          'Gagal membuat data kematian. Status: ${response.statusCode}, Body: $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat membuat data kematian: $e');
      return false;
    }
  }

  // --- DELETE ---
  // Mengembalikan true jika sukses, false jika gagal.
  Future<bool> deleteKematian(int id) async {
    try {
      var request = http.Request('DELETE', Uri.parse('$base_url/kematian/$id'));
      request.headers.addAll({'Accept': 'application/json'});

      http.StreamedResponse response = await request.send();

      // API Resource Controller biasanya mengembalikan 200 atau 204 untuk delete
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Data kematian berhasil dihapus. Status: ${response.statusCode}');
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
          'Gagal menghapus data kematian. Status: ${response.statusCode}, Body: $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat menghapus data kematian: $e');
      return false;
    }
  }

  // --- GET (Contoh Tambahan) ---
  // Fungsi ini bisa Anda tambahkan jika API Anda menyediakan endpoint untuk GET
  Future<Kematian?> getKematian(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/kematian/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse = json.decode(response.body);
        return Kematian.fromJson(decodedResponse['data']);
      } else if (response.statusCode == 404) {
        // Ini adalah kasus yang wajar: tidak ada data kematian untuk balita ini.
        // Kita kembalikan null secara diam-diam tanpa mencatat "error".
        return null;
      } else {
        // Untuk error lain, kita lempar exception agar bisa ditangani oleh FutureBuilder.
        print(
          'Gagal memuat data kematian: ${response.statusCode} ${response.reasonPhrase}',
        );
        throw Exception(
          'Gagal memuat data kematian: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Terjadi exception saat mengambil data kematian: $e');
      // Lempar kembali exception agar UI bisa menampilkan state error.
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  // --- UPDATE (Contoh Tambahan) ---
  // Fungsi ini bisa Anda tambahkan jika API Anda menyediakan endpoint untuk UPDATE
  Future<bool> updateKematian(int id, Map<String, dynamic> data) async {
    try {
      var request = http.Request('PUT', Uri.parse('$base_url/kematian/$id'));
      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      });
      request.body = json.encode(data);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(
          'Data kematian berhasil diperbarui. Status: ${response.statusCode}',
        );
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
          'Gagal memperbarui data kematian. Status: ${response.statusCode}, Body: $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi exception saat memperbarui data kematian: $e');
      return false;
    }
  }
}
