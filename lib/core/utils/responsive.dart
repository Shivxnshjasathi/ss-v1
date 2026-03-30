import 'package:flutter/widgets.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static late bool isTablet;
  static late bool isMobile;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    isMobile = screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 1200;
  }

  /// Scaling for Width
  static double w(double width) {
    return (width / 375.0) * screenWidth; // 375 is standard mobile width
  }

  /// Scaling for Height
  static double h(double height) {
    return (height / 812.0) * screenHeight; // 812 is standard mobile height
  }

  /// Scaling for Text (SP)
  static double sp(double fontSize) {
    return (fontSize / 375.0) * screenWidth;
  }
}

extension ResponsiveExtension on num {
  /// Scaling for Width
  double get w => Responsive.w(this.toDouble());

  /// Scaling for Height
  double get h => Responsive.h(this.toDouble());

  /// Scaling for Text (SP)
  double get sp => Responsive.sp(this.toDouble());
}

extension BuildContextResponsive on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && MediaQuery.of(this).size.width < 1200;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
