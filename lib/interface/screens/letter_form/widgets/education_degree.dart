import 'package:flutter/material.dart';

class EducationDegree extends StatelessWidget {
  const EducationDegree({Key? key, required this.education}) : super(key: key);
  final TextEditingController education;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pendidikan',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropdownButtonFormField(
            decoration: const InputDecoration(
              label: Text('Tingkat pendidikan'),
            ),
            validator: (String? value) {
              if (value == null) {
                return 'Pendidikan harus diisi';
              }
            },
            onChanged: (String? value) {
              education.text = value ?? 'Tingkat pendidikan';
            },
            items: [
              ...['SD', 'SMP', 'SMA', 'S1', 'S2', 'S3'].map(
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
