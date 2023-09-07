// import 'package:flutter/material.dart';
// import 'package:adminapp/productDatatable.dart';
// import 'package:logger/logger.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'utility.dart';

// var logger = Logger(
//   printer: PrettyPrinter(),
//   level: Level.debug,
// );

// class opentwoDetails extends StatefulWidget {
//   @override
//   _opentwoDetailsState createState() => _opentwoDetailsState();
// }

// class _opentwoDetailsState extends State<opentwoDetails> {
//   String productId = '-';
//   String productName = '-';
//   double productMass = 0.0;

//   //utility 메소드 DataRow 리스트 반환
//   List<DataRow> _createRows_price(
//       String productId, String productName, double productMass) {
//     return createRowsPrice(productId, productName, productMass); // 유틸리티 메서드를 사용
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('2번 오픈선반'),
//         ),
//         body: Row(
//           children: [
//             Flexible(
//               flex: 4,
//               child: SingleChildScrollView(
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 3 / 4,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: <Widget>[
//                         Text('오픈선반'), // '오픈선반' 텍스트 추가
//                         for (int i = 1; i < 6; i++) ...[
//                           Container(
//                             height: 70,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0), // 좌측 공간 추가
//                               child: GridView.builder(
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 6,
//                                   childAspectRatio: 1.5,
//                                 ),
//                                 itemBuilder: (context, index) {
//                                   int row = i;
//                                   int column = index + 1;
//                                   return GestureDetector(
//                                     onTap: () {
//                                       handleCardClick(row, column);
//                                     },
//                                     child: Card(
//                                       child: Container(
//                                         width: 10,
//                                         height: 80,
//                                         child: Center(
//                                           child:
//                                               Text("아이템 ${row * 6 + column}"),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 itemCount: 6,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: 4000,
//                             height: 30,
//                             child: Image.asset(
//                               'assets/page-1/images/sunban.png',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Flexible(
//               flex: 4,
//               child: Container(
//                 alignment: Alignment.topCenter,
//                 margin: EdgeInsets.only(top: 50), // 상단 여백 추가
//                 child: productDataTable(
//                   num: 1,
//                   productId: productId, // productId 전달
//                   productName: productName, // productName 전달
//                   productMass: productMass, // productMass 전달
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // handleCardClick() 호출 시 row, column에 있는
// // productId, productName, productMass의 값을
// //
//   void handleCardClick(int row, int column) async {
//     final response = await http.get(
//       Uri.parse('http://192.168.0.210:7777/mass/1'),
//     );
//     // HTTP GET 요청이 성공적으로 완료된 경우 (상태 코드 200)
//     if (response.statusCode == 200) {
//       // 응답 데이터를 json 형태로 디코드
//       final data = json.decode(utf8.decode(response.bodyBytes))['data'];
//       // 'data'에서 일치하는 행과 열을 찾고
//       final matchingData = data.firstWhere((item) {
//         return item['row'] == row && item['column'] == column;
//       }, orElse: () => null);
//       // 일치하는 데이터가 있는 경우
//       if (matchingData != null) {
//         productId = matchingData['product']['_id'];
//         productName = matchingData['product']['name'];
//         productMass = matchingData['product']['mass'];
//         // 카드 클릭과 관련된 정보를 로깅
//         logger.d('Row: $row, Column: $column 카드 클릭');
//         logger.d(
//             'Product ID: $productId, Product Name: $productName, Product Mass: $productMass');

//         setState(() {
//           // 상태를 업데이트하여 화면 리로드
//         });
//       } else {
//         logger.d('해당하는 데이터가 없음');
//       }
//     } else {
//       logger.d('HTTP GET 요청 실패: ${response.statusCode}');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:adminapp/productDatatable.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utility.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug,
);

class opentwoDetails extends StatefulWidget {
  @override
  _opentwoDetailsState createState() => _opentwoDetailsState();
}

class _opentwoDetailsState extends State<opentwoDetails> {
  String productId = '-';
  String productName = '-';
  double productMass = 0.0;

  //utility 메소드 DataRow 리스트 반환
  List<DataRow> _createRows_price(
      String productId, String productName, double productMass) {
    return createRowsPrice(productId, productName, productMass); // 유틸리티 메서드를 사용
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: Text('2번 오픈선반'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.close_rounded),
              iconSize: 48.0,
              onPressed: () {
                Navigator.of(context).pop(); // 모달 창 닫기
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: EdgeInsets.only(
            //       right: 32.0), // 32.0 logical pixels = 1cm approximately

            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       IconButton(
            //         icon: Icon(Icons.close_rounded),
            //         iconSize: 48.0,
            //         onPressed: () {
            //           Navigator.of(context).pop(); // 모달 창 닫기
            //         },
            //       ),
            //     ],
            //   ),
            // ),

            Expanded(
              child: Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 3 / 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              // Text('오픈선반'), // '오픈선반' 텍스트 추가
                              for (int i = 1; i < 6; i++) ...[
                                Container(
                                  height: 70,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 6,
                                        childAspectRatio: 1.5,
                                      ),
                                      itemBuilder: (context, index) {
                                        int row = i;
                                        int column = index + 1;
                                        return GestureDetector(
                                          onTap: () {
                                            handleCardClick(row, column);
                                          },
                                          child: Card(
                                            child: Container(
                                              width: 10,
                                              height: 80,
                                              child: Center(
                                                child: Text(
                                                    "아이템 ${row * 6 + column}"),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: 6,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 4000,
                                  height: 30,
                                  child: Image.asset(
                                    'assets/page-1/images/sunban.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(top: 50),
                      child: productDataTable(
                        num: 1,
                        productId: productId,
                        productName: productName,
                        productMass: productMass,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleCardClick(int row, int column) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.210:7777/mass/1'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      final matchingData = data.firstWhere((item) {
        return item['row'] == row && item['column'] == column;
      }, orElse: () => null);

      if (matchingData != null) {
        productId = matchingData['product']['_id'];
        productName = matchingData['product']['name'];
        productMass = matchingData['product']['mass'];

        logger.d('Row: $row, Column: $column 카드 클릭');
        logger.d(
            'Product ID: $productId, Product Name: $productName, Product Mass: $productMass');

        setState(() {});
      } else {
        logger.d('해당하는 데이터가 없음');
      }
    } else {
      logger.d('HTTP GET 요청 실패: ${response.statusCode}');
    }
  }
}
