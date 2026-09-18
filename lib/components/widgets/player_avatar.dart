import 'package:flutter/material.dart';
import 'package:futdraw/theme/app_tokens.dart';

/// Avatar de jogador do app inteiro.
///
/// Substitui os `Image.network` crus que existiam em tres lugares -- sem
/// `errorBuilder`, sem placeholder e, o mais caro, sem `cacheWidth`: uma foto
/// em resolucao cheia decodificada para um circulo de 44 px desperdica dezenas
/// de MB de memoria por tela.
///
/// Nao usa `cached_network_image`: o `ImageCache` do Flutter ja deduplica por
/// URL em memoria, sao no maximo 22 fotos por tela, e o pacote esta com
/// manutencao parada e relatos de vazamento. Se as fotos passarem a piscar
/// entre telas, ai sim vale reavaliar um cache em disco.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.url,
    required this.name,
    required this.size,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? url;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  static const String _fallbackAsset = 'assets/images/jogador_nao_encontrado.png';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = backgroundColor ?? scheme.surfaceContainerHighest;
    final foreground = foregroundColor ?? scheme.onSurfaceVariant;

    final cacheWidth =
        (size * MediaQuery.devicePixelRatioOf(context)).round().clamp(1, 2048);

    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: background,
          child: url == null || url!.isEmpty
              ? _Initial(name: name, size: size, color: foreground)
              : Image.network(
                  url!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  cacheWidth: cacheWidth,
                  frameBuilder: (context, child, frame, wasSync) {
                    if (wasSync) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: AppMotion.fast,
                      curve: AppMotion.settling,
                      child: child,
                    );
                  },
                  // Placeholder que segura o layout: pop-in e deslocamento sao
                  // defeitos visiveis.
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                      ? child
                      : _Initial(name: name, size: size, color: foreground),
                  errorBuilder: (context, error, stack) => Image.asset(
                    _fallbackAsset,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    cacheWidth: cacheWidth,
                    errorBuilder: (context, error, stack) =>
                        _Initial(name: name, size: size, color: foreground),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.size, required this.color});

  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: color,
        ),
      ),
    );
  }
}
