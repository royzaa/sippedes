import 'package:flutter/material.dart';

import './widgets/notification_icon.dart';
import './widgets/letter_grid.dart';

class LetterScreen extends StatefulWidget {
  const LetterScreen({Key? key}) : super(key: key);

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  final _scrollController = ScrollController();

  bool lanchShadow = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollNotification>(
          onNotification: (notif) {
            if (_scrollController.position.pixels >
                MediaQuery.of(context).padding.top) {
              lanchShadow = true;
              setState(() {});
            } else {
              lanchShadow = false;
              setState(() {});
            }
            return true;
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 16 + 30 + 20,
                ),
                const ListTile(
                  leading: Icon(
                    Icons.article_rounded,
                    color: Colors.grey,
                    size: 32,
                  ),
                  title: Text(
                    'Pilih surat yang diajukan',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25, right: 20),
                  child: LetterGrid(),
                ),
              ],
            ),
          ),
        ),

        // white containter as appbar to overlap lottie
        Container(
          width: size.width,
          height: MediaQuery.of(context).padding.top + 16 + 35 + 5,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(lanchShadow ? 0.4 : 0.0),
              blurRadius: 50,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            )
          ]),
        ),

        // greatings + name in appbar
        Positioned(
          left: 56,
          top: MediaQuery.of(context).padding.top + 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Selamat pagi',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Bapak Budi',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
        // app bar icon

        Positioned(
          top: MediaQuery.of(context).padding.top,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.person,
              size: 32,
              color: Colors.black,
            ),
          ),
        ),
        const Positioned(
          right: 0,
          child: NotificationIcon(),
        ),
      ],
    );
  }
}