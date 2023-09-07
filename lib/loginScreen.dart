import 'package:adminapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adminapp/tokenModel.dart';

import 'package:adminapp/mainView.dart';
import 'package:adminapp/store.dart';
import 'package:adminapp/selectedStores.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug, // 출력할 로그 레벨을 설정
  // 이 예시에서는 debug 레벨을 사용
);

// class loginScreen extends StatelessWidget {
// class loginScreen extends StatefulWidget {

class loginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('savedId');
    String? savedPassword = prefs.getString('savedPassword');

    if (savedId != null && savedPassword != null) {
      idController.text = savedId;
      passwordController.text = savedPassword;
      _isChecked = true;
    }
  }

  _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('savedId', idController.text);
    prefs.setString('savedPassword', passwordController.text);
  }

  _clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('savedId');
    prefs.remove('savedPassword');
  }

  Future<String?> performLogin(String id, String password) async {
    // String url = 'http://192.168.0.171:10000/api/v1/authenticate/login';
    String url = 'https://storepop.io/api/v2/authenticate/login';
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> body = {
      "id": id,
      "pw": password,
    };

    try {
      var response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      // 응답 코드 확인
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        //서버로 부터 accessToken과 refreshToken 을 모두 받아옴.
        String? accessToken = data["access"];
        String? refreshToken = data["refresh"];

        // 토큰 값 확인
        if (accessToken != null && refreshToken != null) {
          logger.i('Received access token: $accessToken');
          logger.i('Received refresh token: $refreshToken');

          // Save the tokens to shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('refreshToken', refreshToken);

          return accessToken;
        } else {
          logger.e('No token in response.');
          return 'No token in response';
        }
      } else {
        logger.e('Login failed. Please check your credentials.');
        return '로그인에 실패하였습니다. 아이디나 비밀번호를 확인해주세요.';
      }
    } catch (e) {
      logger.e('Error occurred during login: $e');
      return 'Error occurred during login: $e';
    }
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    String url = 'https://storepop.io/api/v2/authenticate/refresh';
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, String> body = {
      "refresh": refreshToken,
    };

    try {
      var response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      // 응답 코드 확인
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String? accessToken = data["access"];

        // 토큰 값 확인
        if (accessToken != null) {
          logger.i('Received new access token: $accessToken');

          // Save the new access token to shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);

          return accessToken;
        } else {
          logger.e('No access token in response.');
          return 'No access token in response';
        }
      } else {
        logger.e('Failed to refresh access token.');
        return 'Failed to refresh access token.';
      }
    } catch (e) {
      logger.e('Error occurred during token refresh: $e');
      return 'Error occurred during token refresh: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 1280;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    bool _isChecked = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          // CBj (1:11)
          padding: EdgeInsets.fromLTRB(107 * fem, 0 * fem, 0 * fem, 0 * fem),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                // frame61093vvM (1:15)
                margin:
                    EdgeInsets.fromLTRB(0 * fem, 0 * fem, 106 * fem, 44 * fem),
                width: 310 * fem,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // frame61092dZs (1:16)
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 176 * fem),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            // frame16MEy (1:17)
                            margin: EdgeInsets.fromLTRB(
                                71 * fem, 0 * fem, 71 * fem, 35 * fem),
                            padding: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0.01 * fem, 0 * fem),
                            width: double.infinity,
                            height: 32 * fem,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  // component3v57 (1:18)
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 12 * fem, 0 * fem),
                                  width: 32 * fem,
                                  height: 32 * fem,
                                  child: Image.asset(
                                    'assets/page-1/images/component-3.png',
                                    width: 32 * fem,
                                    height: 32 * fem,
                                  ),
                                ),
                                Container(
                                  // intermindslogoblue2oPo (1:19)
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 6 * fem, 0 * fem, 6.09 * fem),
                                  height: double.infinity,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        // vectorqrH (1:20)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 3.81 * fem, 0.31 * fem),
                                        width: 2.57 * fem,
                                        height: 18.36 * fem,
                                        decoration: BoxDecoration(
                                          color: Color(0xff0f1f4b),
                                        ),
                                      ),
                                      Container(
                                        // vectorXz1 (1:21)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 1.33 * fem, 0.31 * fem),
                                        width: 11.25 * fem,
                                        height: 12.6 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-Mtd.png',
                                          width: 11.25 * fem,
                                          height: 12.6 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectorpTK (1:22)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 1.82 * fem, 0 * fem),
                                        width: 8.73 * fem,
                                        height: 16.05 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-ZW9.png',
                                          width: 8.73 * fem,
                                          height: 16.05 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectorvWM (1:23)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 2.43 * fem, 0 * fem),
                                        width: 12.75 * fem,
                                        height: 12.91 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-kCH.png',
                                          width: 12.75 * fem,
                                          height: 12.91 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectorqtD (1:24)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 3.27 * fem, 0.31 * fem),
                                        width: 7.34 * fem,
                                        height: 12.6 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-N7j.png',
                                          width: 7.34 * fem,
                                          height: 12.6 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectorm1B (1:25)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 3.24 * fem, 0.31 * fem),
                                        width: 19.77 * fem,
                                        height: 18.36 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector.png',
                                          width: 19.77 * fem,
                                          height: 18.36 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectorfsF (1:26)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 2.82 * fem, 0.31 * fem),
                                        width: 3.54 * fem,
                                        height: 18.41 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-oBF.png',
                                          width: 3.54 * fem,
                                          height: 18.41 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectorNmf (1:27)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 2.56 * fem, 0.31 * fem),
                                        width: 11.25 * fem,
                                        height: 12.6 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-mW9.png',
                                          width: 11.25 * fem,
                                          height: 12.6 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectoruFo (1:28)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 2.12 * fem, 0 * fem),
                                        width: 13.34 * fem,
                                        height: 19.91 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-K53.png',
                                          width: 13.34 * fem,
                                          height: 19.91 * fem,
                                        ),
                                      ),
                                      Container(
                                        // vectordSh (1:29)
                                        width: 10.05 * fem,
                                        height: 12.91 * fem,
                                        child: Image.asset(
                                          'assets/page-1/images/vector-tW5.png',
                                          width: 10.05 * fem,
                                          height: 12.91 * fem,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // frame61091ZbF (1:30)
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  // frame61090uf7 (1:31)
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 0 * fem, 19 * fem),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        // frame61089Suw (1:32)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 0 * fem, 23 * fem),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // frame61085amF (1:33)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  0 * fem,
                                                  16 * fem),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    // emailWeu (1:34)
                                                    margin: EdgeInsets.fromLTRB(
                                                        0 * fem,
                                                        0 * fem,
                                                        0 * fem,
                                                        5 * fem),
                                                    width: double.infinity,
                                                    child: Text(
                                                      'id',
                                                      textAlign: TextAlign.left,
                                                      style: SafeGoogleFont(
                                                        'Pretendard',
                                                        fontSize: 16 * ffem,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height:
                                                            1.2575 * ffem / fem,
                                                        color:
                                                            Color(0xff1f252a),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    // frame61084mqj (1:35)
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            34.5 * fem,
                                                            10 * fem,
                                                            34.5 * fem,
                                                            8 * fem),
                                                    width: double.infinity,
                                                    height: 35 * fem,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Color(
                                                              0xffe9ebee)),
                                                      color: Color(0xffffffff),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5 * fem),
                                                    ),

                                                    child: TextField(
                                                      controller: idController,
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      decoration:
                                                          InputDecoration(
                                                        border: InputBorder
                                                            .none, // 테두리 없음
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical:
                                                                    14), // 콘텐츠 패딩 설정
                                                        hintText:
                                                            '아이디를 입력해주세요.', // 힌트 텍스트
                                                        hintStyle: TextStyle(
                                                          fontFamily:
                                                              'Pretendard',
                                                          fontSize: 13 * ffem,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.2575 *
                                                              ffem /
                                                              fem,
                                                          color:
                                                              Color(0xffc5c8ce),
                                                        ),
                                                      ),
                                                      textAlign: TextAlign
                                                          .center, // 힌트 텍스트 가운데 정렬
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              // frame610872Fs (1:37)
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    // passwordZmb (1:38)
                                                    margin: EdgeInsets.fromLTRB(
                                                        0 * fem,
                                                        0 * fem,
                                                        0 * fem,
                                                        5 * fem),
                                                    width: double.infinity,
                                                    child: Text(
                                                      'Password',
                                                      textAlign: TextAlign.left,
                                                      style: SafeGoogleFont(
                                                        'Pretendard',
                                                        fontSize: 16 * ffem,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height:
                                                            1.7 * ffem / fem,
                                                        color:
                                                            Color(0xff1f252a),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    // frame61084g5X (1:39)
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            36.5 * fem,
                                                            10 * fem,
                                                            36.5 * fem,
                                                            8 * fem),
                                                    width: double.infinity,
                                                    height: 35 * fem,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Color(
                                                              0xffe9ebee)),
                                                      color: Color(0xffffffff),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5 * fem),
                                                    ),

                                                    child: TextField(
                                                      controller:
                                                          passwordController,
                                                      obscureText: true,
                                                      decoration:
                                                          InputDecoration(
                                                        border: InputBorder
                                                            .none, // 테두리 없음
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical:
                                                                    14), // 콘텐츠 패딩 설정
                                                        hintText:
                                                            '비밀번호를 입력해주세요.', // 힌트 텍스트
                                                        hintStyle: TextStyle(
                                                          fontFamily:
                                                              'Pretendard',
                                                          fontSize: 13 * ffem,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          //1.2575
                                                          height: 1.2575 *
                                                              ffem /
                                                              fem,
                                                          // height: 200,
                                                          color:
                                                              Color(0xffc5c8ce),
                                                        ),
                                                      ),
                                                      textAlign: TextAlign
                                                          .center, // 힌트 텍스트 가운데 정렬
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //로그인 시작
                                      Container(
                                        // frame61088wXF (1:41)
                                        width: double.infinity,
                                        height: 43 * fem,
                                        decoration: BoxDecoration(
                                          color: Color(0xff00c3ff),
                                          borderRadius:
                                              BorderRadius.circular(5 * fem),
                                        ),

/////////////////
                                        ///

                                        child: ElevatedButton(
                                          onPressed: () async {
                                            String id = idController.text;
                                            String password =
                                                passwordController.text;

                                            if (id.isEmpty ||
                                                password.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        '아이디나 비밀번호를 입력해주세요.')),
                                              );
                                              return;
                                            }
                                            // if (_isRememberMeChecked) {
                                            //   final prefs =
                                            //       await SharedPreferences
                                            //           .getInstance();
                                            //   prefs.setString(
                                            //       'savedId', idController.text);
                                            //   prefs.setString('savedPassword',
                                            //       passwordController.text);
                                            // }

                                            try {
                                              String? token =
                                                  await performLogin(
                                                      id, password);
                                              if (token != null) {
                                                Provider.of<tokenModel>(context,
                                                        listen: false)
                                                    .setAccessToken = token;

                                                List<Store> stores =
                                                    await fetchStores(context);
                                                if (stores.isNotEmpty) {
                                                  Provider.of<selectedStores>(
                                                          context,
                                                          listen: false)
                                                      .addStore(stores[0].id);
                                                  logger.d(
                                                      '첫번째 store Id :${stores[0].id}');
                                                }

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        mainView(),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          '로그인에 실패하였습니다. 아이디나 비밀번호를 확인해주세요.')),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        '로그인에 실패하였습니다. 아이디나 비밀번호를 확인해주세요.')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xff00c3ff),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            height: 56,
                                            child: Center(
                                              child: Text(
                                                'Log in',
                                                textAlign: TextAlign.center,
                                                style: SafeGoogleFont(
                                                  'Pretendard',
                                                  fontSize: 16 * ffem,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.2575 * ffem / fem,
                                                  color: Color(0xffffffff),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  width: double.infinity,
                                  child: CheckboxListTile(
                                    title: Text(
                                      'ID, PW 저장하기',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff6f777e),
                                      ),
                                    ),
                                    tileColor: _isChecked
                                        ? Colors.yellow.withOpacity(0.3)
                                        : null, // 체크됐을 때 연한 노란색으로 하이라이트
                                    value: _isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isChecked = value!;
                                      });

                                      if (_isChecked) {
                                        _saveCredentials();
                                      } else {
                                        _clearCredentials();
                                      }
                                    },
                                  ),
                                )

                                // Container(
                                //     // didyouforgetyourpasswordNsT (1:43)
                                //     width: double.infinity,
                                //     child: Row(
                                //       children: [
                                //         Checkbox(
                                //           value: _isRememberMeChecked,
                                //           onChanged: (value) {
                                //             setState(() {
                                //               _isRememberMeChecked = value!;
                                //             });
                                //           },
                                //         ),
                                //         Text("ID와 비밀번호 저장하기")
                                //       ],
                                //     )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      // orsignup5G5 (1:44)
                      'or Sign Up',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Pretendard',
                        fontSize: 16 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1.2575 * ffem / fem,
                        color: Color(0xff00c3ff),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // autogroupkijuCbb (YRf9wnUpEpXPKbPf2GKiJu)
                padding: EdgeInsets.fromLTRB(
                    178.5 * fem, 339 * fem, 177.5 * fem, 339 * fem),
                height: 800 * fem,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/page-1/images/image-7-bg.png',
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // autonomousstoreUJD (1:13)
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 5 * fem),
                      child: Text(
                        'Autonomous Store',
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'Pretendard',
                          fontSize: 24 * ffem,
                          fontWeight: FontWeight.w400,
                          height: 1.2575 * ffem / fem,
                          color: Color(0xffffffff),
                        ),
                      ),
                    ),
                    Container(
                      // reshapingretailstorewitheyeoft (1:14)
                      constraints: BoxConstraints(
                        maxWidth: 401 * fem,
                      ),
                      child: Text(
                        'Re-shaping retail store with\neye of the future.',
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'Pretendard',
                          fontSize: 34 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.2575 * ffem / fem,
                          color: Color(0xffffffff),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ////여기
      ),
    );

    //widget 끝
  }
}
