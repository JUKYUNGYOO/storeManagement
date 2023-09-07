//선택된 store_id 들을 관리하기 위한 클래스 정의
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);

class selectedStores with ChangeNotifier {
  List<String> _selectedStoreIds = [];
  List<String> get selectedStoreIds => _selectedStoreIds;

  void addStore(String storeId) {
    _selectedStoreIds.add(storeId);
    logger.i('Added selectedStores ID: $storeId');
    notifyListeners();
  }

  void removeStore(String storeId) {
    _selectedStoreIds.remove(storeId);
    logger.i('Removed selectedStores ID: $storeId');
    notifyListeners();
  }
}
