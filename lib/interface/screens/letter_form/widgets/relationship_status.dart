import 'package:flutter/material.dart';

class RelationshipStatus extends StatelessWidget {
  const RelationshipStatus({Key? key, required this.relationshipStatus})
      : super(key: key);
  final void Function(String?) relationshipStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Perkawinan',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropdownButtonFormField<String?>(
            decoration: const InputDecoration(
              label: Text('Status Perkawinan'),
            ),
            validator: (String? value) {
              if (value == null) {
                return 'Status perkawinan harus diisi';
              }
            },
            onChanged: (String? value) {
              relationshipStatus(value);
            },
            items: [
              ...['Belum kawin', 'Kawin', 'Cerai hidup', 'Cerai mati'].map(
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
