import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug,
);

class tokenModel extends ChangeNotifier {
  String _accessToken = '';
  String _refreshToken = '';

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;

  set setAccessToken(String value) {
    _accessToken = value;
    notifyListeners();
    logger.i('tokenModel AccessToken: $_accessToken');
  }

  set setRefreshToken(String value) {
    _refreshToken = value;
    notifyListeners();
    logger.i('tokenModel RefreshToken: $_refreshToken');
  }
}
