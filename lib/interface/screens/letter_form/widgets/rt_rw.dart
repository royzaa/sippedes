import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RtRw extends StatelessWidget {
  const RtRw({
    Key? key,
    required this.color,
    required this.rtController,
    required this.rWController,
    required this.fieldName,
    this.customValidator,
    this.onChanged,
    this.suffixIcon,
    this.inputType,
    this.isEnable = true,
    this.isUnderline = true,
  }) : super(key: key);

  /// TextEditingContorller for input
  final TextEditingController rtController;

  /// TextEditingContorller for input
  final TextEditingController rWController;

  /// color of cursor and border
  final Color color;

  /// execute every time the text value in controller changed
  final void Function(String)? onChanged;

  /// Display in text form title and default validator
  final String fieldName;

  /// enable or disable text field
  final bool? isEnable;

  final bool isUnderline;

  /// Custom validator for spesific input field
  final String? Function(String?)? customValidator;

  /// set keyboard input type
  final TextInputType? inputType;

  /// suffic icon
  final Icon? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width.w * 0.3,
            child: Column(
              children: [
                Text(
                  'RT',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
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
                          return 'RT tidak boleh kosong';
                        }
                        return null;
                      },
                  controller: rtController,
                  decoration: InputDecoration(
                    border: isUnderline
                        ? const UnderlineInputBorder()
                        : const OutlineInputBorder(),
                    focusColor: color,
                    label: Text(fieldName),
                    suffixIcon: suffixIcon,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 25.w,
          ),
          SizedBox(
            width: size.width.w * 0.3,
            child: Column(
              children: [
                Text(
                  'RW',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
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
                          return 'RW tidak boleh kosong';
                        }
                        return null;
                      },
                  controller: rWController,
                  decoration: InputDecoration(
                    border: isUnderline
                        ? const UnderlineInputBorder()
                        : const OutlineInputBorder(),
                    focusColor: color,
                    label: Text(fieldName),
                    suffixIcon: suffixIcon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
