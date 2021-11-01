import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notification _screen/notification_screen.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifCount = Provider.of<int>(context);
    return Padding(
      padding: EdgeInsets.only(
        right: MediaQuery.of(context).padding.right + 10,
        top: MediaQuery.of(context).padding.top + 5,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.notifications,
              color: Colors.black,
              size: 36,
            ),
          ),
          notifCount < 1
              ? const SizedBox()
              : Positioned(
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
                    child: Text(
                      '$notifCount',
                      style: const TextStyle(
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
