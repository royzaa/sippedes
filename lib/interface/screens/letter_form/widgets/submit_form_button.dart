import 'package:flutter/material.dart';

class SubmitFormButton extends StatefulWidget {
  const SubmitFormButton(
      {Key? key,
      required this.color,
      required this.isLoading,
      required this.submitForm})
      : super(key: key);
  final Color color;
  final bool isLoading;
  final Function(BuildContext) submitForm;

  @override
  _SubmitFormButtonState createState() => _SubmitFormButtonState();
}

class _SubmitFormButtonState extends State<SubmitFormButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 30,
        shadowColor: widget.color.withOpacity(0.5),
        primary: Colors.black,
        padding: widget.isLoading
            ? null
            : const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
        shape: widget.isLoading
            ? const CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
      ),
      onPressed: widget.isLoading ? null : () => widget.submitForm(context),
      child: widget.isLoading
          ? Center(
              child: CircularProgressIndicator(color: widget.color),
            )
          : Text(
              'Simpan dan ajukan',
              style: TextStyle(
                color: widget.color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
