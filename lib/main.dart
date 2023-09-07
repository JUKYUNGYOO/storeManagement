import 'package:adminapp/qrPage.dart';
import 'package:flutter/material.dart';
import 'package:adminapp/loginScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // 로케일 데이터를 초기화하기 위해 추가해주세요.
import 'package:provider/provider.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:adminapp/checkboxListTitleApp.dart';
import 'package:adminapp/utils.dart';
import 'package:adminapp/mainView.dart';
import 'package:adminapp/myPage.dart';
import 'package:adminapp/selectedStores.dart';
import 'package:adminapp/totalSalesProvider.dart';
import 'package:adminapp/draggableItemsPosition.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adminapp/navExpandProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    print(details.stack);
  };

  // debugPaintSizeEnabled = true;
  initializeDateFormatting().then((_) async {
    // Get the refresh token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    runApp(
      MultiProvider(
        providers: [
          // tokenModel을 제공합니다.
          ChangeNotifierProvider(
            create: (context) {
              var model = tokenModel();
              if (refreshToken != null) {
                model.setRefreshToken = refreshToken;
              }
              return model;
            },
          ),
          // CheckedStores를 제공합니다.
          ChangeNotifierProvider(
            create: (context) => selectedStores(),
          ),
          ChangeNotifierProvider(
            create: (context) => totalSalesProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => draggableItemsPosition(),
          ),
          ChangeNotifierProvider(
            create: (context) => navExpandProvider(),
          ),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //전체화면으로 앱 실행
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // 앱의 루트 위젯

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App', // 앱 제목
      // initialRoute: '/', // 초기 경로설정
      // 앱 내의 경로와 그 경로에 대응되는 화면
      routes: {
        // '/': (context) => SingleChildScrollView(child: loginScreen()),
        '/': (context) => loginScreen(),
        '/sideMenu': (context) => mainView(),
        '/qrPage': (context) => QRCodePage(),
        '/myPage': (context) => myPage(),
        '/checkboxListTitleApp': (context) => checkboxListTitleApp(),
      },

      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        // primarySwatch: createMaterialColor(Color(0xFFE3F3FA)), // 기본 테마 색상
        primarySwatch: Colors.lightBlue,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'NanumGothic',
            ),
      ),

      // 다른 설정들...
      // localizationsDelegates와 supportedLocales 추가
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 영어 (미국)
        const Locale('ko', 'KR'), // 한국어 (대한민국)
        // 원하는 다른 로케일 추가 가능...
      ],
      // home: loginScreen(), // 앱의 시작 화면 설정.
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });

    return MaterialColor(color.value, swatch);
  }
}
