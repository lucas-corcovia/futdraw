import 'package:flutter/material.dart';
import 'package:futdraw/models/consts/app.colors.dart';
import 'package:futdraw/models/enums/theme_color.dart';

class ThemeSelector {
  static ThemeData get(ThemeColor selected) {
    switch (selected) {
      case ThemeColor.green:
        return _green;
      case ThemeColor.blue:
        return _blue;
      case ThemeColor.purple:
        return _purple;
      case ThemeColor.red:
        return _red;
    }
  }

  static final ThemeData _green = ThemeData(
    fontFamily: 'Kanit',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CommonsColors.scaffoldBackgroundColor,
    primaryColor: ThemeColors.green.primary,
    colorScheme: ColorScheme.dark(
      primary: ThemeColors.green.primary,
      secondary: ThemeColors.green.secondary,
      surface: CommonsColors.surfaceColor,
      onPrimary: CommonsColors.onPrimaryColor,
      onSecondary: Colors.black,
      onSurface: CommonsColors.onSurfaceColor,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: ThemeColors.green.label,
      unselectedLabelColor: CommonsColors.unselectedLabelColor,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: ThemeColors.green.label, width: 2),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: ThemeColors.green.primary,
      inactiveTrackColor: ThemeColors.green.primary.withAlpha(77),
      thumbColor: ThemeColors.green.thumb,
      overlayColor: ThemeColors.green.overlay,
      valueIndicatorColor: ThemeColors.green.primary,
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CommonsColors.surfaceColor,
      selectedColor: ThemeColors.green.primary,
      secondarySelectedColor: ThemeColors.green.primary,
      labelStyle: TextStyle(color: Color(0xFF212121).withAlpha(222)),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: StadiumBorder(side: BorderSide(color: ThemeColors.green.primary)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.green.primary;
        }
        return Color(0xFF757575); // dark
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.green.primary.withAlpha(128);
        }
        return Color(0xFF757575).withAlpha(100);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((states) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          );
        }),
        padding: WidgetStateProperty.resolveWith((states) {
          return EdgeInsets.symmetric(vertical: 16);
        }),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(color: Colors.white, fontSize: 16); // dark
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return ThemeColors.green.primary.withAlpha(77);
          }
          return ThemeColors.green.primary; // dark
        }),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CommonsColors.surfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: CommonsColors.bodyMediumColor),
    ),
    iconTheme: IconThemeData(color: CommonsColors.iconColor),
  );

  static final ThemeData _blue = ThemeData(
    fontFamily: 'Kanit',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CommonsColors.scaffoldBackgroundColor,
    primaryColor: ThemeColors.blue.primary,
    colorScheme: ColorScheme.dark(
      primary: ThemeColors.blue.primary,
      secondary: ThemeColors.blue.secondary,
      surface: CommonsColors.surfaceColor,
      onPrimary: CommonsColors.onPrimaryColor,
      onSecondary: Colors.black,
      onSurface: CommonsColors.onSurfaceColor,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: ThemeColors.blue.label,
      unselectedLabelColor: CommonsColors.unselectedLabelColor,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: ThemeColors.blue.label, width: 2),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: ThemeColors.blue.primary,
      inactiveTrackColor: ThemeColors.blue.primary.withAlpha(77),
      thumbColor: ThemeColors.blue.thumb,
      overlayColor: ThemeColors.blue.overlay,
      valueIndicatorColor: ThemeColors.blue.primary,
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CommonsColors.surfaceColor,
      selectedColor: ThemeColors.blue.primary,
      secondarySelectedColor: ThemeColors.blue.primary,
      labelStyle: TextStyle(color: Color(0xFF212121).withAlpha(222)),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: StadiumBorder(side: BorderSide(color: ThemeColors.blue.primary)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.blue.primary;
        }
        return Color(0xFF757575); // dark
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.blue.primary.withAlpha(128);
        }
        return Color(0xFF757575).withAlpha(100);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((states) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          );
        }),
        padding: WidgetStateProperty.resolveWith((states) {
          return EdgeInsets.symmetric(vertical: 16);
        }),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(color: Colors.white, fontSize: 16); // dark
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return ThemeColors.blue.primary.withAlpha(77);
          }
          return ThemeColors.blue.primary; // dark
        }),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CommonsColors.surfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: CommonsColors.bodyMediumColor),
    ),
    iconTheme: IconThemeData(color: CommonsColors.iconColor),
  );

  static final ThemeData _purple = ThemeData(
    fontFamily: 'Kanit',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CommonsColors.scaffoldBackgroundColor,
    primaryColor: ThemeColors.purple.primary,
    colorScheme: ColorScheme.dark(
      primary: ThemeColors.purple.primary,
      secondary: ThemeColors.purple.secondary,
      surface: CommonsColors.surfaceColor,
      onPrimary: CommonsColors.onPrimaryColor,
      onSecondary: Colors.black,
      onSurface: CommonsColors.onSurfaceColor,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: ThemeColors.purple.label,
      unselectedLabelColor: CommonsColors.unselectedLabelColor,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: ThemeColors.purple.label, width: 2),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: ThemeColors.purple.primary,
      inactiveTrackColor: ThemeColors.purple.primary.withAlpha(77),
      thumbColor: ThemeColors.purple.thumb,
      overlayColor: ThemeColors.purple.overlay,
      valueIndicatorColor: ThemeColors.purple.primary,
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CommonsColors.surfaceColor,
      selectedColor: ThemeColors.purple.primary,
      secondarySelectedColor: ThemeColors.purple.primary,
      labelStyle: TextStyle(color: Color(0xFF212121).withAlpha(222)),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: StadiumBorder(side: BorderSide(color: ThemeColors.purple.primary)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.purple.primary;
        }
        return Color(0xFF757575); // dark
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.purple.primary.withAlpha(128);
        }
        return Color(0xFF757575).withAlpha(100);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((states) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          );
        }),
        padding: WidgetStateProperty.resolveWith((states) {
          return EdgeInsets.symmetric(vertical: 16);
        }),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(color: Colors.white, fontSize: 16); // dark
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return ThemeColors.purple.primary.withAlpha(77);
          }
          return ThemeColors.purple.primary; // dark
        }),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CommonsColors.surfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: CommonsColors.bodyMediumColor),
    ),
    iconTheme: IconThemeData(color: CommonsColors.iconColor),
  );

  static final ThemeData _red = ThemeData(
    fontFamily: 'Kanit',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CommonsColors.scaffoldBackgroundColor,
    primaryColor: ThemeColors.red.primary,
    colorScheme: ColorScheme.dark(
      primary: ThemeColors.red.primary,
      secondary: ThemeColors.red.secondary,
      surface: CommonsColors.surfaceColor,
      onPrimary: CommonsColors.onPrimaryColor,
      onSecondary: Colors.black,
      onSurface: CommonsColors.onSurfaceColor,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: ThemeColors.red.label,
      unselectedLabelColor: CommonsColors.unselectedLabelColor,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: ThemeColors.red.label, width: 2),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: ThemeColors.red.primary,
      inactiveTrackColor: ThemeColors.red.primary.withAlpha(77),
      thumbColor: ThemeColors.red.thumb,
      overlayColor: ThemeColors.red.overlay,
      valueIndicatorColor: ThemeColors.red.primary,
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CommonsColors.surfaceColor,
      selectedColor: ThemeColors.red.primary,
      secondarySelectedColor: ThemeColors.red.primary,
      labelStyle: TextStyle(color: Color(0xFF212121).withAlpha(222)),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: StadiumBorder(side: BorderSide(color: ThemeColors.red.primary)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.red.primary;
        }
        return Color(0xFF757575); // dark
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ThemeColors.red.primary.withAlpha(128);
        }
        return Color(0xFF757575).withAlpha(100);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((states) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          );
        }),
        padding: WidgetStateProperty.resolveWith((states) {
          return EdgeInsets.symmetric(vertical: 16);
        }),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(color: Colors.white, fontSize: 16); // dark
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return ThemeColors.red.primary.withAlpha(77);
          }
          return ThemeColors.red.primary; // dark
        }),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CommonsColors.surfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: CommonsColors.bodyMediumColor),
    ),
    iconTheme: IconThemeData(color: CommonsColors.iconColor),
  );
}
