import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:check_app_version/models/json_file.dart';
import 'package:http/http.dart' as http;

export 'components/componenets.dart';
export 'models/json_file.dart';
export 'utils/utils.dart';

class CheckAppVersion {
  factory CheckAppVersion() {
    return instance;
  }

  CheckAppVersion._internal();

  late JsonFile appFile;

  static final CheckAppVersion instance = CheckAppVersion._internal();

  bool _isJson(String input) {
    try {
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
        log('Http error $error');
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
        log('File error $error');
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
  }
}
