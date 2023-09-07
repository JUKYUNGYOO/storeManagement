//Flutter애플리케이션에 대한 사용자 정의 ScrollBehavior를 정의하고,
// 지정된 폰트를 가져올 수 없는 경우 대체 옵션을 가진
// Google Fonts를 안전하게 사용하기 위한 함수를 정의함.

// Flutter의 Material Design 패키지를 임포트합니다.
import 'package:flutter/material.dart';

// UI를 위한 Dart의 윈도우 패키지를 임포트합니다.
import 'dart:ui';

// Google Fonts 패키지를 임포트합니다.
import 'package:google_fonts/google_fonts.dart';

// Flutter의 MaterialScrollBehavior를 상속하여 사용자 정의 스크롤 동작을 정의합니다.
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // 'dragDevices' 게터를 오버라이드하여 터치와 마우스 입력을 포함합니다.
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

// Google Fonts를 안전하게 사용하기 위한 함수를 정의합니다.
TextStyle SafeGoogleFont(
  String fontFamily, {
  // 폰트 패밀리를 지정하는 필수 매개변수입니다.
  // 나머지 매개변수들은 선택적이며, 텍스트 스타일을 지정합니다.
  TextStyle? textStyle,
  Color? color,
  Color? backgroundColor,
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? wordSpacing,
  TextBaseline? textBaseline,
  double? height,
  Locale? locale,
  Paint? foreground,
  Paint? background,
  List<Shadow>? shadows,
  List<FontFeature>? fontFeatures,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
  double? decorationThickness,
}) {
  try {
    // Google Fonts에서 폰트를 가져옵니다.
    return GoogleFonts.getFont(
      fontFamily,
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  } catch (ex) {
    // 예외가 발생하면 'Source Sans Pro' 폰트를 기본으로 사용합니다.
    return GoogleFonts.getFont(
      "Source Sans Pro",
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }
}
