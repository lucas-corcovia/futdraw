import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  final String message;
  bool isError;
  Toast({super.key, required this.message, this.isError = false});

  static void show(BuildContext context, String message, bool isError) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 50.0,
            left: 20.0,
            right: 20.0,
            child: Toast(message: message, isError: isError),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: !isError ? Colors.transparent : Colors.red.withAlpha(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color:
              !isError
                  ? Colors.black.withAlpha(100)
                  : Colors.red.withAlpha(100),
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
