import 'package:flutter/material.dart';

class ResponsiveSizes {
  const ResponsiveSizes._();

  static const double mobileBreakpoint = 320;
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 900;

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < tabletBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}

class ResponsiveFontSizes {
  const ResponsiveFontSizes._();

  static double caption(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 10, tablet: 11, desktop: 12);
  }

  static double bodySmall(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 12, tablet: 13, desktop: 14);
  }

  static double bodyMedium(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 14, tablet: 15, desktop: 16);
  }

  static double labelSmall(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 11, tablet: 12, desktop: 13);
  }

  static double labelMedium(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 12, tablet: 13, desktop: 14);
  }

  static double titleSmall(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 14, tablet: 15, desktop: 16);
  }

  static double titleMedium(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 16, tablet: 18, desktop: 20);
  }

  static double titleLarge(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 20, tablet: 22, desktop: 24);
  }

  static double headlineSmall(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 22, tablet: 26, desktop: 28);
  }

  static double headlineMedium(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 24, tablet: 28, desktop: 32);
  }
}

class ResponsiveSpacing {
  const ResponsiveSpacing._();

  static double xs(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 4, tablet: 6, desktop: 8);
  }

  static double sm(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 8, tablet: 10, desktop: 12);
  }

  static double md(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 12, tablet: 16, desktop: 20);
  }

  static double lg(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 16, tablet: 20, desktop: 24);
  }

  static double xl(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 20, tablet: 24, desktop: 32);
  }

  static double padding(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 16, tablet: 20, desktop: 24);
  }
}

class ResponsiveIconSizes {
  const ResponsiveIconSizes._();

  static double iconSmall(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 16, tablet: 18, desktop: 20);
  }

  static double iconMedium(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 20, tablet: 22, desktop: 24);
  }

  static double iconLarge(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 24, tablet: 28, desktop: 32);
  }

  static double avatar(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 64, tablet: 72, desktop: 80);
  }

  static double colorCircle(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 24, tablet: 28, desktop: 32);
  }

  static double checkIcon(BuildContext context) {
    return ResponsiveSizes.value(context, mobile: 14, tablet: 16, desktop: 18);
  }
}

extension ResponsiveTextStyle on TextTheme {
  TextStyle responsiveBodySmall(BuildContext context) {
    return bodySmall?.copyWith(
          fontSize: ResponsiveFontSizes.bodySmall(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.bodySmall(context));
  }

  TextStyle responsiveBodyMedium(BuildContext context) {
    return bodyMedium?.copyWith(
          fontSize: ResponsiveFontSizes.bodyMedium(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.bodyMedium(context));
  }

  TextStyle responsiveLabelSmall(BuildContext context) {
    return labelSmall?.copyWith(
          fontSize: ResponsiveFontSizes.labelSmall(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.labelSmall(context));
  }

  TextStyle responsiveLabelMedium(BuildContext context) {
    return labelMedium?.copyWith(
          fontSize: ResponsiveFontSizes.labelMedium(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.labelMedium(context));
  }

  TextStyle responsiveTitleSmall(BuildContext context) {
    return titleSmall?.copyWith(
          fontSize: ResponsiveFontSizes.titleSmall(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.titleSmall(context));
  }

  TextStyle responsiveTitleMedium(BuildContext context) {
    return titleMedium?.copyWith(
          fontSize: ResponsiveFontSizes.titleMedium(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.titleMedium(context));
  }

  TextStyle responsiveTitleLarge(BuildContext context) {
    return titleLarge?.copyWith(
          fontSize: ResponsiveFontSizes.titleLarge(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.titleLarge(context));
  }

  TextStyle responsiveHeadlineSmall(BuildContext context) {
    return headlineSmall?.copyWith(
          fontSize: ResponsiveFontSizes.headlineSmall(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.headlineSmall(context));
  }

  TextStyle responsiveHeadlineMedium(BuildContext context) {
    return headlineMedium?.copyWith(
          fontSize: ResponsiveFontSizes.headlineMedium(context),
        ) ??
        TextStyle(fontSize: ResponsiveFontSizes.headlineMedium(context));
  }
}
