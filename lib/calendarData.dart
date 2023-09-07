import 'dart:convert';
import 'package:adminapp/totalSalesProvider.dart';
import 'package:flutter/material.dart';
import 'package:adminapp/calendarWidget.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/selectedStores.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.verbose, // 변경: 모든 로그를 출력하기 위해 verbose로 설정
);

class calendarData extends StatefulWidget {
  @override
  _CalendarDataState createState() => _CalendarDataState();
}

class _CalendarDataState extends State<calendarData> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // 1. GlobalKey를 사용해 ScaffoldState에 접근
  final TextEditingController _startDateController = TextEditingController();
  // 2. 시작 날짜를 제어하는 TextEditingController 초기화
  final TextEditingController _endDateController = TextEditingController();
  // 3. 종료 날짜를 제어하는 TextEditingController 초기화
  Map<String, int> _salesData = {};
  // 4. 판매 데이터를 저장할 Map 변수

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  //startDate, endDate를 초기화

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now(); // 8. 현재 날짜와 시간
    startDate = DateTime(now.year, now.month, 1);
    logger.i('calendar test startDate : $startDate'); //2023-09-01
    // 9. startDate를 현재 월의 첫 날로 설정
    // endDate = DateTime(now.year, now.month + 1, 0);
    // 10. endDate를 현재 월의 마지막 날로 설정
    // -> endDate를 현재 월의 현재일(즉, 경과된 날짜)로 설정으로 변경함.
    endDate = DateTime(now.year, now.month, now.day);
    logger.i('calendar test endDate: $endDate'); //2023-09-06

    //startDate, endDate 두 변수는 현재날짜와 시간으로 설정 후
    //initState()는 현재 월의 특정 포인트

    _startDateController.text = formatDate(startDate);
    // 11. 시작 날짜를 문자열 형식으로 변환하여 컨트롤러에 저장
    _endDateController.text = formatDate(endDate);
    // 12. 종료 날짜를 문자열 형식으로 변환하여 컨트롤러에 저장

    _loadInitialSalesData();
    logger.i('initState executed');
  }

// 캘린더 위젯에 _salesData를 초기화 : 변경 전
  // void _loadInitialSalesData() async {
  //   Map<String, dynamic> salesData = await fetchSalesData(context);
  //   setState(() {
  //     _salesData = salesData;
  //   });
  // }

  //캘린더 위젯에 시작일 ~ 종료일의 누적매출액 초기화 : 변경 후
  void _loadInitialSalesData() async {
    Map<String, int> salesData = await fetchSalesData(context);
    setState(() {
      _salesData = salesData;
    });

    //
    int DaySales = _salesData[formatDate(startDate)] ?? 0;
    logger.i('calendar test firstDaySales DaySales : $_salesData');
    // _salesData : {2023-09-01: 49550, 2023-09-02: 0, 2023-09-03: 4000, 2023-09-04: 56530, 2023-09-05: 76695, 2023-09-06: 34415}
    // _salesData에 저장 된 값의 합계

    int totalSales = _salesData.values
        .fold(0, (previousValue, element) => previousValue + element);

    // 값을 TotalSalesProvider에 저장합니다.
    Provider.of<totalSalesProvider>(context, listen: false).totalSales =
        totalSales;

    logger.i('provider executed with total sales: $totalSales');
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<Map<String, int>> fetchSalesData(BuildContext context) async {
    try {
      final selectedStoresData =
          Provider.of<selectedStores>(context, listen: false);

      if (selectedStoresData.selectedStoreIds.isEmpty) {
        logger.i('No Store ID selected!');
        return {};
      } else {
        logger.i(
            'calendar Store ID selected!: ${selectedStoresData.selectedStoreIds.first}');
      }

      String selectedStoreId = selectedStoresData.selectedStoreIds.first;

      String url = 'https://storepop.io/api/v2/worker/sales/period';
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
        // "Bearer ${Provider.of<tokenModel>(context, listen: false).refreshToken}",
      };

      DateTime? start = DateTime.tryParse(_startDateController.text);
      DateTime? end = DateTime.tryParse(_endDateController.text);

      var bodyContent = {
        "store_id": {"\$oid": selectedStoreId},
        "from": formatDate(start!),
        "to": formatDate(end!)
      };

      var request = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(bodyContent),
      );
      logger.i('calendar Body Data: ${jsonEncode(bodyContent)}');

      if (request.statusCode == 200) {
        var data = jsonDecode(request.body);
        if (data.containsKey("data")) {
          logger.i('Sales Data: ${data["data"]}');
          Map<String, int> salesMap = {};
          for (var item in data["data"]) {
            salesMap[item["date"]] = item["sales"];
          }
          return salesMap;
        } else {
          return {};
        }
      } else {
        logger.e(
            'HTTP Request failed with status: ${request.statusCode}, body: ${request.body}');
        return {};
      }
    } catch (e, stacktrace) {
      logger.e('Error occurred in fetchSalesData: $e', e, stacktrace);
      return {};
    }
  }
// ... [다른 부분의 코드는 동일]

  @override
  Widget build(BuildContext context) {
    final double gap = 1 * 2.54 * MediaQuery.of(context).devicePixelRatio;
    final double dpi =
        MediaQuery.of(context).devicePixelRatio * 96.0; // <-- Get DPI

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 100.0,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 10 + dpi,
                  top: -10, // 이 값을 조절하여 '시작날짜', '종료날짜', '확인' 버튼의 위치를 변경합니다.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      dateTextField('시작날짜', _startDateController),
                      SizedBox(width: gap),
                      dateTextField('종료날짜', _endDateController),
                      SizedBox(width: gap),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? start =
                              DateTime.tryParse(_startDateController.text);

                          DateTime? end =
                              DateTime.tryParse(_endDateController.text);
                          //start 가 null 이거나 end 가 null 일 경우
                          logger.i('시작날짜 입력 후 start : $start');
                          logger.i('종료날짜 입력 후 end: $end');

                          if (start == null || end == null) {
                            start == startDate;
                            end == endDate;
                          } else if (start != null && end != null) {
                            Map<String, int> salesData =
                                await fetchSalesData(context);
                            setState(() {
                              _salesData = salesData;
                            });
                            logger
                                .i('Calendar Fetched Sales Data: $_salesData');
                            //누적 매출액 계산
                            int totalSales = _salesData.values.fold(
                                0,
                                (int prev, dynamic curr) =>
                                    prev + (curr as num).toInt());

                            logger.i(
                                'Calendar Total Sales for the period: $totalSales'); // 누적매출액 로그로 출력

                            // 값을 TotalSalesProvider에 저장
                            Provider.of<totalSalesProvider>(context,
                                    listen: false)
                                .totalSales = totalSales;
                          }
                        },
                        child: Text('선택 날짜로 조회'),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 30, // 이 값을 조절하여 calendarWidget의 위치를 아래로 이동
                  child: Container(
                    width: 500, // 원하는 너비
                    height: 500, // 원하는 높이
                    child: calendarWidget(
                      salesData: _salesData,
                      selectedStartDate: startDate,
                      selectedEndDate: endDate,
                      onDaySelected: _updateDateTextFields,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

// ... [나머지 코드는 동일]

  Widget dateTextField(String text, TextEditingController controller) {
    return Container(
      width: 120,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: text),
        onTap: () {
          _selectDateFromTextField(controller);
        },
      ),
    );
  }

  Future<void> _selectDateFromTextField(
      TextEditingController controller) async {
    try {
      DateTime initialDate =
          DateTime.tryParse(controller.text) ?? DateTime.now();
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1800, 1, 1),
        lastDate: DateTime(3000, 1, 1),
      );

      if (pickedDate != null) {
        controller.text = formatDate(pickedDate);
      }
    } catch (e, stacktrace) {
      logger.e('Error occurred in _selectDateFromTextField: $e', e, stacktrace);
    }
  }

  void _applySelectedDates() async {
    try {
      DateTime? start = DateTime.tryParse(_startDateController.text);
      DateTime? end = DateTime.tryParse(_endDateController.text);

      if (start != null && end != null) {
        logger.i('applySelectedDates : $start');
        logger.i('applySelectedDates : $end');

        Map<String, dynamic> salesData = await fetchSalesData(context);

        if (salesData.containsKey("data")) {
          setState(() {
            startDate = start;
            endDate = end;
            _salesData = salesData["data"];
            // salesData라는 map에서 "data"라는 키에 해당하는 값을 _salesData 변수에 할당
          });
        } else {
          setState(() {
            startDate = start;
            endDate = end;
            _salesData = {};
          });
        }

        logger.i('Sales Data passed to calendarWidget: $_salesData');
      }
    } catch (e, stacktrace) {
      logger.e('Error occurred in _applySelectedDates: $e', e, stacktrace);
    }
  }

  // String formatDate(DateTime date) {
  //   return '${date.year}-${date.month}-${date.day}';
  // }
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _updateDateTextFields(DateTime start, DateTime end) {
    try {
      _startDateController.text = formatDate(start);
      _endDateController.text = formatDate(end);
      setState(() {
        startDate = start;
        endDate = end;
      });
    } catch (e, stacktrace) {
      logger.e('Error occurred in _updateDateTextFields: $e', e, stacktrace);
    }
  }
}
