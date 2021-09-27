import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_mail_app/open_mail_app.dart';

class DialogBox extends StatelessWidget {
  const DialogBox({
    Key? key,
  }) : super(key: key);

  List getFunction(BuildContext context) {
    late Future<void> Function() buttonOneFunc;
    late void Function() buttonTwoFunc;

    buttonOneFunc = () async {
      // Android: Will open mail app or show native picker.
      var result = await OpenMailApp.openMailApp(
        nativePickerTitle: 'Select email app to open',
      );
      // If no mail apps found, show error
      if (!result.didOpen && !result.canOpen) {
        showNoMailAppsDialog(context);
      } else if (!result.didOpen && result.canOpen) {
        showDialog(
          context: context,
          builder: (_) {
            return MailAppPickerDialog(
              mailApps: result.options,
            );
          },
        );
      }
    };
    buttonTwoFunc = () => Navigator.of(context).pop();

    return [buttonOneFunc, buttonTwoFunc];
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaQuery = MediaQuery.of(context).size;

    Widget buildButton(
        {required Color color,
        required Color textColor,
        required String buttonName,
        required VoidCallback callBack}) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: callBack,
        child: Container(
          alignment: Alignment.center,
          width: mediaQuery.width * 0.34,
          child: Text(
            buttonName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return Dialog(
      insetAnimationCurve: Curves.easeIn,
      insetAnimationDuration: const Duration(milliseconds: 250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: mediaQuery.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                height: mediaQuery.height * 0.1,
                width: mediaQuery.height * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(200, 200, 255, 1),
                ),
                child: SvgPicture.asset(
                  'assets/images/email.svg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                child: Column(
                  children: const [
                    Text(
                      'Cek email kamu',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Kami sudah mengirimkan alamat untuk melakukan reset password. Segera pulihkan akunmu.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    buildButton(
                        buttonName: 'Buka email',
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        callBack: getFunction(context).elementAt(0)),
                    buildButton(
                      buttonName: 'Saya coba nanti',
                      color: Colors.white,
                      textColor: Colors.grey,
                      callBack: getFunction(context).elementAt(1),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
