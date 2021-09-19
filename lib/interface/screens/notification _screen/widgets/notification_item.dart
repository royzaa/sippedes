import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../services/firestore_services.dart';
import '../../../../services/shared_preferences.dart';
import '../../letter_form/letter_form.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem(
      {Key? key,
      required this.body,
      required this.date,
      required this.readStatus,
      required this.letterId,
      required this.title})
      : super(key: key);
  final String title, body, date, readStatus, letterId;

  @override
  Widget build(BuildContext context) {
    final bool isAlreadyRead = readStatus == 'read';
    final Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        FirestoreServices.changeLetterStatus(
            registredNIK: DataSharedPreferences.getNIK(),
            letterId: letterId,
            readStatus: 'read');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LetterForm(
              letterName: title,
              appColor: Colors.white,
              tabIndex: 1,
            ),
          ),
        );
      },
      child: Container(
        color: isAlreadyRead
            ? Colors.white
            : Colors.grey.shade300.withOpacity(0.4),
        width: size.width,
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 12,
              width: 12,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isAlreadyRead ? Colors.black : Colors.white),
                color: isAlreadyRead ? Colors.transparent : Colors.green,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    body,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight:
                          isAlreadyRead ? FontWeight.w400 : FontWeight.bold,
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
