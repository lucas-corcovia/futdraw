import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Photos are stored in the existing urlFoto text field as small JPEG data URIs.
/// Older players can still have an HTTP URL in that field.
class PlayerPhoto {
  static const _prefix = 'data:image/jpeg;base64,';
  static const _maxBytes = 100 * 1024;
  static final _decoded = <String, MemoryImage>{};

  static String encode(Uint8List source) {
    if (source.length > 10 * 1024 * 1024) {
      throw const FormatException('Imagem muito grande');
    }
    final img.Image? decoded;
    try {
      decoded = img.decodeImage(source);
    } catch (_) {
      throw const FormatException('Imagem inválida');
    }
    if (decoded == null) throw const FormatException('Imagem inválida');

    final oriented = img.bakeOrientation(decoded);
    final resized =
        oriented.width <= 384 && oriented.height <= 384
            ? oriented
            : img.copyResize(
              oriented,
              width: oriented.width >= oriented.height ? 384 : null,
              height: oriented.height > oriented.width ? 384 : null,
            );
    for (final quality in [75, 60, 45]) {
      final bytes = img.encodeJpg(resized, quality: quality);
      if (bytes.length <= _maxBytes) return '$_prefix${base64Encode(bytes)}';
    }
    final smaller = img.copyResize(
      resized,
      width: resized.width >= resized.height ? 288 : null,
      height: resized.height > resized.width ? 288 : null,
    );
    final bytes = img.encodeJpg(smaller, quality: 45);
    if (bytes.length > _maxBytes) {
      throw const FormatException('Imagem muito grande');
    }
    return '$_prefix${base64Encode(bytes)}';
  }

  static ImageProvider? provider(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!value.startsWith('data:')) return NetworkImage(value);
    if (!value.startsWith(_prefix)) return null;
    final cached = _decoded.remove(value);
    if (cached != null) {
      _decoded[value] = cached;
      return cached;
    }
    try {
      final image = MemoryImage(base64Decode(value.substring(_prefix.length)));
      _decoded[value] = image;
      if (_decoded.length > 64) _decoded.remove(_decoded.keys.first);
      return image;
    } on FormatException {
      return null;
    }
  }
}
