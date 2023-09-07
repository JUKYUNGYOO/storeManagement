import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:adminapp/imagebuttonOneDetails.dart';
import 'package:adminapp/utility.dart';

//1번 냉동고의 > 상세 페이지
var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);

// StatefulWidget을 정의합니다.
//위젯이 표시하는 데이터가 시간이 지남에 따라 변경됨.
class productDataTable extends StatefulWidget {
  final int num;
  final String productId; // 추가
  final String productName; // 추가
  final double productMass; // 추가

  productDataTable({
    required this.num,
    required this.productId,
    required this.productName,
    required this.productMass,
  });

  @override
  _ProductDataTableState createState() => _ProductDataTableState();
}

class _ProductDataTableState extends State<productDataTable> {
  List<dynamic> products = [];
  String query = '';
  TextEditingController _controller = TextEditingController();
  int? selectedRow;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.210:7777/mass/${widget.num}?query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      setState(() {
        products = data;
      });
    } else {
      throw Exception('서버에서 데이터를 로드하는데 실패했습니다.');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30), // 상단에 20 픽셀의 공간 추가
        Container(
          width: 400,
          // height: 100,
          child: DataTable(
            columns: _createColumns_price(),
            rows: createRowsPrice(
                widget.productId, widget.productName, widget.productMass),
            dividerThickness: 5,
            dataRowHeight: 60,
            showBottomBorder: true,
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headingRowColor: MaterialStateProperty.resolveWith(
              (states) => Color.fromARGB(255, 146, 152, 155),
            ),
          ),
        ),
        Container(
          width: 400,
          height: 100,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Search',
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
        //Expanded -> Flexible로 변경 됨.
        //상세 페이지에서 상품바코드, 상품명
        Expanded(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 400, // Specify the minimum width
                    maxHeight: 200, // Specify the minimum height
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
              Container(
                margin: EdgeInsets.only(top: 20),
                width: 400,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 154, 158, 161),
                  ),
                  child: Text('상품변경'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        label: Container(
          width: 200,
          child: Text('상품 바코드'),
        ),
      ),
      DataColumn(
        label: Container(
          width: 200,
          child: Text('상품명'),
        ),
      ),
    ];
  }

  List<DataRow> _createRows() {
    if (query.isEmpty) {
      return [
        DataRow(cells: [
          DataCell(
            Container(
              width: 150,
              child: Text('        ',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
          DataCell(
            Container(
              width: 150,
              child: Text('검색된 상품이 없습니다.',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
        ]),
      ];
    }

    final filteredProducts = products.where((product) {
      final name = product['product']['name'];
      final id = product['product']['_id'];
      return name.contains(query) || id.contains(query);
    }).toList();

    if (filteredProducts.isEmpty) {
      return [
        DataRow(cells: [
          DataCell(
            Container(
              // width: 150,
              child: Text('        ',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
          DataCell(
            Container(
              // width: 150,
              child: Text('검색된 상품이 없습니다.',
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
        ]),
      ];
    }

    return filteredProducts.map((product) {
      final id = product['product']['_id'];
      final name = product['product']['name'];
      logger.i('product name: $name');

      bool isSelected =
          selectedRow != null && products[selectedRow!]['product']['_id'] == id;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (bool? selected) {
          if (selected != null) {
            setState(() {
              selectedRow = isSelected ? null : products.indexOf(product);
            });
            print('Row selected: $name');
          }
        },
        cells: [
          DataCell(
            Container(
              width: 100,
              child: Text(id,
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
          DataCell(
            Container(
              width: 100,
              child: Text(name,
                  style:
                      TextStyle(color: Colors.black, fontFamily: 'NotoSansKR')),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<DataColumn> _createColumns_price() {
    return [
      DataColumn(
        label: Container(
          width: 100,
          child: Text('바코드'),
        ),
      ),
      DataColumn(
        label: Container(
          width: 100,
          child: Text('상품명'),
        ),
      ),
      DataColumn(
        label: Container(
          width: 100,
          child: Text('가격'),
        ),
      ),
    ];
  }
}
