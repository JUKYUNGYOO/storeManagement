import 'package:flutter/material.dart';
import 'package:adminapp/Home.dart';

// 좌측 메뉴 구성
class NavigationRailPage extends StatefulWidget {
  const NavigationRailPage({Key? key}) : super(key: key);

  @override
  State<NavigationRailPage> createState() => _NavigationRailPageState();
}

// 하단 네비게이션 바 아이템들
const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.store),
    activeIcon: Icon(Icons.store),
    label: 'Store management',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.attach_money_rounded),
    activeIcon: Icon(Icons.attach_money_rounded),
    label: 'Sales',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline_rounded),
    activeIcon: Icon(Icons.person_outline_rounded),
    label: 'My page',
  ),
];

class _NavigationRailPageState extends State<NavigationRailPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;
    final bool isLargeScreen = width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(_navBarItems[_selectedIndex].label!),
      ),
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              items: _navBarItems,
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : null,
      body: Row(
        children: <Widget>[
          if (!isSmallScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: isLargeScreen,
              destinations: _navBarItems
                  .asMap()
                  .entries
                  .map((entry) => NavigationRailDestination(
                        icon: entry.value.icon,
                        selectedIcon: entry.value.activeIcon,
                        label:
                            entry.key == _selectedIndex // 현재 선택된 아이템에 대한 스타일 변경
                                ? Text(
                                    entry.value.label!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(entry.value.label!),
                      ))
                  .toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            // child: Center(
            child: getPageContent(), // 선택된 아이템에 따라 해당 페이지 컨텐츠 표시
            // ),
          )
        ],
      ),
    );
  }

  // 선택된 아이템에 따라 해당 페이지 컨텐츠를 반환하는 메서드
  Widget getPageContent() {
    switch (_selectedIndex) {
      // HOME을 선택 했을 때
      case 0:
        return Align(
          alignment: Alignment.topLeft,
          child: Home(),
        );
      // 나머지 case들...
      default:
        return Container();
    }
  }
}
