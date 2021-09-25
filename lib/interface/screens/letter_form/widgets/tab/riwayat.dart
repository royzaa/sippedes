import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../model/notification.dart';

class Riwayat extends StatelessWidget {
  const Riwayat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<List<NotificationModel>>(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            height: 30,
          ),
          const Text(
            'Riwayat pengajuan surat anda',
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: DataTable(
              columns: const [
                DataColumn(
                  numeric: true,
                  label: Text('No.'),
                ),
                DataColumn(
                  label: Text('Jenis surat'),
                ),
                DataColumn(
                  label: Text('Tanggal proses'),
                ),
                DataColumn(
                  label: Text('Status'),
                ),
              ],
              rows: [
                ...data.asMap().entries.map(
                  (entry) {
                    final int index = entry.key + 1;
                    final NotificationModel notification = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            index.toString(),
                          ),
                        ),
                        DataCell(
                          Text(notification.title),
                        ),
                        DataCell(
                          Text(notification.date),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Text(notification.readStatus),
                              const SizedBox(
                                width: 7,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      notification.readStatus.toLowerCase() ==
                                              "terkirim"
                                          ? Colors.yellow
                                          : Colors.green,
                                ),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
