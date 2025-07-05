import 'dart:convert';
import 'package:flutter_application_1/API/BaseURL.dart';
import 'package:flutter_application_1/models/posyanduModel.dart';
import 'package:http/http.dart' as http;

class Posyanduservice {
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
}
