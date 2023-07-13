import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:adminapp/CalendarWidget.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  void _showQRCodePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('QR Code'),
          // content: Image.asset('assets/qr_code.png'), // QR 코드 이미지 경로로 수정
          content: Container(
            width: 3 * MediaQuery.of(context).size.width / 100, // 2cm
            height: 3 * MediaQuery.of(context).size.width / 100, // 2cm
            child: Image.asset('assets/images/qr_code.png'), // QR 코드 이미지 경로로 수정
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('On : Interminds Company Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () {
              _showQRCodePopup(context);
            },
          ),
        ],
      ),
      body: CalendarWidget(),
    );
  }
}
// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('On : Interminds Company Store'),
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 20),
//           Expanded(
//             child: Scrollbar(
//               isAlwaysShown: true, // 항상 스크롤바 표시
//               child: ListView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 children: [
//                   CalendarWidget(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('On : Interminds Company Store'),
      ),
      body: CalendarWidget(),
    );
  }
}


class SectionWidget extends StatelessWidget {
  final String title;

  const SectionWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Icon(Icons.folder, size: 50),
        ],
      ),
    );
  }
}
