// 필요한 패키지들을 임포트합니다.
// import 'dart:ui';
import 'package:adminapp/selectedStores.dart';
import 'package:adminapp/qrPage.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:adminapp/store.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);

// 메인 앱 위젯
class checkboxListTitleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: CheckboxListTitleExample(),
    );
  }
}

// CheckboxListTile를 활용한 상태 위젯
class CheckboxListTitleExample extends StatefulWidget {
  @override
  State<CheckboxListTitleExample> createState() =>
      _CheckboxListTileExampleState();
}

// 상태 관리 클래스
class _CheckboxListTileExampleState extends State<CheckboxListTitleExample> {
  List<Store> storeNames = []; // 상점 이름을 저장할 리스트
  List<Store> filteredStoreNames = [];
  // 사용자의 검색에 따라 필터링된 상점 이름 리스트
  Map<String, bool> storeCheckStatus = {}; // 각 상점의 체크 상태를 저장하는 맵

  @override
  void initState() {
    super.initState();
    fetchStores(context).then((fetchedStores) {
      setState(() {
        storeNames = fetchedStores;
        filteredStoreNames = List.from(storeNames);
        storeNames.forEach((store) {
          storeCheckStatus[store.id] = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double serchbarWidth = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            // padding: const EdgeInsets.all(8.0),
            // padding: const EdgeInsets.only(top: 60.0),
            padding: const EdgeInsets.only(top: 30.0, right: 400.0),

            child: Container(
              padding: const EdgeInsets.only(top: 20.0, right: 100.0),
              width: serchbarWidth,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    filteredStoreNames = storeNames.where((store) {
                      return store.name.startsWith(value);
                    }).toList();
                  });
                },
                decoration: InputDecoration(
                  labelText: "매장을 입력해 주세요.",
                  hintText: "Search for stores",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20), // add space between search bar and grid

          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minWidth: 500,
                maxHeight: 100,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: filteredStoreNames.length,
                itemBuilder: (BuildContext context, int index) {
                  Store store = filteredStoreNames[index];
                  return Container(
                    height: 10,
                    child: CheckboxListTile(
                      value: storeCheckStatus[store.id],
                      onChanged: (bool? value) {
                        setState(() {
                          storeCheckStatus[store.id] = value!;
                          if (value) {
                            Provider.of<selectedStores>(context, listen: false)
                                .addStore(store.id);
                            logger.i('Store ID added: ${store.id}');

                            sendStoreID(context);
                          } else {
                            Provider.of<selectedStores>(context, listen: false)
                                .removeStore(store.id);
                            logger.i('Store ID removed: ${store.id}');
                          }
                        });
                      },
                      title: Text(
                        store.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 199, 219, 235),
                        ),
                      ),
                      subtitle: Text(
                        store.id,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 108, 235, 207),
                        ),
                      ),
                      secondary: const Icon(Icons.store),
                      activeColor: Colors.green,
                      tileColor: Colors.grey[200],
                      selectedTileColor: Colors.grey[300],
                      // contentPadding: EdgeInsets.all(16.0),
                    ),
                  );

                  ///
                },
              ),
            ),
////
          ),
        ],
      ),
    );
  }
}
