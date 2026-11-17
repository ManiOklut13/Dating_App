import 'package:flutter/material.dart';

/// App-wide theme palette tokens adhering to the YoUnMe design specification.
/// Supports both Light Mode and Cyber Luxe Dark Mode.
class AppColors {
  AppColors._();

  // Core brand accents
  static const Color flamePink = Color(0xFFE11D48); // Vibrant Crimson / Rose
  static const Color flameHotPink = Color(0xFFEC4899); // Hot Pink
  static const Color flamePurple = Color(0xFF9B51E0);
  static const Color cyanAccent = Color(0xFF38BDF8); // Verified Blue Badge
  static const Color goldAccent = Color(0xFFF59E0B); // Streak Flame / Ruby Amber
  static const Color onlineGreen = Color(0xFF22C55E); // Active / Match Green
  static const Color rubyPink = Color(0xFFFB7185); // Ruby Pink
  static const Color offlineGrey = Color(0xFF8E8E93);
  static const Color errorRed = Color(0xFFFF4757);

  // Dark Mode Surfaces & Backgrounds - Deep dark plum/void black (#0D070C to #140A12)
  static const Color darkBackground = Color(0xFF0D070C);
  static const Color darkSurface = Color(0xFF140A12);
  static const Color darkCard = Color(0xFF1B1119);
  static const Color darkElevated = Color(0xFF1E131C);
  static const Color darkBorder = Color(0xFF2E1E2B);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkIncomingBubble = Color(0xFF241822);

  // Light Mode Surfaces & Backgrounds
  static const Color lightBackground = Color(0xFFF9F6F0); // Warm cream / warm white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF2ECE4);
  static const Color lightBorder = Color(0x1A2D1B2E);
  static const Color lightTextPrimary = Color(0xFF231826); // Dark plum / charcoal
  static const Color lightTextSecondary = Color(0xFF6B5E6E);
  static const Color lightTextMuted = Color(0xFF9A8D9D);
  static const Color lightIncomingBubble = Color(0xFFEDE7DF);

  // Brand Gradients
  static const LinearGradient flameGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleLightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFDFBF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// ThemeExtension to provide tailored semantic colors that adapt seamlessly
/// between Light and Dark modes.
class YoUnMeThemeExtension extends ThemeExtension<YoUnMeThemeExtension> {
  final Color bgSurface;
  final Color bgCard;
  final Color bgElevated;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color incomingBubble;
  final Color incomingBubbleText;
  final Color outgoingBubble;
  final Color outgoingBubbleText;
  final Color badgeBackground;
  final Color searchFill;
  final Color onlineDot;
  final Color offlineDot;

  const YoUnMeThemeExtension({
    required this.bgSurface,
    required this.bgCard,
    required this.bgElevated,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.incomingBubble,
    required this.incomingBubbleText,
    required this.outgoingBubble,
    required this.outgoingBubbleText,
    required this.badgeBackground,
    required this.searchFill,
    required this.onlineDot,
    required this.offlineDot,
  });

  static const dark = YoUnMeThemeExtension(
    bgSurface: AppColors.darkSurface,
    bgCard: AppColors.darkCard,
    bgElevated: AppColors.darkElevated,
    borderSubtle: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    incomingBubble: AppColors.darkIncomingBubble,
    incomingBubbleText: Colors.white,
    outgoingBubble: AppColors.flamePink,
    outgoingBubbleText: Colors.white,
    badgeBackground: AppColors.flamePink,
    searchFill: Color(0xFF141826),
    onlineDot: AppColors.onlineGreen,
    offlineDot: AppColors.offlineGrey,
  );

  static const light = YoUnMeThemeExtension(
    bgSurface: AppColors.lightSurface,
    bgCard: AppColors.lightCard,
    bgElevated: AppColors.lightElevated,
    borderSubtle: AppColors.lightBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    incomingBubble: AppColors.lightIncomingBubble,
    incomingBubbleText: AppColors.lightTextPrimary,
    outgoingBubble: AppColors.flamePink,
    outgoingBubbleText: Colors.white,
    badgeBackground: Color(0xFFE6204E),
    searchFill: Color(0xFFECE5DC),
    onlineDot: AppColors.onlineGreen,
    offlineDot: AppColors.offlineGrey,
  );

  @override
  ThemeExtension<YoUnMeThemeExtension> copyWith({
    Color? bgSurface,
    Color? bgCard,
    Color? bgElevated,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? incomingBubble,
    Color? incomingBubbleText,
    Color? outgoingBubble,
    Color? outgoingBubbleText,
    Color? badgeBackground,
    Color? searchFill,
    Color? onlineDot,
    Color? offlineDot,
  }) {
    return YoUnMeThemeExtension(
      bgSurface: bgSurface ?? this.bgSurface,
      bgCard: bgCard ?? this.bgCard,
      bgElevated: bgElevated ?? this.bgElevated,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      incomingBubble: incomingBubble ?? this.incomingBubble,
      incomingBubbleText: incomingBubbleText ?? this.incomingBubbleText,
      outgoingBubble: outgoingBubble ?? this.outgoingBubble,
      outgoingBubbleText: outgoingBubbleText ?? this.outgoingBubbleText,
      badgeBackground: badgeBackground ?? this.badgeBackground,
      searchFill: searchFill ?? this.searchFill,
      onlineDot: onlineDot ?? this.onlineDot,
      offlineDot: offlineDot ?? this.offlineDot,
    );
  }

  @override
  ThemeExtension<YoUnMeThemeExtension> lerp(
    covariant ThemeExtension<YoUnMeThemeExtension>? other,
    double t,
  ) {
    if (other is! YoUnMeThemeExtension) return this;
    return YoUnMeThemeExtension(
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      incomingBubble: Color.lerp(incomingBubble, other.incomingBubble, t)!,
      incomingBubbleText: Color.lerp(incomingBubbleText, other.incomingBubbleText, t)!,
      outgoingBubble: Color.lerp(outgoingBubble, other.outgoingBubble, t)!,
      outgoingBubbleText: Color.lerp(outgoingBubbleText, other.outgoingBubbleText, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
      searchFill: Color.lerp(searchFill, other.searchFill, t)!,
      onlineDot: Color.lerp(onlineDot, other.onlineDot, t)!,
      offlineDot: Color.lerp(offlineDot, other.offlineDot, t)!,
    );
  }
}

/// Helper extension on BuildContext to quickly access YoUnMeThemeExtension
extension ThemeHelper on BuildContext {
  YoUnMeThemeExtension get appTheme =>
      Theme.of(this).extension<YoUnMeThemeExtension>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? YoUnMeThemeExtension.dark
          : YoUnMeThemeExtension.light);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
