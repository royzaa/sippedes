import 'package:flutter/material.dart';

import '../../../../services/firestore_services.dart';
import '../../../../model/profile.dart';

class BiodataList extends StatelessWidget {
  const BiodataList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double bottomSpacing = 25.0;
    return FutureBuilder(
      future: FirestoreServices.getUserProfile(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final userProfile = snapshot.data as Profile;

        bool isLessThan17() {
          int yOb = int.parse(userProfile.ttgl.split(' ')[3]);
          int ages = DateTime.now().year - yOb;
          if (ages >= 17) {
            return false;
          } else {
            return true;
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...['Nama', 'NIK', 'Jenis Kelamin', 'Alamat', 'Tgl'].map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: bottomSpacing),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...[...(':' * 5).split('')].map(
                      (colon) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: bottomSpacing,
                          right: 15,
                          left: 10,
                        ),
                        child: Text(
                          colon,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...[
                      userProfile.name,
                      userProfile.nik,
                      userProfile.gender,
                      userProfile.address,
                      userProfile.ttgl
                    ].map(
                      (value) => Padding(
                        padding: const EdgeInsets.only(bottom: bottomSpacing),
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            isLessThan17()
                ? const Text(
                    'Umur anda kurang dari 17 tahun, anda belum memiliki izin membuat surat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }
}
