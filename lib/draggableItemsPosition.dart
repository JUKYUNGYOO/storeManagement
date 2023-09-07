import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

//UI의 드래그 가능한 아이템의 위치를 추적
class draggableItemsPosition extends ChangeNotifier {
  // 상태 변경시 리스너에 알림을 위해 ChangeNotifier를 사용
  Map<String, Offset> positions = {};
  // 각 드래그 가능한 아이템의 위치를 저장하기 위한 맵

  bool _isDraggable = true;
  // 아이템이 드래그 가능 여부를 추적하는 private 필드

  // 이 함수를 사용하면 키를 사용하여 드래그 가능한 아이템의 위치를 설정
  void setPosition(String key, Offset offset) {
    positions[key] = offset; // 위치 정보
    notifyListeners();
  }

  // 키를 사용하여 드래그 가능한 아이템의 위치를 가져옴.
  Offset? getPosition(String key) {
    return positions[key];
    // 위치가 있으면 반환하고, 그렇지 않으면 null을 반환.
  }

  // 모든 드래그 가능한 아이템의 위치를 가져옴.
  Map<String, Offset> getAllPositions() {
    return positions; // 전체 맵을 반환.
  }

  // 아이템이 현재 드래그 가능한지 확인하는 getter.
  bool get isDraggable => _isDraggable;

  // 드래그 가능한 상태를 변경.
  void setDraggableStatus(bool value) {
    _isDraggable = value; // 드래그 가능한 상태를 업데이트.
    notifyListeners();
  }
}
