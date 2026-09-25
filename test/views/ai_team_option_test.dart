import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/views/team_generator_view.dart';

void main() {
  testWidgets('opcao de IA aparece e conserva a quantidade de times', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeamGenerationScreen(
          preselectedGroup: Group(id: 'grupo-1', nome: 'Amigos'),
        ),
      ),
    );

    expect(find.text('Sortear com IA'), findsOneWidget);
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.ensureVisible(find.text('Sortear com IA'));
    await tester.tap(find.text('Sortear com IA'));
    await tester.pumpAndSettle();

    expect(find.text('Instruções Personalizadas'), findsOneWidget);
    expect(find.text('Número de Times: 4'), findsOneWidget);
  });
}
