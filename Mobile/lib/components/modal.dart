import 'package:flutter/material.dart';

class CustomModal extends StatefulWidget {
  final String titulo;
  final VoidCallback? onFechar;
  final Widget content;

  const CustomModal({
    super.key,
    this.titulo = 'Modal Customizada',
    this.onFechar,
    required this.content,
  });

  @override
  State<CustomModal> createState() => _CustomModalState();
}

class _CustomModalState extends State<CustomModal> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.titulo, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 15),
            Column(children: [widget.content]),
          ],
        ),
      ),
    );
  }
}
