import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/components/widgets/player_avatar.dart';
import 'package:futdraw/utils/player_photo.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

void main() {
  test('encodes a bounded JPEG data URI and reads it back', () {
    final source = img.Image(width: 900, height: 600);
    img.fill(source, color: img.ColorRgb8(60, 120, 180));

    final value = PlayerPhoto.encode(Uint8List.fromList(img.encodePng(source)));
    expect(value, startsWith('data:image/jpeg;base64,'));
    final bytes = base64Decode(value.split(',').last);
    expect(bytes.length, lessThanOrEqualTo(100 * 1024));
    final decoded = img.decodeJpg(bytes)!;
    expect(decoded.width, 384);
    expect(decoded.height, lessThanOrEqualTo(384));
    expect(PlayerPhoto.provider(value), isA<MemoryImage>());
  });

  test('keeps old URLs readable and ignores broken data URIs', () {
    expect(
      PlayerPhoto.provider('https://example.com/photo.jpg'),
      isA<NetworkImage>(),
    );
    expect(PlayerPhoto.provider('data:image/jpeg;base64,%%%'), isNull);
    expect(
      () => PlayerPhoto.encode(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });

  testWidgets('renders a stored photo in the player avatar', (tester) async {
    final source = img.Image(width: 64, height: 64);
    img.fill(source, color: img.ColorRgb8(60, 120, 180));
    final value = PlayerPhoto.encode(Uint8List.fromList(img.encodePng(source)));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PlayerAvatar(url: value, name: 'Ana', size: 48)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
