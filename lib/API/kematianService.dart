import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kematian.dart'; // Pastikan path ini benar
import '../API/BaseURL.dart'; // Pastikan path ini benar

/// Service untuk mengelola data kematian balita melalui API.
class KematianService {
  /// Membuat data kematian baru.
  /// Melemparkan Exception jika gagal.
  Future<void> createKematian(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/kematian'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      // API yang baik mengembalikan 201 (Created) saat sukses membuat data baru.
      if (response.statusCode != 201) {
        // Jika gagal, lemparkan exception dengan detail dari server.
        throw Exception(
          'Gagal membuat data kematian. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
      print('Data kematian berhasil dibuat.');
    } catch (e) {
      // Lempar kembali exception agar bisa ditangani di UI.
      throw Exception('Terjadi kesalahan saat membuat data kematian: $e');
    }
  }

  /// Menghapus data kematian berdasarkan ID balita.
  /// Melemparkan Exception jika gagal.
  Future<void> deleteKematian(int balitaId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$base_url/kematian/balita/$balitaId',
        ), // Endpoint disesuaikan
        headers: {'Accept': 'application/json'},
      );

      // Status 200 (OK) atau 204 (No Content) adalah tanda sukses.
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Gagal menghapus data kematian. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
      print('Data kematian berhasil dihapus.');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus data kematian: $e');
    }
  }

  /// Mengambil data kematian berdasarkan ID balita.
  /// Mengembalikan objek Kematian jika ada, atau null jika tidak ditemukan (404).
  Future<Kematian?> getKematian(int balitaId) async {
    try {
      // Pastikan endpoint Anda benar, biasanya berdasarkan ID balita
      final response = await http.get(
        Uri.parse('$base_url/kematian/balita/$balitaId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        // Pastikan response memiliki data sebelum di-parse
        if (decodedResponse['data'] != null) {
          return Kematian.fromJson(decodedResponse['data']);
        }
        return null; // Bisa jadi sukses tapi data kosong
      } else if (response.statusCode == 404) {
        // Kasus normal: tidak ada data kematian untuk balita ini.
        return null;
      } else {
        // Untuk error lain, lemparkan exception.
        throw Exception(
          'Gagal memuat data kematian: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// Memperbarui data kematian.
  /// Melemparkan Exception jika gagal.
  Future<void> updateKematian(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/kematian/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui data kematian. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
      print('Data kematian berhasil diperbarui.');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memperbarui data kematian: $e');
    }
  }
}
