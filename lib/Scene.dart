// 필요한 Flutter 패키지들을 가져옵니다.
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:adminapp/utils.dart';

// Scene이라는 이름의 상태가 없는 위젯을 정의.
class Scene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 기본 너비를 정의합니다.
    double baseWidth = 64;
    // 장치의 너비와 기본 너비를 기반으로 'fem' 값을 계산합니다.
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // 'fem'의 97%로 'ffem' 값을 계산합니다.
    double ffem = fem * 0.97;

    // 컨테이너 위젯을 반환합니다.
    return Container(
      // 컨테이너의 너비를 무한대(전체 너비)로 설정합니다.
      width: double.infinity,
      child: Container(
        // 이 컨테이너에 패딩을 추가합니다.
        padding: EdgeInsets.fromLTRB(0 * fem, 20 * fem, 0 * fem, 10 * fem),
        width: double.infinity,
        height: 800 * fem,
        // 이 컨테이너의 데코레이션(색상 및 그림자 포함)을 설정합니다.
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000),
              offset: Offset(1 * fem, 1 * fem),
              blurRadius: 7.5 * fem,
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // 자식 위젯들을 조직하기 위해 컬럼을 사용합니다.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.fromLTRB(8 * fem, 0 * fem, 8 * fem, 31 * fem),
                padding:
                    EdgeInsets.fromLTRB(8 * fem, 0 * fem, 8 * fem, 0 * fem),
                width: double.infinity,
                height: 56 * fem,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 32 * fem,
                    height: 32 * fem,
                    // assets에서 이미지를 표시합니다.
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 24 * fem),
                      child: Image.asset(
                        'assets/page-1/images/component-2.png',
                        width: 32 * fem,
                        height: 32 * fem,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          8 * fem, 0 * fem, 8 * fem, 391 * fem),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 여러 개의 컨테이너를 반복하여 다양한 이미지를 표시합니다.
                          Container(
                            width: 48 * fem,
                            height: 48 * fem,
                            child: Image.asset(
                              'assets/page-1/images/frame-12.png',
                              width: 48 * fem,
                              height: 48 * fem,
                            ),
                          ),
                          SizedBox(
                            height: 14 * fem,
                          ),
                          Container(
                            width: 48 * fem,
                            height: 48 * fem,
                            child: Image.asset(
                              'assets/page-1/images/frame-13.png',
                              width: 48 * fem,
                              height: 48 * fem,
                            ),
                          ),
                          SizedBox(
                            height: 14 * fem,
                          ),
                          Container(
                            width: 48 * fem,
                            height: 48 * fem,
                            child: Image.asset(
                              'assets/page-1/images/frame-14.png',
                              width: 48 * fem,
                              height: 48 * fem,
                            ),
                          ),
                          SizedBox(
                            height: 14 * fem,
                          ),
                          Container(
                            width: 48 * fem,
                            height: 48 * fem,
                            child: Image.asset(
                              'assets/page-1/images/frame-15.png',
                              width: 48 * fem,
                              height: 48 * fem,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          8 * fem, 10 * fem, 8 * fem, 0 * fem),
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 48 * fem,
                          height: 48 * fem,
                          child: Image.asset(
                            'assets/page-1/images/frame-11.png',
                            width: 48 * fem,
                            height: 48 * fem,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
