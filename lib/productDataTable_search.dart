import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:adminapp/tokenModel.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);

//매장관리 페이지 우측의 상품바코드, 상품명 테이블
class productDataTable_search extends StatefulWidget {
  // final int num; // num 값을 받아오기 위한 변수
  // productDataTable_full({required this.num}); // 생성자 수정

  @override
  _ProductDataTableState createState() => _ProductDataTableState();
}

class _ProductDataTableState extends State<productDataTable_search> {
  List<dynamic> products = []; // 제품을 저장하기 위한 리스트
  String query = ''; // 검색 쿼리를 저장하기 위한 문자열
  TextEditingController _controller = TextEditingController();

  String productId = '-';
  String productName = '-';
  double productMass = 0.0;

  // 위젯이 생성될 때 한 번 실행되는 메소드.

  @override
  void initState() {
    super.initState();
    _fetchData(); // 위젯이 초기화될 때 데이터를 가져옴.
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

  // 위젯이 위젯 트리에서 제거될 때 컨트롤러를 해제.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // UI를 생성하기 위한 빌드 메소드.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 400,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: '바코드 혹은 상품명 검색 후 등록 여부 확인',
              hintText: '상품명 또는 바코드 입력',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    query = _controller.text;
                    _fetchData();
                  });
                },
              ),
            ),
          ),
        ),
        //table widget
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 400,
                  // maxHeight: 400,
                ),
                child: DataTable(
                  columns: _createColumns(),
                  rows: _createRows(),
                  dividerThickness: 5,
                  dataRowHeight: 60,
                  showBottomBorder: true,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.lightBlue,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
//매장관리 페이지에서 상품 바코드와 상품명을 검색

  // DataTable의 열을 생성하기 위한 함수.
  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        label: Container(
          // width: 80, // 바코드 열의 너비를 100으로 설정
          child: Text('상품 바코드'),
        ),
      ),
      DataColumn(
        label: Container(
          // width: 100, // 상품명 열의 너비를 200으로 설정
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
      logger.i('product name: $name');

      return DataRow(cells: [
        DataCell(
          Container(
            // width: 200,
            child: Text(id,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
          ),
        ),
        DataCell(
          Container(
            // width: 200,
            child: Text(name,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
          ),
        ),
      ]);
    }).toList();
  }
}
