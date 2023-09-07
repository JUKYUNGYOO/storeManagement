import 'dart:ui' as ui;
import 'package:adminapp/barchartScreen.dart';
import 'package:adminapp/datatable.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:flutter/material.dart';
import 'package:adminapp/profileCard.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/calendarData.dart';
import 'package:adminapp/totalSalesProvider.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.verbose, // 변경: 모든 로그를 출력하기 위해 verbose로 설정
);

class home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime? selectedDate;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  //시작날짜, 종료날짜

  @override
  Widget build(BuildContext context) {
    final accessToken = Provider.of<tokenModel>(context).accessToken;
    // final refressToken = Provider.of<tokenModel>(context).refreshToken;
    final screenWidth = MediaQuery.of(context).size.width;
    final double offset = -780 / 2.54 * ui.window.devicePixelRatio;

    logger.d('displaySize : ${MediaQuery.of(context).size}');
    //displaySize : Size(1280.0, 720.0)
    logger.d('displayHeight : ${MediaQuery.of(context).size.height}');
    //displayHeight : 720.0
    logger.d('displayWidth : ${MediaQuery.of(context).size.width}');
    //displayWidth : 1280.0
    logger.d('devicePixelRatio : ${MediaQuery.of(context).devicePixelRatio}');
    //devicePixelRatio : 1.0
    logger.d('statusBarHeight : ${MediaQuery.of(context).padding.top}');
    //statusBarHeight : 0.0

    double baseWidth = 1280;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Text('InterMinds 사내매장'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Container(
                height: 1400.0,
                child: profileCard(
                  name: "John Doe",
                  jobTitle: "Manager(InterMinds.co)",
                  accessToken: accessToken,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        //왼쪽 컨테이너
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Cards section
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Card(
                                    elevation: 10,
                                    child: Container(
                                      color: Color(0xff009bf0),
                                      width: 165,
                                      height: 80,
                                      child: Stack(
                                        children: [
                                          // Top-left text
                                          Positioned(
                                            top: 6,
                                            left: 15,
                                            child: Text(
                                              '누적매출',
                                              style: TextStyle(
                                                fontFamily: 'NanumGothic',
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            bottom: 20,
                                            left: 15,
                                            child: Consumer<totalSalesProvider>(
                                              builder: (context,
                                                  totalSalesProvider, child) {
                                                // 총 매출액을 만원 단위로 변환
                                                // int valueInTenThousand =
                                                //     (totalSalesProvider
                                                //                 .totalSales /
                                                //             10000)
                                                //         .toInt();
                                                double valueInTenThousand =
                                                    (totalSalesProvider
                                                                .totalSales /
                                                            10000)
                                                        .toDouble();
                                                valueInTenThousand = double
                                                    .parse(valueInTenThousand
                                                        .toStringAsFixed(1));

                                                return Text(
                                                  // 숫자를 콤마로 구분된 문자열 형식으로 변환하여 표시(예: 1,234만원)
                                                  '\ ${valueInTenThousand.toString().replaceAllMapped(RegExp(r'(?<=[0-9])(?=(?:[0-9]{3})+(?![0-9]))'), (Match m) => ',')}만원',
                                                  style: TextStyle(
                                                    fontFamily: 'NanumGothic',
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          // Top-right image
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Image.asset(
                                              'assets/page-1/images/formkit-won.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 10,
                                    child: Container(
                                      color: Color(0xff00d394),
                                      width: 165,
                                      height: 80,
                                      child: Stack(
                                        children: [
                                          // Top-left text
                                          Positioned(
                                            top: 6,
                                            left: 15,
                                            child: Text(
                                              '방문자 수',
                                              style: TextStyle(
                                                fontFamily: 'NanumGothic',
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          // Bottom-left text
                                          Positioned(
                                            bottom: 20,
                                            left: 15,
                                            child: Text(
                                              '\ 2000명',
                                              style: TextStyle(
                                                fontFamily: 'NanumGothic',
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          // Top-right image
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Image.asset(
                                              'assets/page-1/images/fluent-person-walking-16-regular.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    elevation: 10,
                                    child: Container(
                                      color: Color(0xff00c3ff),
                                      width: 165,
                                      height: 80,
                                      child: Stack(
                                        children: [
                                          // Top-left text
                                          Positioned(
                                            top: 6,
                                            left: 15,
                                            child: Text(
                                              '구매 전환',
                                              style: TextStyle(
                                                fontFamily: 'NanumGothic',
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          // Bottom-left text
                                          Positioned(
                                            bottom: 20,
                                            left: 15,
                                            child: Text(
                                              '\ 2000명',
                                              style: TextStyle(
                                                fontFamily: 'NanumGothic',
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          // Top-right image
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Image.asset(
                                              'assets/page-1/images/icon-park-outline-buy.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Date Buttons below the Cards
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              ),
                            ),

                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      ui.Color(0xffffffff),
                                      ui.Color(0xffffffff),
                                    ],
                                    stops: [0.0, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 10.0), // 원하는 값으로 조절
                                  child: calendarData(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //왼쪽 컨테이너 끝

                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Center(
                                  child: barchartScreen(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Center(
                                  child: datatable(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
