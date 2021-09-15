import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: MediaQuery.of(context).padding.right + 10,
        top: MediaQuery.of(context).padding.top + 5,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 36,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 21,
              height: 21,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
                border: Border.all(
                  color: Colors.white,
                  width: 1.8,
                ),
              ),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
