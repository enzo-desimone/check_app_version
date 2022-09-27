import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:check_app_version/json_file.dart';
import 'package:http/http.dart' as http;

class CheckAppVersion {
  late JsonFile appFile;

  static final CheckAppVersion _singleton = CheckAppVersion._internal();

  factory CheckAppVersion() {
    return _singleton;
  }

  CheckAppVersion._internal();

  Future<bool> getJsonFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        appFile = JsonFile.fromJson(json.decode(response.body));
        return true;
      } else
        return false;
    } on Exception catch (error) {
      log(error.toString());
      return false;
    }
  }
}
