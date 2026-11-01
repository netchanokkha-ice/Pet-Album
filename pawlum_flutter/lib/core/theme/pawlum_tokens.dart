import 'package:flutter/material.dart';

abstract final class PawlumColors {
  static const pink = Color(0xFFF7B6C6);
  static const pinkSoft = Color(0xFFFFE5EC);
  static const pinkStrong = Color(0xFF9C3A5C);
  static const purple = Color(0xFFC8B4E8);
  static const purpleStrong = Color(0xFF5B3FB0);
  static const yellow = Color(0xFFFFE08A);
  static const yellowStrong = Color(0xFF7A5800);
  static const mint = Color(0xFFBFE3D0);
  static const paper = Color(0xFFFFFCF7);
  static const paperMuted = Color(0xFFF7F0E8);
  static const canvas = Color(0xFFFAF9F5);
  static const ink = Color(0xFF2D2424);
  static const inkMuted = Color(0xFF6E6262);
  static const outline = Color(0xFFE3D8CF);
}

abstract final class PawlumSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const xxxl = 64.0;
}

abstract final class PawlumRadii {
  static const control = 12.0;
  static const card = 20.0;
  static const sheet = 28.0;
  static const round = 999.0;
}

abstract final class PawlumShadows {
  static const paper = <BoxShadow>[
    BoxShadow(color: Color(0x242D2424), offset: Offset(0, 5), blurRadius: 18),
  ];

  static const lifted = <BoxShadow>[
    BoxShadow(color: Color(0x302D2424), offset: Offset(0, 9), blurRadius: 28),
  ];
}

abstract final class PawlumMotion {
  static const quick = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 220);
  static const relaxed = Duration(milliseconds: 360);
  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;
}

abstract final class PawlumBreakpoints {
  static const compactMax = 600.0;
  static const mediumMax = 1024.0;
}

enum PawlumWindowClass { compact, medium, expanded }

@immutable
class PawlumLayoutTheme extends ThemeExtension<PawlumLayoutTheme> {
  const PawlumLayoutTheme({
    required this.windowClass,
    required this.pagePadding,
    required this.contentMaxWidth,
    required this.sectionGap,
    required this.cardRadius,
  });

  factory PawlumLayoutTheme.forWidth(double width) {
    if (width < PawlumBreakpoints.compactMax) {
      return const PawlumLayoutTheme(
        windowClass: PawlumWindowClass.compact,
        pagePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        contentMaxWidth: 560,
        sectionGap: PawlumSpacing.lg,
        cardRadius: 18,
      );
    }

    if (width < PawlumBreakpoints.mediumMax) {
      return const PawlumLayoutTheme(
        windowClass: PawlumWindowClass.medium,
        pagePadding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        contentMaxWidth: 720,
        sectionGap: PawlumSpacing.xl,
        cardRadius: PawlumRadii.card,
      );
    }

    return const PawlumLayoutTheme(
      windowClass: PawlumWindowClass.expanded,
      pagePadding: EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      contentMaxWidth: 960,
      sectionGap: PawlumSpacing.xxl,
      cardRadius: PawlumRadii.sheet,
    );
  }

  final PawlumWindowClass windowClass;
  final EdgeInsets pagePadding;
  final double contentMaxWidth;
  final double sectionGap;
  final double cardRadius;

  static PawlumLayoutTheme of(BuildContext context) {
    return Theme.of(context).extension<PawlumLayoutTheme>()!;
  }

  @override
  PawlumLayoutTheme copyWith({
    PawlumWindowClass? windowClass,
    EdgeInsets? pagePadding,
    double? contentMaxWidth,
    double? sectionGap,
    double? cardRadius,
  }) {
    return PawlumLayoutTheme(
      windowClass: windowClass ?? this.windowClass,
      pagePadding: pagePadding ?? this.pagePadding,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
      sectionGap: sectionGap ?? this.sectionGap,
      cardRadius: cardRadius ?? this.cardRadius,
    );
  }

  @override
  PawlumLayoutTheme lerp(
    covariant ThemeExtension<PawlumLayoutTheme>? other,
    double t,
  ) {
    if (other is! PawlumLayoutTheme) {
      return this;
    }

    return PawlumLayoutTheme(
      windowClass: t < 0.5 ? windowClass : other.windowClass,
      pagePadding: EdgeInsets.lerp(pagePadding, other.pagePadding, t)!,
      contentMaxWidth: _lerpDouble(contentMaxWidth, other.contentMaxWidth, t),
      sectionGap: _lerpDouble(sectionGap, other.sectionGap, t),
      cardRadius: _lerpDouble(cardRadius, other.cardRadius, t),
    );
  }

  static double _lerpDouble(double start, double end, double t) {
    return start + (end - start) * t;
  }
}
