import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:check_app_version/models/json_file.dart';
import 'package:http/http.dart' as http;

class CheckAppVersion {
  late JsonFile appFile;

  static final CheckAppVersion _singleton = CheckAppVersion._internal();

  factory CheckAppVersion() {
    return _singleton;
  }

  CheckAppVersion._internal();

  bool _isJson(String input) {
    try {
      // final obj = json.decode(input);
      final obj = json.decode(input);
      if (obj is Map<String, dynamic>) {
        return true;
      }
    } on FormatException {
      return false;
    }
    return false;
  }

  bool _isUrl(String input) {
    try {
      Uri.parse(input);
      return true;
    } on FormatException {
      return false;
    }
  }

  bool _isFile(String input) {
    try {
      final uri = Uri.parse(input);
      return uri.scheme == 'file';
    } on FormatException {
      return false;
    }
  }

  /// getJsonFile, input from, url, file, string
  ///
  /// url,  http://127.0.0.1/version.json
  /// file, file:///path/to/file.json
  /// string, {"app_name": "", "new_app_version": "1.5.0", "new_app_code": "36"}
  ///
  Future<bool> getJsonFile(String input) async {
    var raw = '';
    if (_isUrl(input)) {
      try {
        final response = await http.get(Uri.parse(input));
        if (response.statusCode == 200) {
          raw = response.body;
        }
      } on Exception catch (error) {
        log('Http error ${error.toString()}');
        return false;
      }
    }

    if (_isFile(input)) {
      try {
        final file = File(input);
        if (await file.exists()) {
          raw = await file.readAsString();
        } else {
          log('File notfound $input');
          return false;
        }
      } catch (error) {
        log('File error ${error.toString()}');
        return false;
      }
    }

    if (_isJson(input)) {
      raw = input;
    }

    if (raw.isNotEmpty && _isJson(raw)) {
      appFile = JsonFile.fromJson(json.decode(raw));
      return true;
    }

    log('Input error: invalid input');
    return false;

    // ufn.lastline
  }

/*
  Future<bool> getJsonFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        appFile = JsonFile.fromJson(json.decode(response.body));
        return true;
      } else
        return false;
    } on Exception catch (error) {
      log('Http error ${error.toString()}');
      return false;
    }
  }
*/

  // cls.lastline
}
