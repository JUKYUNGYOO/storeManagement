import 'dart:convert'; // JSON 인코딩 및 디코딩 메서드 제공
import 'package:flutter/material.dart'; // Flutter의 주요 머티리얼 디자인 패키지
import 'package:http/http.dart' as http; // 요청을 만들기 위한 HTTP 패키지
import 'package:logger/logger.dart'; // 정보와 오류를 기록하기 위한 로거
import 'package:adminapp/tokenModel.dart';
import 'package:provider/provider.dart'; // Provider를 사용한 상태 관리
import 'package:shared_preferences/shared_preferences.dart'; // 로컬에 키-값 쌍을 저장하기 위함
import 'package:qr_flutter/qr_flutter.dart'; // QR 코드 생성 및 표시를 위함
import 'package:adminapp/selectedStores.dart'; // 선택된 매장과 관련된 모델 또는 로직으로 추정됨
//사용하지 않음.

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);
// 저장된 리프레시 토큰을 사용하여 액세스 토큰을 새로 고침하는 함수
Future<String?> refreshAccessToken() async {
  // 로컬 저장소(SharedPreferences)에서 리프레시 토큰을 가져옴
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('refreshToken');

  // refreshToken이 null이면 오류를 기록하고 null 반환
  if (refreshToken == null) {
    logger.e('리프레시 토큰을 찾을 수 없습니다.');
    return null;
  }

  // API 요청에 대한 엔드포인트 및 헤더 정의
  String url = 'https://storepop.io/api/v2/authenticate/refresh';
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $refreshToken"
  };

  // API 요청을 함
  var response = await http.post(Uri.parse(url), headers: headers);

  // 응답이 성공적인 경우 응답을 디코드하고 새 액세스 토큰 반환
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data["access"];
  }

  logger.e('액세스 토큰을 새로 고침하는데 실패했습니다.');
  return null;
}

// API 엔드포인트에 매장 ID를 보내고 QR 코드 페이지로 이동하는 함수
Future<void> sendStoreID(BuildContext context) async {
  // final selectedStoresData = Provider.of<selectedStores>(context);
  final selectedStoresData =
      Provider.of<selectedStores>(context, listen: false);

  String url = 'https://storepop.io/api/v2/worker/control/qr';
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization":
        "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
  };
  // 매장 ID를 보내기 위한 body 데이터 정의
  var bodyContent = {
    "store_id": {"\$oid": selectedStoresData.selectedStoreIds}
  };

// body 값 로그 출력
  logger.i('Sending Body Data: ${jsonEncode(bodyContent)}');

  // 매장 ID를 보내기 위한 API 요청
  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(bodyContent),
  );

  // 성공적인 경우 응답에서 QR 코드를 표시하는 QRCodePage로 이동
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRCodePage(qrData: data["data"]),
        ));
  }
}

// 현재 액세스 토큰을 사용하여 서버에서 QR 데이터를 검색하는 함수
Future<String?> getQRData(BuildContext context) async {
  final accessToken =
      Provider.of<tokenModel>(context, listen: false).accessToken;

  String url = 'https://storepop.io/api/v2/worker/control/qr';
  logger.i('서버에서 QR 데이터를 가져오려고 시도 중...');

  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $accessToken",
  };

  var response = await http.post(Uri.parse(url), headers: headers);

  // 응답 상태 코드를 기록
  logger.i('서버가 상태 코드로 응답: ${response.statusCode}');

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data["data"];
  } else if (response.statusCode == 401) {
    // 토큰이 유효하지 않은 경우 토큰을 새로 고치고 요청을 다시 시도
    String? newAccessToken = await refreshAccessToken();
    if (newAccessToken != null) {
      Provider.of<tokenModel>(context, listen: false).setAccessToken =
          newAccessToken;
      return await getQRData(context);
    }
    logger.e('인증 문제. 액세스 토큰을 새로 고치는데 실패했습니다.');
  } else {
    logger.e('예상하지 못한 상태 코드: ${response.statusCode}');
  }

  return null;
}

// QR 코드 페이지를 표시하는 위젯
class QRCodePage extends StatefulWidget {
  final String? qrData; // 표시할 QR 데이터

  QRCodePage({this.qrData});

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  @override
  Widget build(BuildContext context) {
    final accessToken =
        Provider.of<tokenModel>(context, listen: false).accessToken;
    final selectedStoresData =
        Provider.of<selectedStores>(context, listen: false);

    return Scaffold(
      // 현재 액세스 토큰을 표시하는 앱 바 (주석 처리됨)
      // appBar: AppBar(
      //   title: Text('토큰: $accessToken'),
      // ),
      body: Center(
        child: widget.qrData != null
            // QR 데이터가 있으면 QR 코드와 원시 값 표시
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: widget.qrData!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(height: 20),
                  // Text('QR 데이터: ${widget.qrData}')
                ],
              )
            // QR 데이터가 없으면 로딩 스피너 표시
            : CircularProgressIndicator(),
      ),
    );
  }
}
//  code1에서 QR코드 아이콘 클릭시 QRCodePage클래스의 sendStoreID() 메소드를 호출해서 qrCode를 생성하는 방법
