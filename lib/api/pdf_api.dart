import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    const channel = MethodChannel('externalStorage');
    final path = await channel.invokeMethod('getExternalStorageDirectory');
    final bytes = await pdf.save();

    final storagePermission = Permission.storage;
    if (await storagePermission.status.isDenied) {
      await storagePermission.request();
    }
    debugPrint(
        'status: ' + (await storagePermission.status.isGranted).toString());

    final dir = Directory('$path/Sippedes');

    try {
      if (!(await dir.exists())) {
        await dir.create();
      }
    } on FileSystemException catch (e) {
      debugPrint('error: ${e.osError}');
    }
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
