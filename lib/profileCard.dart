import 'package:flutter/material.dart';
import 'package:adminapp/qrPage.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/selectedStores.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:http/http.dart' as http;
import 'package:adminapp/tokenModel.dart';
import 'package:logger/logger.dart';

// component-2
// 프로필에 있는 qr버튼 클릭 시 팝업으로 qr코드 생성
var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);

class profileCard extends StatelessWidget {
  final String name;
  final String jobTitle;
  // final String accessToken;
  final String accessToken;

  profileCard({
    required this.name,
    required this.jobTitle,
    // required this.imageUrl,
    required this.accessToken,
  });
//post요청시 store_id에 따른 qr데이터 반환
  Future<void> showQRCodeDialog(BuildContext context) async {
    final selectedStoresData =
        Provider.of<selectedStores>(context, listen: false);
    // Check if any storeId is selected
    if (selectedStoresData.selectedStoreIds.isEmpty) {
      logger.i('No Store ID selected!');
      return;
    }
    String selectedStoreId = selectedStoresData.selectedStoreIds.first;

    String url = 'https://storepop.io/api/v2/worker/control/qr';
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
    };
    var bodyContent = {
      "store_id": {"\$oid": selectedStoreId}
    };
    // body 값 로그 출력
    logger.i('profileCard Body Data: ${jsonEncode(bodyContent)}');
    var request = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(bodyContent),
    );
    logger.i('request Body Data: ${request.body}');

    if (request.statusCode == 200) {
      var data = jsonDecode(request.body);
      // data["qr"] 값 로그 출력
      logger.i('Received QR Data: ${data["data"]}');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('QR Code'),
            content: SizedBox(
              width: 300.0,
              height: 400.0,
              child: QRCodePage(qrData: data["data"]),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStoresData = Provider.of<selectedStores>(context);
    final ids = selectedStoresData.selectedStoreIds;

    return Container(
      height: 60, // 적절한 높이 값으로 조정
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // 최소한의 크기로 설정
        children: [
          CircleAvatar(
            radius: 20, // 크기 조절
            backgroundImage: AssetImage('assets/page-1/images/component-2.png'),
          ),
          SizedBox(width: 10), // 간격 조절
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16, // 글자 크기 조절
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 2), // 간격 조절
              Text(
                jobTitle,
                style: TextStyle(
                  fontSize: 10, // 글자 크기 조절
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
          SizedBox(width: 10), // 간격 조절
          IconButton(
            icon: Icon(Icons.qr_code, color: Colors.black),
            iconSize: 50.0, // 아이콘 크기 조절
            onPressed: () => showQRCodeDialog(context),
          )
        ],
      ),
    );
  }
}
