import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    Key? key,
    required this.color,
    required this.controller,
    required this.fieldName,
    this.isEnable = true,
    this.isCustom = false,
    this.isUnderline = true,
  }) : super(key: key);
  final TextEditingController controller;
  final Color color;
  final String fieldName;
  final bool? isEnable;
  final bool isCustom;
  final bool isUnderline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isCustom
              ? const SizedBox()
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
            enabled: isEnable,
            cursorColor: color,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
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
