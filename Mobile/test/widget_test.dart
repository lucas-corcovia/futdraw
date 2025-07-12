import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/views/home_view.dart';
import 'package:provider/provider.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/configurations_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeView exibe título e botão', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PlayerController()),
          ChangeNotifierProvider(create: (_) => GroupController()),
          ChangeNotifierProvider(create: (_) => ConfigurationsController()),
        ],
        child: MaterialApp(home: HomeView()),
      ),
    );

    expect(find.text('FutDraw'), findsOneWidget);
  });
}
