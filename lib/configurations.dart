import 'package:bfast/options.dart';
import 'package:flutter/material.dart';

// 0xFF0b2e13
// class Config{
const primaryColor = Color(0xff000000);

MaterialColor getSmartStockMaterialColorSwatch() {
  Color color = const Color(0xff2c2c2c);
  List strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
// }

const maxSmallScreen = 640;
const maxMediumScreen = 1007;
// const MAX_LARGE_SCREEN = > 1008

App smartstockApp =
    App(applicationId: 'smartstock_lb', projectId: 'smartstock');
