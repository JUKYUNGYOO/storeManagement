import 'package:adminapp/imagebuttonOneDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:adminapp/selectedStores.dart';
import 'package:adminapp/tokenModel.dart';
import 'package:logger/logger.dart';
import 'package:adminapp/productDataTable_search.dart';
import 'package:adminapp/imagebuttonThreeDetails.dart';
import 'package:adminapp/imagebuttonTwoDetails.dart';
import 'package:adminapp/imagebuttonFourDetails.dart';
import 'package:adminapp/imagebuttonFiveDetails.dart';
import 'package:adminapp/imagebuttonSixDetails.dart';
import 'package:adminapp/imagebuttonSevenDetails.dart';
import 'package:adminapp/imagebuttonEightDetails.dart';

import 'navExpandProvider.dart';

var logger = Logger(
  level: Level.verbose,
  printer: PrettyPrinter(),
);

class storeManagement_scene1 extends StatefulWidget {
  @override
  _storeManagement_scene1_State createState() =>
      _storeManagement_scene1_State();
}

class _storeManagement_scene1_State extends State<storeManagement_scene1> {
  List<Widget> _StorepopButtons = [];
  Offset outPosition = const Offset(67.2, 297.7); // 출구
  Offset inPosition = const Offset(67.2, 195.2); //입구
  Map<int, List<int>> idToCompositionMap = {};

  //initialOffset에 대응하는 id를 저장하려면, initialOffset을 키로 id를 값으로
  //가지는 Map을 생성
  Map<Offset, int> offsetToIdMap = {};

  final TextEditingController _searchController = TextEditingController();
  String searchTerm = "";

  void handleResponse(Map<String, dynamic> responseJson) {
    final shelves = responseJson['shelves'];
    // 서버로부터 받은 JSON 응답에서 shelves를 가져옴

    List<Widget> Buttons = [];

    for (final shelf in shelves) {
      //매장관리 메뉴의 매장 레이아웃
      final id = shelf['id']; // 각 shelf의 id
      final type = shelf['type']; // 각 shelf의 type

      final List<int> composition = List<int>.from(shelf['composition']);
      idToCompositionMap[id] = composition;

      Offset initialOffset;
      String imageAsset;

      // id에 따라 initialOffset을 설정
      switch (id) {
        case 1:
          initialOffset = Offset(147.7, 81.9);
          break;
        case 2:
          initialOffset = Offset(269.7, 81.9);
          break;
        case 3:
          initialOffset = Offset(381.7, 81.9);
          break;
        case 4:
          initialOffset = Offset(455.1, 182.3);
          break;
        case 5:
          initialOffset = Offset(455.1, 286.9);
          break;
        case 6:
          initialOffset = Offset(387.9, 383.7);
          break;
        case 7:
          initialOffset = Offset(269.3, 383.7);
          break;
        case 8:
          initialOffset = Offset(142.1, 383.7);
          break;
        default:
          initialOffset = Offset(0, 0); // default value
          break;
      }

      //Map에 initialOffset과 id 저장
      offsetToIdMap[initialOffset] = id;

      // type에 따라 imageAsset을 설정
      switch (type) {
        case 'Lunchcase':
          imageAsset = 'assets/page-1/images/Lunchcase.png';
          break;
        case 'Freezer':
          imageAsset = 'assets/page-1/images/Freezer.png';
          break;
        case 'Fridge':
          imageAsset = 'assets/page-1/images/Fridge.png';
          break;
        case 'Hanger':
          imageAsset = 'assets/page-1/images/Shelf.png';
          break;
        case 'Shelf':
          imageAsset = 'assets/page-1/images/Shelf.png';
          break;
        default:
          imageAsset = 'assets/page-1/images/Shelf.png'; // default value
          break;
      }

      // initialOffset과 imageAsset을 사용하여 DraggableButton 위젯을 생성하고 리스트에 추가
// 이 부분이 수정됨.
//_StorepopButtons 리스트에 storepop_buttons 버튼을 추가함.
      Buttons.add(storepop_buttons(
        initialOffset: initialOffset,
        imageAsset: imageAsset,
        id: id,
        idToCompositionMap: idToCompositionMap,
      ));
    }

    // draggableButtons 리스트를 사용하여 상태를 업데이트
    setState(() {
      _StorepopButtons = Buttons;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData(context));
  }

  Future<void> fetchData(BuildContext context) async {
    final selectedStoresData =
        Provider.of<selectedStores>(context, listen: false);

    // 상점 ID 중 하나를 선택. 예를 들어, 첫 번째 상점 ID를 선택
    String selectedStoreId = selectedStoresData.selectedStoreIds.first;

    logger.d('Selected Store ID: $selectedStoreId');

    final response = await http.post(
      Uri.parse('https://storepop.io/api/v2/worker/store/layout'),
      body: json.encode({
        "store_id": {"\$oid": selectedStoreId}
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            // "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
            "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
      },
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      logger.d('Response JSON: $responseJson');
      handleResponse(responseJson);
      // clickStorePopButton(responseJson);
      //추가된 부분
    } else {
      logger.e('Server response: ${response.body}');
      throw Exception('Failed to load data from the server');
    }
  }

//위젯의 레이아웃을 결정하는 부분
  @override
  Widget build(BuildContext context) {
//Stack > children > Positioned
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          // children: _Buttons,
          children: [
            ..._StorepopButtons,
            image_inAndout(
                initialOffset: outPosition,
                imageAsset: 'assets/page-1/images/out.png'),
            image_inAndout(
                initialOffset: inPosition,
                imageAsset: 'assets/page-1/images/in.png'),
            Container(
                margin: EdgeInsets.only(right: 100.0, top: 100.0),
                alignment: Alignment.topRight,
                child: productDataTable_search()),
          ],
        ),
      ),
    );
  }
}

class storepop_buttons extends StatelessWidget {
  final Offset initialOffset;
  final String imageAsset;
  final int id; // id 필드 추가
  final Map<int, List<int>> idToCompositionMap;

  //storepop_buttons 위젯이 _MainViewState의 ValueNotifier에 접근 할 수 있게 하려면
  //해당 ValueNotifier을 외부에서 주입받아야 됨.

  storepop_buttons(
      {required this.initialOffset,
      required this.imageAsset,
      required this.id,
      required this.idToCompositionMap});

//각 버튼을 클릭 할 때 마다 버튼의 id가 로그로 출력
  void _onTap(BuildContext context) {
    // final composition = idToCompositionMap[id];
    final composition = idToCompositionMap[id] ?? [];

    logger.e('button id: $id, composition: $composition');

    switch (id) {
      // 이미지 버튼 1을 눌렀을 때, 다음의 화면으로 네비게이트 함.
      case 1:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonOneDetails(id, composition)),
        );
        break;
      case 2:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonTwoDetails(id, composition)),
        );
        break;
      case 3:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonThreeDetails(id, composition)),
        );
        break;
      case 4:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonFourDetails(id, composition)),
        );
        break;
      case 5:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonFiveDetails(id, composition)),
        );
        break;
      case 6:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonSixDetails(id, composition)),
        );
        break;
      case 7:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonSevenDetails(id, composition)),
        );
        break;
      case 8:
        var provider = Provider.of<navExpandProvider>(context, listen: false);
        provider.isSideNavExpanded = !provider.isSideNavExpanded;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => imagebuttonEightDetails(id, composition)),
        );
        break;

      default:
        // Default action
        break;
    }
  }

  Widget build(BuildContext context) {
    return Positioned(
      top: initialOffset.dy,
      left: initialOffset.dx,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Image.asset(imageAsset, width: 70, height: 70),
      ),
    );
  }
}

class image_inAndout extends StatelessWidget {
  final Offset initialOffset;
  final String imageAsset;

  image_inAndout({required this.initialOffset, required this.imageAsset});

//각 버튼을 클릭 할 때 마다 버튼의 id가 로그로 출력

  Widget build(BuildContext context) {
    return Positioned(
      top: initialOffset.dy,
      left: initialOffset.dx,
      child: Image.asset(imageAsset, width: 70, height: 70),
    );
  }
}
