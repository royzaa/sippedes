import 'package:flutter/material.dart';

class BloodType extends StatelessWidget {
  const BloodType({Key? key, required this.bloodType}) : super(key: key);
  final TextEditingController bloodType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Golongan darah',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropdownButtonFormField(
            decoration: const InputDecoration(
              label: Text('Pilih goloh darah'),
            ),
            validator: (String? value) {
              if (value == null) {
                return 'Golongan darah harus diisi';
              }
            },
            onChanged: (String? value) {
              bloodType.text = value ?? 'Tidak tahu';
            },
            items: [
              ...[
                'A',
                'B',
                'AB',
                '0',
                'A+',
                'A-',
                'B+',
                'B-',
                'AB+',
                'AB-',
                '0+',
                '0-',
                'Tidak tahu'
              ].map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
