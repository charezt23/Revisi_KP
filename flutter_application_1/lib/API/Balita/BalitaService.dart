import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Balitaservice {
  GetBalita(id) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse(base_url + '/balita?posyandu_id=${id}'),
      );

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> responDecode = json.decode(responseData);
        List<dynamic> data = responDecode['data'];
        BalitaList.clear();
        for (var item in data) {
          BalitaList.add(BalitaModel.fromJson(item));
        }
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print(e);
    }
  }
}
