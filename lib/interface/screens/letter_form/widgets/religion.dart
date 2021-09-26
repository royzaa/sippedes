import 'package:flutter/material.dart';

class Religion extends StatelessWidget {
  const Religion({Key? key, required this.religion}) : super(key: key);
  final TextEditingController religion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agama',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropdownButtonFormField(
            decoration: const InputDecoration(
              label: Text('Pilih Agama'),
            ),
            validator: (String? value) {
              if (value == null) {
                return 'Agama harus diisi';
              }
            },
            value: 'Konghucu',
            onChanged: (String? value) {
              religion.text = value ?? 'Tingkat pendidikan';
            },
            items: [
              ...['Konghucu', 'Katolik', 'Islam', 'Budha', 'Kristen', 'Hindu']
                  .map(
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
