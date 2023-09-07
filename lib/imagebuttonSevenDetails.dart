import 'dart:async';
import 'dart:typed_data';

import 'package:adminapp/navExpandProvider.dart';
import 'package:adminapp/product.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:convert';
import 'utility.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/selectedStores.dart';
import 'package:adminapp/tokenModel.dart';

var logger = Logger(
  level: Level.verbose,
  printer: PrettyPrinter(),
);

//shelf_id = 1 , 1번 선반
// row=1,column=1, 1 행 1열에 있는 선반 아이템
class imagebuttonSevenDetails extends StatefulWidget {
  final int id;
  final List<int>? composition;

  imagebuttonSevenDetails(this.id, this.composition);

  @override
  _imagebuttonSevenDetailsState createState() =>
      _imagebuttonSevenDetailsState();
}

class _imagebuttonSevenDetailsState extends State<imagebuttonSevenDetails> {
  String productId = '-';
  String productName = '-';
  double productMass = 0.0;

  String? selectedProductId;
  String? selectedProductName;

  // List<dynamic> products = []; // 제품을 저장하기 위한 리스트
  // List<Map<String, dynamic>> products = [];
  List<dynamic> products = []; // 제품을 저장하기 위한 리스트
  List<Map<String, dynamic>> selectedProducts = [];

  String query = ''; // 검색 쿼리를 저장하기 위한 문자열

  UsbPort? _port; // 연결할 USB 포트
  String _status = "Idle"; // 현재 상태를 표시하는 문자열
  List<Widget> _ports = []; // 사용 가능한 USB 포트 목록
  List<Widget> _serialData = []; // 수신한 시리얼 데이터 목록

  StreamSubscription<String>? _subscription; // 데이터 스트림 구독자
  Transaction<String>? _transaction; // 데이터 처리를 위한 트랜잭션 객체
  UsbDevice? _device; // 현재 연결된 USB 장치

  TextEditingController _controller = TextEditingController();

  int? currentRow;
  int? currentColumn;

  Future<bool> _connectTo(device) async {
    _serialData.clear(); // 기존에 저장된 시리얼 데이터를 초기화

    // 기존에 존재하는 스트림 구독을 취소하고 null로 설정
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    // 기존에 존재하는 트랜잭션을 종료하고 null로 설정
    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    // 기존에 열려 있는 포트를 닫고 null로 설정
    if (_port != null) {
      _port!.close();
      _port = null;
    }

    // 제공된 device가 null인 경우 연결을 종료하고 종료 상태로 설정
    if (device == null) {
      _device = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    // 제공된 device에서 포트를 생성
    _port = await device.create();
    // 포트를 열려고 시도하고, 실패할 경우 에러 상태로 설정
    if (await (_port!.open()) != true) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }
    _device = device; // 현재 연결된 장치를 설정

    // 포트의 통신 파라미터를 설정
    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // 포트의 입력 스트림을 문자열로 변환하도록 트랜잭션을 생성
    //문자열은 CR로 종료
    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13]));

    // 트랜잭션 스트림을 구독하여 들어오는 데이터를 처리
    _subscription = _transaction!.stream.listen((String line) {
      print("Received Serial Data: $line");
      // 받아온 시리얼 데이터를 로그로 출력.

      // 상태를 업데이트하여 받아온 데이터를 UI에 표시
      setState(() {
        _controller.text = line.trim();
        _serialData.add(Text(line.trim()));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    // 연결 상태를 "Connected"로 업데이트
    setState(() {
      _status = "Connected";
    });
    return true; // 연결에 성공했음을 나타내는 true 값을 반환.
  }

  // 사용 가능한 USB 포트 목록을 가져오는 함수
// 이 함수는 사용 가능한 USB 기기의 목록을 가져오고, 이에 따른 UI를 갱신하는 역할을 합니다.
  void _getPorts() async {
    // _ports 리스트 초기화
    _ports = [];

    // 사용 가능한 USB 기기의 목록을 얻습니다.
    List<UsbDevice> devices = await UsbSerial.listDevices();

    // 현재 연결된 기기(_device)가 사용 가능한 기기 목록에 없으면 연결을 해제
    if (!devices.contains(_device)) {
      _connectTo(null);
    }

    // 현재 연결된 모든 USB 기기의 정보를 콘솔에 출력합니다.
    print(devices);

    // 각 USB 기기에 대해 ListTile UI 요소를 생성합니다.
    devices.forEach((device) {
      _ports.add(ListTile(
          leading: Icon(Icons.usb), // 아이콘 설정
          title: Text(device.productName!), // 기기의 제품 이름
          subtitle: Text(device.manufacturerName!), // 기기의 제조사 이름
          trailing: ElevatedButton(
            // 연결/연결 해제 버튼
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              // 버튼을 누르면 해당 기기에 연결하거나 연결을 해제합니다.
              _connectTo(_device == device ? null : device).then((res) {
                _getPorts(); // 연결 상태 변경 후 기기 목록을 다시 불러옵니다.
              });
            },
          )));
    });

    // setState를 호출하여 UI를 갱신합니다.
    setState(() {
      print(_ports); // 갱신된 _ports 리스트를 콘솔에 출력
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData(); // 위젯이 초기화될 때 데이터를 가져옴.

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

// 위젯이 제거될 때 모든 연결을 종료
  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  void _fetchData() async {
    if (query.isEmpty) {
      // 쿼리가 비어 있으면 제품 목록을 리셋
      setState(() {
        products = [];
      });
      return;
    }

    // 쿼리가 바코드 (예: 모든 숫자) 인지 확인하고, 바코드이면 바코드로 가져오기.
    // 그렇지 않으면 상품명으로 가져 옴.
    if (_isBarcode(query)) {
      await _fetchData_barcode();
    } else {
      await _fetchData_productname();
    }
    // 필요하면 추가적인 상태 업데이트 로직을 여기에 추가.
  }

  bool _isBarcode(String input) {
    return RegExp(r'^\d+$').hasMatch(input); // 쿼리가 숫자만 포함하는지 확인
  }

  Future<void> _fetchData_productname() async {
    final response = await http.get(
      Uri.parse(
        'https://storepop.io/api/v2/worker/products/name/cu/${Uri.encodeComponent(query)}',
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
        // "Bearer ${Provider.of<tokenModel>(context, listen: false).refreshToken}",
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(utf8.decode(response.bodyBytes))['result'];

      // Filter out products where the mass is null
      final filteredProducts = result.where((product) {
        return product['mass'] != null;
      }).toList();

      // Log the filtered response
      logger.i(
          'Filtered response from _fetchData_productname: $filteredProducts');

      setState(() {
        products =
            filteredProducts; // Update the product list without products with null mass
        logger.i('selected products kkk : $products');
      });
    } else {
      logger.e('Error: ${response.statusCode}, ${response.body}');
      throw Exception('서버에서 데이터를 로드하는데 실패했습니다.');
    }
  }

  Future<void> _fetchData_barcode() async {
    final response = await http.get(
      Uri.parse(
        'https://storepop.io/api/v2/worker/products/partial_barcode/cu/${Uri.encodeComponent(query)}',
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(utf8.decode(response.bodyBytes))['result'];

      // Filter out products where the mass is null
      final filteredProducts = result.where((product) {
        return product['mass'] != null;
      }).toList();

      logger.i('_fetchData_barcode $filteredProducts');
      setState(() {
        products =
            filteredProducts; // Update the product list without products with null mass
      });
    } else {
      logger.e('Error: ${response.statusCode}, ${response.body}');
      throw Exception('서버에서 데이터를 로드하는데 실패했습니다.');
    }
  }

  Future<int?> _fetchQtyValue(int row, int column) async {
    final selectedStoresData =
        Provider.of<selectedStores>(context, listen: false);
    String selectedStoreId = selectedStoresData.selectedStoreIds.first;
    final response = await http.post(
      Uri.parse('https://storepop.io/api/v2/worker/pog/qty'),
      body: json.encode({
        "store_id": {"\$oid": selectedStoreId},
        "shelf_id": widget.id,
        "row": row, // 지역 변수를 사용
        "column": column, // 지역 변수를 사용
        // "barcode": productId
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['data'] != null && responseData['data'].isNotEmpty) {
        return responseData['data'][0]['qty'];
      }
    } else {
      logger.d('HTTP PATCH 요청 실패: ${response.statusCode}');
    }
    return null;
  }

  void _sendDataToServer() async {
    if (currentRow == null || currentColumn == null) {
      logger.d('Row or Column is not set.');
      return;
    }
    final selectedStoresData =
        Provider.of<selectedStores>(context, listen: false);
    String selectedStoreId = selectedStoresData.selectedStoreIds.first;
    final response = await http.post(
      Uri.parse('https://storepop.io/api/v2/worker/pog/alter'),
      body: json.encode({
        "store_id": {"\$oid": selectedStoreId},
        "shelf_id": widget.id,
        "row": currentRow,
        "column": currentColumn,
        "barcode": productId
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
      },
    );

    if (response.statusCode == 200) {
      logger.d('Data successfully updated and saved.');
    } else {
      logger.d('HTTP PATCH 요청 실패: ${response.statusCode}');
    }
  }

  //utility 메소드 DataRow 리스트 반환
  List<DataRow> _createRows_price(
      String productId, String productName, double productMass) {
    return createRowsPrice(productId, productName, productMass); // 유틸리티 메서드를 사용
  }

  void didChangeDependencies() {
    super.didChangeDependencies();

    var provider = Provider.of<navExpandProvider>(context, listen: false);
    provider.isSideNavExpanded = !provider.isSideNavExpanded;
  }

// 이 메소드는 해당 화면의 UI 구조를 정의하는 메인 빌드 메소드입니다.
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenWidth = screenSize.width;
    var screenHeight = screenSize.height;

    logger.i('Composition of freezerOneDetails: ${widget.composition}');
    logger.d('ID of freezerOneDetails: ${widget.id}');

    return Scaffold(
      // 제목이 있는 상단 앱 바
      appBar: AppBar(
        title: Text(
          '7번 선반',
          style: TextStyle(
            fontFamily: 'NanumGothic', // 위에서 설정한 폰트 패밀리 이름
          ),
        ),
      ),
      // 위젯의 주요 본문
      body: SingleChildScrollView(
        child: Row(
          children: [
            // 화면의 왼쪽 부분
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: screenWidth * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        // 그리드 항목을 생성하는 루프
                        for (int i = 0;
                            i < widget.composition!.length;
                            i++) ...[
                          Container(
                            height: 80,
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: widget.composition![i],
                                childAspectRatio: 0.5,
                              ),
                              itemBuilder: (context, index) {
                                int row = i + 1;
                                int column = index + 1;
                                return GestureDetector(
                                  onTap: () {
                                    handleCardClick(row, column);
                                  },
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Card(
                                          color: (row == currentRow &&
                                                  column == currentColumn)
                                              ? Color.fromARGB(255, 158, 223,
                                                  231) // 클릭됐을 때의 색상
                                              : null, // 기본 색상 (배경이 투명하도록 설정)

                                          child: Container(
                                            width: 90,
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  "아이템 ${row * widget.composition![i] + column}"),
                                            ),
                                          ),
                                        ),
                                        FutureBuilder<int?>(
                                          future: _fetchQtyValue(row, column),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator(); // Or any other loading widget
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  '오류: ${snapshot.error}');
                                            } else {
                                              return Text('  ${snapshot.data}');
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: widget.composition![i],
                            ),
                          ),

                          // 그리드 항목 사이의 이미지 구분 기호
                          Container(
                            width: 4500,
                            height: 50,
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
            // 화면의 오른쪽 부분
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: screenWidth * 0.4, height: screenHeight * 0.8),
                child: Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      // 제품 세부 정보를 표시하는 테이블
                      DataTable(
                        columns: [
                          DataColumn(label: Text('상품 바코드')),
                          DataColumn(label: Text('상품명')),
                          DataColumn(label: Text('무게')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Container(
                                width: 100,
                                child: Text('$productId',
                                    softWrap: true, maxLines: 2))),
                            DataCell(Container(
                                width: 150,
                                child: Text('$productName',
                                    softWrap: true, maxLines: 2))),
                            DataCell(Container(
                                width: 100,
                                child: Text('$productMass',
                                    softWrap: true, maxLines: 2))),
                          ]),
                        ],
                      ),
                      SizedBox(height: 40),

                      Container(
                        width: 500,
                        height:
                            80, // decreased height since we're removing the button
                        child: TextField(
                          controller:
                              _controller, // Use the controller from code1
                          decoration: InputDecoration(
                            labelText: '변경할 상품명 또는 바코드 입력',
                            hintText: '상품명 또는 바코드 입력',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () async {
                                // Fetching the data
                                setState(() {
                                  query = _controller.text;
                                  _fetchData();
                                });

                                // Sending data via serial communication (from the Send button logic)
                                if (_port != null) {
                                  String data = _controller.text + "\r\n";
                                  await _port!.write(
                                      Uint8List.fromList(data.codeUnits));
                                  _controller.text = "";
                                }
                              },
                            ),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                            ),
                          ),
                        ),
                      ),

                      // 검색 결과를 표시하는 부분
                      SizedBox(height: 20.0),

                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 200.0,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: screenWidth * 0.4,
                              // height: 200,
                              child: Column(
                                children: [
                                  // 검색 결과를 표시하는 테이블
                                  DataTable(
                                    headingRowHeight: 40,
                                    columns: _createColumns(),
                                    rows: _createRows(),
                                    dividerThickness: 5,
                                    dataRowHeight: 60,
                                    showBottomBorder: true,
                                    headingTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) => Colors.lightBlue,
                                    ),
                                  ),
                                  SizedBox(height: 30.0),
                                ],
                              ),
                            ),
                          ),
                          //추가
                        ),
                      ),
                      Container(
                          width: 500.0, // 원하는 너비로 설정하세요.
                          height: 30,
                          child: ElevatedButton(
                              onPressed: () {
                                if (selectedProducts.isNotEmpty) {
                                  // Update productId and productName from the selected product in the list
                                  setState(() {
                                    // setState 호출
                                    // Update productId and productName from the selected product in the list
                                    productId = selectedProducts[0]['_id'];
                                    productName = selectedProducts[0]['name'];
                                  });

                                  // Optionally: Send updated data to the server
                                  _sendDataToServer();
                                }
                              },
                              child: Text("상품변경"))),

                      ..._ports, // 가능한 시리얼 포트 목록을 화면에 표시
                      Text('Status: $_status\n'), // 현재 연결 상태를 화면에 표시.

                      ..._serialData,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleCardClick(int row, int column) async {
    setState(() {
      currentRow = row;
      currentColumn = column;
    });

    final selectedStoresData =
        Provider.of<selectedStores>(context, listen: false);
    int id = widget.id;
    String selectedStoreId = selectedStoresData.selectedStoreIds.first;

    final response = await http.post(
      Uri.parse('https://storepop.io/api/v2/worker/pog/query'),
      body: json.encode({
        "store_id": {"\$oid": selectedStoreId},
        "shelf_id": id,
        "row": row,
        "column": column
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
      },
    );

    logger.d('Response: ${response.body}');
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

        setState(() {
          productId = matchingData['product']['_id'];
          productName = matchingData['product']['name'];
          productMass = matchingData['product']['mass'];
        });
      } else {
        logger.d('해당하는 데이터가 없음');
      }
    } else {
      logger.d('HTTP GET 요청 실패: ${response.statusCode}');
    }
    _sendDataToServer();
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        label: Container(
          width: 100,
          child: Text('상품 바코드'),
        ),
      ),
      DataColumn(
        label: Container(
          width: 300,
          child: Text('상품명'),
        ),
      ),
    ];
  }

  List<DataRow> _createRows() {
    if (products.isEmpty) {
      return [
        DataRow(cells: [
          DataCell(
            Container(
              // width: 80,
              child: Text('        ',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
          DataCell(
            Container(
              // width: 100,
              child: Text('검색된 상품이 없습니다.',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
        ]),
      ];
    }

    return products.map((product) {
      final id = product['_id'];
      final name = product['name'];

      return DataRow(
          selected: selectedProducts.contains(product),
          onSelectChanged: (bool? isSelected) {
            setState(() {
              if (isSelected == true) {
                selectedProducts.add(product);
              } else {
                selectedProducts.removeWhere((item) => item['_id'] == id);
              }
            });

            // Log only the selected products
            for (var p in selectedProducts) {
              logger.i('Selected Product ID: ${p['_id']}');
              logger.i('Selected Product Name: ${p['name']}');
            }
          },
          cells: [
            DataCell(
              Container(
                // width: 200,
                child: Text(id,
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'NotoSansKR')),
              ),
            ),
            DataCell(
              Container(
                // width: 200,
                child: Text(name,
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'NotoSansKR')),
              ),
            ),
          ]);
    }).toList();
  }
}
