import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:logger/logger.dart';
import 'package:adminapp/totalSalesProvider.dart';
import 'package:provider/provider.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);

class calendarWidget extends StatefulWidget {
  DateTime selectedStartDate;
  DateTime selectedEndDate;
  final void Function(DateTime, DateTime)? onDaySelected;
  final Map<String, dynamic> salesData;

  calendarWidget({
    required this.salesData,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    this.onDaySelected,
  })  : selectedStartDate = selectedStartDate ?? DateTime.now(),
        selectedEndDate = selectedEndDate ?? DateTime.now();

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();

  void updateRange(DateTime startDate, DateTime endDate) {
    _calendarKey.currentState?.updateRange(startDate, endDate);
  }

  final GlobalKey<_CalendarWidgetState> _calendarKey =
      GlobalKey<_CalendarWidgetState>();
}

class _CalendarWidgetState extends State<calendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();

  void updateRange(DateTime start, DateTime end) {
    setState(() {
      widget.selectedStartDate = start;
      widget.selectedEndDate = end;
      _focusedDay = start;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });
  }

  void _calculateTotalSales() {
    double totalSales = 0;
    DateTime dateIterator = widget.selectedStartDate;
    while (
        dateIterator.isBefore(widget.selectedEndDate.add(Duration(days: 1)))) {
      final daySales = widget.salesData[dateIterator.toString().split(' ')[0]];
      if (daySales != null) {
        totalSales += daySales;
      }
      dateIterator = dateIterator.add(Duration(days: 1));
    }

    logger.d('누적매출액: $totalSales');
    Provider.of<totalSalesProvider>(context, listen: false).totalSales =
        totalSales as dynamic;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      //선택된 날짜의 하이라이터 기능 삭제
      // selectedDayPredicate: null,
      locale: 'ko_kr',
      daysOfWeekHeight: 35,
      firstDay: DateTime(1800, 1, 1),
      lastDay: DateTime(3000, 1, 1),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      // headerVisible: false,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15.0,
        ),
      ),
      availableCalendarFormats: {
        CalendarFormat.month: 'Month',
      },

      //날짜 셀을 만드는 속성

      // 날짜 셀을 만드는 속성
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          final daySales = widget.salesData[date.toString().split(' ')[0]];
          // DateTime의 문자열에서 시간 부분을 제거

          return Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // children: [
              //   Text(date.day.toString()), // 날짜 숫자

              //   if (daySales != null)
              //     Text('${(daySales / 10000).toStringAsFixed(1)}만원',
              //         style: TextStyle(color: Colors.green)),
              // ],
              children: [
                Text(date.day.toString()), // 날짜 숫자

                if (daySales != null && daySales >= 0.1)
                  Text('${(daySales / 10000).toStringAsFixed(1)}만원',
                      style: TextStyle(color: Colors.green)),
              ],
            ),
          );
        },
      ),
      /////////////

//캘린더 위젯에서 선택된 기간을 하이라이트
      // selectedDayPredicate: (date) {
      //   return isSameDay(widget.selectedStartDate, date) ||
      //       (date.isAfter(widget.selectedStartDate) &&
      //           date.isBefore(widget.selectedEndDate.add(Duration(days: 1))));
      // },
      onDaySelected: (selectedDay, focusedDay) {
        if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
          setState(() {
            widget.selectedStartDate = selectedDay;
            widget.selectedEndDate = selectedDay;
            _rangeSelectionMode = RangeSelectionMode.toggledOn;
          });
          widget.onDaySelected
              ?.call(widget.selectedStartDate, widget.selectedEndDate);
        } else if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
          if (selectedDay.isAfter(widget.selectedStartDate)) {
            setState(() {
              widget.selectedEndDate = selectedDay;
              _rangeSelectionMode = RangeSelectionMode.toggledOff;
              widget.onDaySelected
                  ?.call(widget.selectedStartDate, widget.selectedEndDate);
            });
          } else {
            setState(() {
              widget.selectedStartDate = selectedDay;
            });
          }
        }
        _calculateTotalSales();
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }
}
