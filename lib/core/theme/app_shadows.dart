import 'package:flutter/material.dart';

/// Shadow tokens extracted from the reference design.
/// Diffused, ultra-soft elevations without sharp/muddy borders.
class AppShadows {
  AppShadows._();

  /// Subtle shadow for segmented pills and small chips
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Floating cards and sheet shadows
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Default shadow for pure white content cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Floating bottom pill bar shadow
  static const List<BoxShadow> floatingNav = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 24,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  /// Frosted glass circular back button shadow
  static const List<BoxShadow> glassButton = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Glowing needle on the prayer semicircular dial
  static const List<BoxShadow> dialNeedleGlow = [
    BoxShadow(
      color: Color(0x99FFFFFF),
      blurRadius: 10,
      spreadRadius: 2,
    ),
  ];

  /// Spiritual crescent glowing ring shadow on splash & loader
  static const List<BoxShadow> crescentGlow = [
    BoxShadow(
      color: Color(0x6610B981),
      blurRadius: 24,
      spreadRadius: 4,
    ),
  ];
}

