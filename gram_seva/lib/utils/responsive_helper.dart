import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;
  final double screenWidth;
  final double screenHeight;

  ResponsiveHelper(this.context)
    : screenWidth = MediaQuery.of(context).size.width,
      screenHeight = MediaQuery.of(context).size.height;

  static const double _phoneBreakpoint = 600;
  static const double _tabletBreakpoint = 1200;

  bool get isPhone => screenWidth < _phoneBreakpoint;
  bool get isTablet =>
      screenWidth >= _phoneBreakpoint && screenWidth < _tabletBreakpoint;
  bool get isWeb => screenWidth >= _tabletBreakpoint;

  double get scaleFactor {
    if (isPhone) {
      return 1.0;
    } else if (isTablet) {
      return 1.5;
    } else {
      return 2.0;
    }
  }
}
