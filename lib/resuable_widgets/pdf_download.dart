//resuable pdf download button
import 'package:flutter/material.dart';

class ReusableDownloadPdfButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ReusableDownloadPdfButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('PDF'),
      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
    );
  }
}
