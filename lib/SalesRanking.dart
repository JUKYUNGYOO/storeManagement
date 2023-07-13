import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(SalesRanking());

class SalesRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return DateRangeCalendar(constraints: constraints);
            },
          ),
        ),
      ),
    );
  }
}

class DateRangeCalendar extends StatefulWidget {
  final BoxConstraints constraints;

  const DateRangeCalendar({Key? key, required this.constraints})
      : super(key: key);

  @override
  _DateRangeCalendarState createState() => _DateRangeCalendarState();
}

class _DateRangeCalendarState extends State<DateRangeCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = selectedDay;
        _rangeEnd = null;
      } else if (selectedDay.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = selectedDay;
      } else {
        _rangeEnd = selectedDay;
      }
    });
  }

  List<String> getSalesRanking() {
    // 다른 위치에 대한 가상의 판매 순위 데이터 반환
    return [
      '1, Location A, 처음처럼페트640ML, 90',
      '2, Location A, 카스라이트캔맥주500ML, 80',
      '3, Location A, 카스후레쉬캔맥주355ML, 70',
      '4, Location A, 카스후레쉬캔맥주500ML, 60',
      '5, Location A, 오렌지100주스400ml, 50',
      '6, Location B, 처음처럼페트640ML, 120',
      '7, Location B, 카스라이트캔맥주500ML, 90',
      '8, Location B, 카스후레쉬캔맥주355ML, 80',
      '9, Location B, 카스후레쉬캔맥주500ML, 70',
      '10, Location B,오렌지100주스400ml, 60',
    ];
  }

  List<String> getTopSalesProducts() {
    // Location A의 가장 많이 팔린 상위 상품 데이터 반환
    return [
      '처음처럼페트640ML',
      '카스라이트캔맥주500ML',
      '카스후레쉬캔맥주355ML',
      '카스후레쉬캔맥주500ML',
      '오렌지100주스400ml',
    ];
  }

  @override
  Widget build(BuildContext context) {
    var contentView = Row(
      children: getTopSalesProducts().asMap().entries.map((entry) {
        int index = entry.key + 1;
        String product = entry.value;
        int sales = 100 - (10 * index);
        return Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    'Top$index',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    product,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    '판매량: $sales',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );

    var salesTable = DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text('기간'),
        ),
        DataColumn(
          label: Text('지점'),
        ),
        DataColumn(
          label: Text('상품'),
        ),
        DataColumn(
          label: Text('판매량'),
        ),
      ],
      rows: _rangeStart != null && _rangeEnd != null
          ? getSalesRanking().where((ranking) {
              final List<String> rankingData = ranking.split(', ');
              final String location = rankingData[1];
              final String product = rankingData[2];
              return location == 'Location A' &&
                  getTopSalesProducts().contains(product);
            }).map((ranking) {
              final List<String> rankingData = ranking.split(', ');
              return DataRow(
                cells: <DataCell>[
                  DataCell(Text(_rangeStart!.toString())),
                  DataCell(Text(rankingData[1])),
                  DataCell(Text(rankingData[2])),
                  DataCell(Text(rankingData[3])),
                ],
              );
            }).toList()
          : const <DataRow>[],
    );

    var tableCalendar = TableCalendar(
      calendarFormat: _calendarFormat,
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.utc(2023, 12, 31),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) =>
          isSameDay(day, _rangeStart) || isSameDay(day, _rangeEnd),
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      rangeSelectionMode: RangeSelectionMode.toggledOn,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              height: constraints.maxHeight * 1 / 3,
              padding: EdgeInsets.all(10.0),
              child: contentView,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        width: constraints.maxWidth * 0.4,
                        child: tableCalendar,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            salesTable,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
