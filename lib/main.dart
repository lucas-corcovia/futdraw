import 'package:flutter/material.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:futdraw/views/home_view.dart';
import 'package:provider/provider.dart' as statemanagement;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBHelper.initializeDatabase();

  runApp(
    statemanagement.MultiProvider(
      providers: [
        statemanagement.ChangeNotifierProvider(
          create: (_) => PlayerController(),
        ),
        statemanagement.ChangeNotifierProvider(
          create: (_) => GroupController(),
        ),
        // Adicione mais providers aqui, se necessário
      ],
      child: FutDrawApp(),
    ),
  );
}

class FutDrawApp extends StatelessWidget {
  FutDrawApp({super.key});

  final ThemeData lightTheme = ThemeData(
    fontFamily: 'Kanit',
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFFFFFFF),
    primaryColor: Color.fromARGB(255, 57, 105, 59),
    colorScheme: ColorScheme.light(
      primary: Color.fromARGB(255, 57, 105, 59),
      secondary: Color(0xFFFFC107),
      surface: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFF212121),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF212121),
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF212121)),
      bodyMedium: TextStyle(color: Color(0xFF757575)),
    ),
    iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
  );

  final ThemeData darkTheme = ThemeData(
    fontFamily: 'Kanit',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF121212),
    primaryColor: Color.fromARGB(255, 57, 105, 59),
    colorScheme: ColorScheme.dark(
      primary: Color.fromARGB(255, 57, 105, 59),
      secondary: Color.fromARGB(255, 31, 78, 32),
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Color.fromARGB(255, 57, 105, 59),
      unselectedLabelColor: Colors.white,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 57, 105, 59),
          width: 2,
        ),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Color.fromARGB(255, 57, 105, 59),
      inactiveTrackColor: Color.fromARGB(255, 57, 105, 59).withAlpha(77),
      thumbColor: Color.fromARGB(255, 57, 105, 59),
      overlayColor: Color.fromARGB(255, 57, 105, 59).withAlpha(48),
      valueIndicatorColor: Color.fromARGB(255, 57, 105, 59),
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedColor: Color.fromARGB(255, 57, 105, 59),
      secondarySelectedColor: Color.fromARGB(255, 57, 105, 59),
      labelStyle: TextStyle(color: Color(0xFF212121).withAlpha(222)),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: StadiumBorder(
        side: BorderSide(color: Color.fromARGB(255, 57, 105, 59)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Color.fromARGB(255, 57, 105, 59);
        }
        return Color(0xFF757575); // dark
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Color.fromARGB(255, 57, 105, 59).withAlpha(128);
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
            return Color.fromARGB(255, 57, 105, 59).withAlpha(77);
          }
          return Color.fromARGB(255, 57, 105, 59); // dark
        }),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
    ),
    iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutDraw',
      theme: darkTheme,
      home: const HomeView(),
    );
  }
}
