import 'package:adminapp/calendarData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:adminapp/home.dart';
import 'package:adminapp/myPage.dart';
import 'package:adminapp/storeManagement_Rail.dart';
import 'package:adminapp/loginScreen.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  level: Level.verbose,
  printer: PrettyPrinter(),
);

class mainView extends StatefulWidget {
  // Making it static allows you to access this without having an instance of the class

  const mainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<mainView> {
  static ValueNotifier<bool> isSideNavExpanded = ValueNotifier<bool>(true);

  void toggleSideNav() {
    isSideNavExpanded.value = !isSideNavExpanded.value;
  }

  List<Widget> views = [
    Center(
      child: home(),
    ),
    Center(
      child: storeManagement_Rail(),
    ),
    Center(
      child: Text('to be continued'),
    ),
    Center(
      child: myPage(),
    ),
  ];
  int selectedIndex = 0;
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    prefs.remove('refreshToken');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => loginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isSideNavExpanded,
      builder: (context, isExpanded, child) {
        return Scaffold(
          body: Row(
            children: [
              SideNavigationBar(
                header: SideNavigationBarHeader(
                  image: Image.asset(
                    'assets/page-1/images/component-3.png',
                    width: 30,
                    height: 30,
                  ),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'InterMinds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  subtitle: Text(''),
                ),
                footer: SideNavigationBarFooter(
                  label: InkWell(
                    onTap: _logout,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.output), // 로그아웃 아이콘
                          SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                          Text('로그아웃'), // "로그아웃" 텍스트
                        ],
                      ),
                    ),
                  ),
                ),
                selectedIndex: selectedIndex,
                items: const [
                  SideNavigationBarItem(
                    icon: Icons.home_outlined,
                    label: '홈',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.store_outlined,
                    label: '매장관리',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.monetization_on,
                    label: '매출',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.settings,
                    label: '내정보',
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                //추가된 부분
                toggler: SideBarToggler(
                  expandIcon: Icons.keyboard_arrow_right_rounded,
                  shrinkIcon: Icons.keyboard_arrow_left_rounded,
                  onToggle: () {
                    isSideNavExpanded.value = !isSideNavExpanded.value;
                    logger.i('isSideNavExpanded: $isSideNavExpanded');

                    //좌측 false
                    //우측 true
                  },
                ),
              ),
              Expanded(
                child: views.elementAt(selectedIndex),
              ),
            ],
          ),
        );
      },
    );
  }
}

//사이드 내비게이션 바에서 아이콘 또는 이미지를 표시하기 위한 클래스
class SideNavigationBarImage {
  /// The [IconData] you want to display
  final IconData? icon;

  /// The [Image] you want to display
  final Image? image;

  /// A text to display route information
  final String label;

  /// Item data
  const SideNavigationBarImage({
    this.icon,
    this.image,
    required this.label,
  }) : assert((icon == null) != (image == null),
            'You can only provide an icon or an image, not both.');
}
