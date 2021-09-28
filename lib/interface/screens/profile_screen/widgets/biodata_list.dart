import 'package:flutter/material.dart';

import '../../../../services/firestore_services.dart';
import '../../../../services/auth_services.dart';
import '../../../../model/profile.dart';

class BiodataList extends StatelessWidget {
  const BiodataList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    // const double bottomSpacing = 25.0;
    final Size size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: FirestoreServices.getUserProfile(auth.getCurrentUser!.uid),
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  size.height < 600 ? size.height * 0.45 : size.height * 0.45,
              maxWidth: size.width * 0.85,
            ),
            child: LayoutBuilder(
              builder: (context, constrains) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...[
                                  'Nama',
                                  'NIK',
                                  'Jenis Kelamin',
                                  'Alamat',
                                  'Tgl'
                                ].map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: SizedBox(
                                      height: constrains.maxHeight * 0.07,
                                      child: FittedBox(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ...[...(':' * 5).split('')].map(
                                  (colon) => Padding(
                                    padding: const EdgeInsets.only(
                                      // bottom: bottomSpacing,
                                      right: 15,
                                      left: 10,
                                    ),
                                    child: SizedBox(
                                      height: constrains.maxHeight * 0.07,
                                      child: FittedBox(
                                        child: Text(
                                          colon,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...[
                                  userProfile.name,
                                  userProfile.nik,
                                  userProfile.gender,
                                  userProfile.address,
                                  userProfile.ttgl
                                ].map(
                                  (value) => Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: SizedBox(
                                      height: value.length > 21
                                          ? constrains.maxHeight * 0.058
                                          : constrains.maxHeight * 0.07,
                                      child: FittedBox(
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      isLessThan17()
                          ? const Flexible(
                              child: Text(
                                'Umur anda kurang dari 17 tahun, anda belum memiliki izin membuat surat.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
