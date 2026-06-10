// lib/widgets/form_buttons.dart
import 'package:flutter/material.dart';

class FormButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onClear;
  final bool isSaving;
  final String saveText;
  final String clearText;
  final bool isSaveEnabled;

  const FormButtons({
    Key? key,
    required this.onSave,
    required this.onClear,
    this.isSaving = false,
    this.saveText = 'Save',
    this.clearText = 'Clear',
    this.isSaveEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isSaveEnabled && !isSaving ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(saveText),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: Text(clearText),
          ),
        ),
      ],
    );
  }
}
