import 'package:provider/provider.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

class totalSalesProvider with ChangeNotifier {
  int _totalSales = 0; //_totalSales의 초기값
  int get totalSales => _totalSales; //_totalSales의 getter 메소드

  set totalSales(int value) {
    //_totalSales의 setter 메소드
    _totalSales = value; // 값 설정.
    notifyListeners(); //_totalSales값 변경 시 적용.
  }
}
//totalSalesProvider클래스의 초기 값을 당월의 누적매출로 설정
