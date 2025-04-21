import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  final String message;

  const Toast({super.key, required this.message});

  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 50.0,
            left: 20.0,
            right: 20.0,
            child: Toast(message: message),
          ),
    );

    // Exibe o toast
    overlay.insert(overlayEntry);

    // Remove o toast após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }
}
