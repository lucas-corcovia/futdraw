import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/helpers/team_generator.dart';
import 'package:futdraw/models/enums/theme_color.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/views/teams_display/widgets/field_controls.dart';
import 'package:futdraw/views/teams_display_view.dart';

void main() {
  testWidgets('a area capturada termina antes dos controles do campo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(ThemeColor.violeta, true),
        home: TeamsDisplayScreen(teams: [Team(name: 'Time 1', players: [])]),
      ),
    );
    await tester.pumpAndSettle();

    final fieldBoundary =
        find
            .ancestor(
              of: find.text('Time 1'),
              matching: find.byType(RepaintBoundary),
            )
            .first;
    final controls = find.byType(FieldControls);
    expect(fieldBoundary, findsOneWidget);
    expect(controls, findsOneWidget);
    expect(
      tester.getBottomLeft(fieldBoundary).dy,
      lessThan(tester.getTopLeft(controls).dy),
    );
    expect(tester.renderObject(fieldBoundary), isA<RenderRepaintBoundary>());
  });
}
