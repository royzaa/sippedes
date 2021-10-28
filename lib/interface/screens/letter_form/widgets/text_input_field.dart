import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    Key? key,
    required this.color,
    required this.controller,
    required this.fieldName,
    this.customValidator,
    this.onChanged,
    this.suffixIcon,
    this.inputType,
    this.isEnable = true,
    this.isCustom = false,
    this.isUnderline = true,
  }) : super(key: key);

  /// TextEditingContorller for input
  final TextEditingController controller;

  /// color of cursor and border
  final Color color;

  /// execute every time the text value in controller changed
  final void Function(String)? onChanged;

  /// Display in text form title and default validator
  final String fieldName;

  /// enable or disable text field
  final bool? isEnable;

  /// Is custom without text form title above text field and sized
  /// box below text field
  final bool isCustom;
  final bool isUnderline;

  /// Custom validator for spesific input field
  final String? Function(String?)? customValidator;

  /// set keyboard input type
  final TextInputType? inputType;

  /// suffic icon
  final Icon? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isCustom
              ? const SizedBox(
                  height: 10,
                )
              : Text(
                  fieldName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
          isEnable ?? true
              ? const SizedBox()
              : const SizedBox(
                  height: 15,
                ),
          TextFormField(
            keyboardType: inputType,
            onChanged: onChanged,
            enabled: isEnable,
            cursorColor: color,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: customValidator ??
                (value) {
                  if (value!.isEmpty) {
                    return '$fieldName tidak boleh kosong';
                  }
                  return null;
                },
            controller: controller,
            decoration: InputDecoration(
              border: isUnderline
                  ? const UnderlineInputBorder()
                  : const OutlineInputBorder(),
              focusColor: color,
              label: Text(fieldName),
              suffixIcon: suffixIcon,
            ),
          ),
          isCustom
              ? const SizedBox()
              : const SizedBox(
                  height: 30,
                ),
        ],
      ),
    );
  }
}
