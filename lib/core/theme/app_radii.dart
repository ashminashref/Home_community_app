import 'package:flutter/material.dart';

/// Corner radius tokens extracted directly from the reference design.
class AppRadii {
  AppRadii._();

  /// Maximum roundness for pill CTA buttons, badges, floating bottom bar, story rings
  static const double pill = 999.0;
  static final BorderRadius pillBorder = BorderRadius.circular(pill);

  /// Top corners for bottom sheets (e.g. Prayer time timeline sheet)
  static const double sheet = 32.0;
  static const double sheetRadius = 32.0;
  static const BorderRadius sheetBorder = BorderRadius.only(
    topLeft: Radius.circular(sheet),
    topRight: Radius.circular(sheet),
  );

  /// Main cards: hero cards, community photo cards, habit tracking cards
  static const double card = 24.0;
  static final BorderRadius cardBorder = BorderRadius.circular(card);

  /// Nested media / thumbnails inside cards
  static const double innerImage = 16.0;
  static const double cardInner = 16.0;
  static final BorderRadius innerImageBorder = BorderRadius.circular(innerImage);
  static final BorderRadius cardInnerBorder = BorderRadius.circular(cardInner);

  /// Standard medium action buttons
  static const double button = 14.0;
  static final BorderRadius buttonBorder = BorderRadius.circular(button);

  /// Subtle small rounding for chips, search bar inputs, metric tiles
  static const double small = 10.0;
  static final BorderRadius smallBorder = BorderRadius.circular(small);
}

