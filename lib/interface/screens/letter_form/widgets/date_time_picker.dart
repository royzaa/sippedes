import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './text_input_field.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({
    Key? key,
    required this.color,
    required this.onDateValue,
    required this.onTimeValue,
  }) : super(key: key);

  final Color color;
  final void Function(String) onDateValue;
  final void Function(String) onTimeValue;

  @override
  State<DateTimePicker> createState() => _BirthState();
}

class _BirthState extends State<DateTimePicker> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  late ValueNotifier<bool> _timeIsEmpty;
  late String _date, _time;

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
          _dateController.text = DateFormat('EEE, d MMMM y').format(date);
          _date = _dateController.text;
          widget.onDateValue(_date);
        });
      }
    });
  }

  void pickTime() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        _timeIsEmpty.value = false;
        setState(() {
          final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
          _timeController.text = '${time.hour} : ${time.minute} $period';
          _time = _timeController.text;
          widget.onTimeValue(_time);
        });
      }
    });
  }

  @override
  void initState() {
    _timeIsEmpty = ValueNotifier(_timeController.text.isEmpty);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Row(
              children: [
                SizedBox(
                  width: size.width * 0.7,
                  child: TextInputField(
                      isEnable: false,
                      isUnderline: false,
                      onChanged: (value) {
                        _timeIsEmpty.value = value.isEmpty;
                      },
                      color: widget.color,
                      controller: _timeController,
                      fieldName: 'Jam'),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: IconButton(
                    onPressed: pickTime,
                    icon: const Icon(Icons.alarm_outlined),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            child: Row(
              children: [
                SizedBox(
                    width: size.width * 0.7,
                    child: TextInputField(
                        isUnderline: false,
                        color: widget.color,
                        controller: _dateController,
                        isEnable: false,
                        fieldName: 'Tanggal')),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ValueListenableBuilder(
                      valueListenable: _timeIsEmpty,
                      builder: (_, bool textIsEmpty, __) {
                        debugPrint(textIsEmpty.toString());
                        return IconButton(
                          onPressed: textIsEmpty ? null : pickDate,
                          icon: const Icon(Icons.calendar_today_rounded),
                        );
                      }),
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
