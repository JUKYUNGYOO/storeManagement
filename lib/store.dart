// 필요한 패키지들을 임포트합니다.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

// Store 클래스를 정의합니다.
class Store {
  final String id;
  final String name;

  // Store 생성자를 정의합니다.
  Store({required this.name, required this.id});

  // JSON 데이터를 Store 객체로 변환하는 메서드입니다.
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id']['\$oid'] as String, // oid를 사용하여 ID를 추출합니다.
      name: json['name'] as String, // 이름을 추출합니다.
    );
  }
}

// 모든 상점 정보를 불러오는 함수입니다.
Future<List<Store>> fetchStores(BuildContext context) async {
  // 액세스 토큰을 가져옵니다.
  final String accessToken =
      Provider.of<tokenModel>(context, listen: false).accessToken;

  // API URL을 설정합니다.
  // final String url = "http://192.168.0.171:10000/api/v1/stores/info";
  final String url = "https://storepop.io/api/v2/worker/stores/info";

  // API를 호출합니다.
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken', // 헤더에 토큰을 포함시킵니다.
    },
  );

  // 응답 상태 코드가 200이면 데이터를 반환하고, 그렇지 않으면 예외를 발생시킵니다.
  if (response.statusCode == 200) {
    List<dynamic> responseBody = json.decode(response.body)['data'];
    return responseBody.map((dynamic item) => Store.fromJson(item)).toList();
  } else {
    throw Exception('상점 정보를 불러오는데 실패했습니다.');
  }
}

// QR control을 위해 POST 요청을 하는 함수입니다.
Future<void> postQRControl(BuildContext context, String storeId) async {
  // 액세스 토큰을 가져옵니다.
  final String accessToken =
      Provider.of<tokenModel>(context, listen: false).accessToken;

  // API URL을 설정합니다.
  final String url = "https://storepop.io/api/v2/worker/control/qr";

  // API에 POST 요청을 보냅니다.
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      "store_id": {"\$oid": storeId} // 요청 본문에 상점 ID를 포함시킵니다.
    }),
  );
  {
    // "data": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2OTMzNTc2ODQsInN0b3JlX29pZCI6eyIkb2lkIjoiNjM4NmY4Njk0MTEwNjMzMDU5ODMwMzIwIn19.cahQJQps1tJL8JYCl5NwaO3zjFNBdyComdRLeZ8S8iQ"
  }

  // 응답 상태 코드가 200이 아니면 예외를 발생시킵니다.
  if (response.statusCode != 200) {
    throw Exception('QR control에 POST 요청하는데 실패했습니다.');
  }
}

// 모든 상점을 로드하고 각각의 상점에 대한 정보를 출력하는 함수입니다.
void _loadStores(BuildContext context) async {
  List<Store> stores = await fetchStores(context);
  for (var store in stores) {
    print("ID: ${store.id}, 이름: ${store.name}");
    await postQRControl(context, store.id);
  }
}
