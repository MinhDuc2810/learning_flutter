import 'dart:ui';

class StringColor {
  static const String primary1 = "282A75";
  // static const String primary1 = "DC143C";
  static const String primary2 = "26A8E0";

  static const String textPrimary = "000000";
  static const String textGrey = "757575";

  static const String greyBackground = "F5F5F5";

  static const int disablePrimary1 = 0xb282A75;

  static const String boxBorder = "EEEEEE";

  static const String loginNofi ="#E4F5FF";
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
