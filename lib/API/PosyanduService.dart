import 'dart:convert';
import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/models/posyanduModel.dart';
import 'package:http/http.dart' as http;

class Posyanduservice {
  CreatePosyandu(String namaPosyandu, String namaDesa, int userId) async {
    try {
      var request = http.Request('POST', Uri.parse(base_url + '/posyandu'));
      request.body = json.encode({
        'nama_posyandu': namaPosyandu,
        'nama_desa': namaDesa,
        'user_id': userId,
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

  GetPosyanduByUser(id) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse(base_url + '/posyandu/user/${id}'),
      );
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> responDecode = json.decode(responseData);
        List<dynamic> data = responDecode['data'];
        print("Data: $data");
        posyanduList.clear();
        for (var item in data) {
          posyanduList.add(PosyanduModel.fromJson(item));
        }
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print(e);
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
