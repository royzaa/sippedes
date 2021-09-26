import 'package:flutter/material.dart';

class FamilyStatus extends StatelessWidget {
  const FamilyStatus({Key? key, required this.familyStatus}) : super(key: key);
  final void Function(String?) familyStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status hubungan dalam keluarga',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropdownButtonFormField<String?>(
            decoration: const InputDecoration(
              label: Text('Status hubungan dalam keluarga'),
            ),
            validator: (String? value) {
              if (value == null) {
                return 'Status hubungan dalam keluarga harus diisi';
              }
            },
            onChanged: (String? value) {
              familyStatus(value);
            },
            items: [
              ...[
                'KK',
                'Suami',
                'Istri',
                'Anak',
                'Cucu',
                'Menantu',
                'Mertua',
                'Orang tua',
                'Family lain',
                'Pembantu',
                'Lainnya'
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
