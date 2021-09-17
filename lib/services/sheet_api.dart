import 'package:flutter/cupertino.dart';
import 'package:gsheets/gsheets.dart';

import '../key/secret_key.dart';

class SheetApi {
  static const _spreadSheetId = SecretKey.spreedSheetId;
  static const _credential = SecretKey.credential;
  static const _workSheetTitle = 'dummy_data_penduduk';

  static final _gSheet = GSheets(_credential);
  static Worksheet? _response;

  static Future<Worksheet?> _getWorkSheet(Spreadsheet spreadSheet,
      {required String sheetTitle}) async {
    try {
      return await spreadSheet.addWorksheet(sheetTitle);
    } catch (e) {
      return spreadSheet.worksheetByTitle(sheetTitle);
    }
  }

  static Future init() async {
    final spreadSheet = await _gSheet.spreadsheet(_spreadSheetId);
    _response = await _getWorkSheet(spreadSheet, sheetTitle: _workSheetTitle);
  }

  static Future<bool> updateData(
      {required String rowKey,
      required String columnKey,
      required String newValue}) async {
    bool status = false;
    try {
      if (_response == null) {
        status = false;
      }
      status = await _response!.values.insertValueByKeys(
        newValue,
        columnKey: columnKey,
        rowKey: rowKey,
      );
    } catch (e) {
      debugPrint('Error when updating gsheets data: ' + e.toString());
    }
    return status;
  }
}
