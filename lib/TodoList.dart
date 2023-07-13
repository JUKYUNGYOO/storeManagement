import 'package:flutter/material.dart';

void main() => runApp(TodoList());

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return TodoListContent(constraints: constraints);
            },
          ),
        ),
      ),
    );
  }
}

class TodoListContent extends StatelessWidget {
  final BoxConstraints constraints;

  const TodoListContent({Key? key, required this.constraints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카드 1을 생성함.
    var card1 = Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              '1셀 오비)카스 후레쉬 캔맥주 재고 채우기 ',
              style: TextStyle(fontSize: 16.0),
            ),
            // Additional content
          ],
        ),
      ),
    );
// card2 생성 함.
    var card2 = Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              '6셀 하이트)이슬톡톡복숭아 350ML 재고 채우기',
              style: TextStyle(fontSize: 16.0),
            ),
            // Additional content
          ],
        ),
      ),
    );
//card 3을 생성함.
    var card3 = Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              '7셀 로드셀 상품 쓰러짐 확인',
              style: TextStyle(fontSize: 16.0),
            ),
            // Additional content
          ],
        ),
      ),
    );
//card4 를 생성함.
    var card4 = Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              '8셀 새로운 카드',
              style: TextStyle(fontSize: 16.0),
            ),
            // Additional content
          ],
        ),
      ),
    );
//상단 컨텐츠를 담는 Row위젯을 생성함.
    var contentView = Row(
      children: [
        Expanded(child: card1),
        Expanded(child: card2),
        Expanded(child: card3),
        Expanded(child: card4),
      ],
    );
//5*5 테이블을 생성함.
    // var table = DataTable(
    //   columns: List.generate(
    //     5,
    //     (index) => DataColumn(label: Text('열 ${index + 1}')),
    //   ),
    //   rows: List.generate(
    //     5,
    //     (rowIndex) => DataRow(
    //       cells: List.generate(
    //         5,
    //         (cellIndex) =>
    //             DataCell(Text('행 ${rowIndex + 1}, 열 ${cellIndex + 1}')),
    //       ),
    //     ),
    //   ),
    // );
    var table = DataTable(
      columns: List.generate(
        9,
        (index) => DataColumn(label: Text(' ${index + 1}')),
      ),
      rows: [
        DataRow(cells: [
          DataCell(Text('셀')),
          DataCell(Text('1셀')),
          DataCell(Text('2셀')),
          DataCell(Text('3셀')),
          DataCell(Text('4셀')),
          DataCell(Text('5셀')),
          DataCell(Text('6셀')),
          DataCell(Text('7셀')),
          DataCell(Text('8셀')),
        ]),
        DataRow(cells: [
          DataCell(Text('1단')),
          DataCell(Text('오비)카스')),
          DataCell(Text('오비)후레쉬')),
          DataCell(Text('오비)후레쉬캔')),
          DataCell(Text('롯데)순하리레몬진')),
          DataCell(Text('롯데)순하리레몬진7.0')),
          DataCell(Text('하이트)이슬톡톡')),
          DataCell(Text('하이트)이슬톡톡7.0')),
          DataCell(Text('하이트)레몬')),
        ]),
        DataRow(cells: [
          DataCell(Text('재고')),
          DataCell(Text('4/10')),
          DataCell(Text('3/10')),
          DataCell(Text('2/10')),
          DataCell(Text('3/10')),
          DataCell(Text('1/10')),
          DataCell(Text('0/10')),
          DataCell(Text('4/10')),
          DataCell(Text('5/10')),
        ]),
        DataRow(cells: [
          DataCell(Text('현재무게')),
          DataCell(Text('1222.9g')),
          DataCell(Text('1111.3g')),
          DataCell(Text('1111.2g')),
          DataCell(Text('3939.2g')),
          DataCell(Text('1010.2g')),
          DataCell(Text('1919.2g')),
          DataCell(Text('1919.2g')),
          DataCell(Text('1902.2g')),
        ]),
      ],
    );

//컬럼과 테이블로 구성된 컨텐츠를 담는 Column 위젯을 생성함.
    return Column(
      children: [
        SizedBox(
          height:
              constraints.maxHeight * 1 / 3, // Height of the top 1/3 section
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: contentView,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: table,
            ),
          ),
        ),
      ],
    );
  }
}
