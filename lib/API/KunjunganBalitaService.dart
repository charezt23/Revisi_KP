import 'dart:convert';
import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/models/KunjunganBalitaModel.dart';
import 'package:http/http.dart' as http;

class Kunjunganbalitaservice {
  CreateKunjunganBalita(
    int balitaId,
    DateTime tanggalKunjungan,
    double beratBadan,
    double tinggiBadan,
    String statusGizi,
    String rambuGizi,
  ) async {
    try {
      var request = http.Request(
        'POST',
        Uri.parse(base_url + '/kunjungan-balita'),
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

  GetKunjunganbalitaByBalita(id) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse(base_url + '/kunjungan-balita/${id}'),
      );
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> responDecode = json.decode(responseData);
        KunjunganList.clear();
        KunjunganList.add(KunjunganModel.fromJson(responDecode['data']));
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print(e);
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

  DeleteKunjunganBalita(int id) async {
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
}
