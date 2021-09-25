import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './text_input_field.dart';

class Birth extends StatefulWidget {
  const Birth({
    Key? key,
    required this.color,
    required this.onValue,
  }) : super(key: key);

  final Color color;
  final void Function(String) onValue;

  @override
  State<Birth> createState() => _BirthState();
}

class _BirthState extends State<Birth> {
  final TextEditingController _birthDate = TextEditingController();
  String _ttgl = '';

  void pickDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime(
        DateTime.now().year - 17,
        DateTime.now().month,
        DateTime.now().day,
      ),
      firstDate: DateTime(1921),
      lastDate: DateTime(
        DateTime.now().year - 17,
        DateTime.now().month,
        DateTime.now().day,
      ),
    ).then((date) {
      if (date != null) {
        setState(() {
          _birthDate.text = DateFormat.yMMMd().format(date);
          _ttgl += ' ${_birthDate.text}';
          widget.onValue(_ttgl);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tempat, tanggal lahir',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SelectState(
            onCountryChanged: (country) {},
            onStateChanged: (state) {},
            onCityChanged: (city) {
              _ttgl = city;
              widget.onValue(_ttgl);
              debugPrint(_ttgl);
              setState(() {});
            },
          ),
          SizedBox(
            child: Row(
              children: [
                SizedBox(
                  width: size.width * 0.7,
                  child: TextInputField(
                      isUnderline: false,
                      color: widget.color,
                      controller: _birthDate,
                      isEnable: false,
                      fieldName: 'Tanggal lahir'),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: IconButton(
                    onPressed: _ttgl.isEmpty ? null : pickDate,
                    icon: const Icon(Icons.calendar_today_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
