import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class navExpandProvider with ChangeNotifier {
  bool _isSideNavExpanded = false;

  bool get isSideNavExpanded => _isSideNavExpanded;

  set isSideNavExpanded(bool value) {
    _isSideNavExpanded = value;
    notifyListeners();
  }
}
