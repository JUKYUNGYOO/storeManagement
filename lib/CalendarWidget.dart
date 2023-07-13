import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:adminapp/db/Sales.dart';

void main() {
  runApp(CalendarWidget());
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Sales> _salesData = [];
  List<Sales> _filteredSalesData = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_startDate == null) {
        _startDate = selectedDay;
        _endDate = null;
      } else if (_endDate == null) {
        if (selectedDay.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = selectedDay;
        } else {
          _endDate = selectedDay;
        }
      } else {
        _startDate = selectedDay;
        _endDate = null;
      }
    });
  }

  void _loadData() {
    if (_startDate != null && _endDate != null) {
      // Filter sales data based on selected date range
      List<Sales> filteredSales = _salesData.where((sale) {
        return (sale.startDate!.isAfter(_startDate!) || isSameDay(sale.startDate!, _startDate!)) &&
            (sale.endDate!.isBefore(_endDate!) || isSameDay(sale.endDate!, _endDate!));
      }).toList();

      // Update filtered sales data
      setState(() {
        _filteredSalesData = filteredSales;
      });
    } else {
      // Handle missing start or end date
      print('Please select both start and end dates.');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSampleSalesData();
  }

  void _loadSampleSalesData() {
    _salesData = [
      Sales(
        startDate: DateTime(2023, 6, 1),
        endDate: DateTime(2023, 6, 1),
        revenue: 1000,
        cumulativeRevenue: 1000,
        visitors: 20,
        maxSales: 10,
        minSales: 5,
      ),
      Sales(
        startDate: DateTime(2023, 6, 1),
        endDate: DateTime(2023, 6, 1),
        revenue: 1500,
        cumulativeRevenue: 2500,
        visitors: 30,
        maxSales: 15,
        minSales: 8,
      ),
      // Add more sample data...
      Sales(
        startDate: DateTime(2023, 7, 1),
        endDate: DateTime(2023, 7, 5),
        revenue: 1500,
        cumulativeRevenue: 2500,
        visitors: 30,
        maxSales: 15,
        minSales: 8,
      ),
      Sales(
        startDate: DateTime(2023, 7, 1),
        endDate: DateTime(2023, 7, 5),
        revenue: 2500,
        cumulativeRevenue: 4000,
        visitors: 300,
        maxSales: 200,
        minSales: 8,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime.utc(2021, 1, 1),
                                  lastDate: DateTime.utc(2023, 12, 31),
                                ).then((selectedDate) {
                                  if (selectedDate != null) {
                                    setState(() {
                                      _startDate = selectedDate;
                                    });
                                  }
                                });
                              },
                              child: Text('Select Start Date'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _endDate ?? DateTime.now(),
                                  firstDate: DateTime.utc(2021, 1, 1),
                                  lastDate: DateTime.utc(2023, 12, 31),
                                ).then((selectedDate) {
                                  if (selectedDate != null) {
                                    setState(() {
                                      _endDate = selectedDate;
                                    });
                                  }
                                });
                              },
                              child: Text('Select End Date'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: Text('Load Data'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: constraints.maxWidth * 2 / 3,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _endDate = null;
                                });
                              },
                              child: DateRangeCalendar(
                                constraints: constraints,
                                startDate: _startDate,
                                endDate: _endDate,
                                salesData: _salesData,
                                onDaySelected: _onDaySelected,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SalesDataTable(salesData: _filteredSalesData),
                      ],
                    ),
                    Positioned(
                      top: 16.0,
                      right: 16.0,
                      child: ToDoList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DateRangeCalendar extends StatelessWidget {
  final BoxConstraints constraints;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Sales> salesData;
  final Function(DateTime, DateTime) onDaySelected;

  const DateRangeCalendar({
    Key? key,
    required this.constraints,
    this.startDate,
    this.endDate,
    required this.salesData,
    required this.onDaySelected,
  }) : super(key: key);

  List<Sales> getSalesForDay(DateTime day) {
    return salesData
        .where((sale) =>
    (sale.startDate!.isBefore(day) || isSameDay(sale.startDate!, day)) &&
        (sale.endDate!.isAfter(day) || isSameDay(sale.endDate!, day)))
        .toList();
  }

  double getTotalRevenueForDay(DateTime day) {
    final salesForDay = getSalesForDay(day);
    final totalRevenue = salesForDay.fold<double>(
      0,
          (sum, sale) => sum + (sale.revenue ?? 0),
    );
    return totalRevenue;
  }

  Widget buildRevenueText(DateTime day) {
    final totalRevenue = getTotalRevenueForDay(day);

    return Text(
      totalRevenue.toStringAsFixed(2),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: totalRevenue > 0 ? Colors.blue : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: constraints.maxWidth * 2 / 3,
            child: TableCalendar(
              calendarFormat: CalendarFormat.month,
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2023, 12, 31),
              focusedDay: startDate ?? DateTime.now(),
              selectedDayPredicate: (day) =>
              (startDate != null &&
                  endDate != null &&
                  day.isAfter(startDate!) &&
                  day.isBefore(endDate!)) ||
                  (startDate != null &&
                      endDate == null &&
                      isSameDay(day, startDate!)),
              rangeStartDay: startDate,
              rangeEndDay: endDate,
              onDaySelected: onDaySelected,
              onFormatChanged: (format) {},
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final salesForDay = getSalesForDay(day);

                  if (salesForDay.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 4,
                        ),
                      ),
                    );
                  }

                  return SizedBox.shrink();
                },
                defaultBuilder: (context, day, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildRevenueText(day),
                    ],
                  );
                },
                selectedBuilder: (context, day, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildRevenueText(day),
                    ],
                  );
                },
                rangeStartBuilder: (context, day, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildRevenueText(day),
                    ],
                  );
                },
                rangeEndBuilder: (context, day, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildRevenueText(day),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ToDoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To-Do List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('1. Task 1'),
          Text('2. Task 2'),
          Text('3. Task 3'),
          // Add more To-Do items here...
        ],
      ),
    );
  }
}

class SalesDataTable extends StatelessWidget {
  final List<Sales> salesData;

  const SalesDataTable({Key? key, required this.salesData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Start Date')), // 시작일 열
          DataColumn(label: Text('End Date')), // 종료일 열
          DataColumn(label: Text('Revenue')), // 매출 열
          DataColumn(label: Text('Cumulative Revenue')), // 누적 매출 열
          DataColumn(label: Text('Number of Visitors')), // 방문자 수 열
          DataColumn(label: Text('Maximum Sales')), // 최대 판매량 열
          DataColumn(label: Text('Minimum Sales')), // 최소 판매량 열
        ],
        rows: salesData.map((sale) {
          return DataRow(
            cells: [
              DataCell(Text(sale.startDate!.toIso8601String().split('T')[0])), // 시작일 데이터 셀
              DataCell(Text(sale.endDate!.toIso8601String().split('T')[0])), // 종료일 데이터 셀
              DataCell(Text(sale.revenue.toString())), // 매출 데이터 셀
              DataCell(Text(sale.cumulativeRevenue.toString())), // 누적 매출 데이터 셀
              DataCell(Text(sale.visitors.toString())), // 방문자 수 데이터 셀
              DataCell(Text(sale.maxSales.toString())), // 최대 판매량 데이터 셀
              DataCell(Text(sale.minSales.toString())), // 최소 판매량 데이터 셀
            ],
          );
        }).toList(),
      ),
    );
  }
}
