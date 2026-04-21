import 'dart:io';
import 'package:flutter_excel/excel.dart';
import 'package:open_file/open_file.dart';

class Excelfiles {

  Excel excel = Excel.createExcel();

  // إنشاء ملف Excel
  Future<void> createexcelfile() async {

    Sheet sheetObject = excel['فاتورة 01'];

    // Header
    sheetObject.appendRow(["Product", "Price"]);

    await saveExcel();
  }

  // حفظ + فتح الملف
  Future<void> saveExcel() async {
    try {

      String path;

      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        final home = Platform.environment['HOME'];
        path = "$home/Downloads/billNo03.xlsx";
      }else if (Platform.isAndroid) {
        path = "/storage/emulated/0/Download/billNo03.xlsx";
      } else {
        path = "billNo03.xlsx";
      }

      final file = File(path);

      var fileBytes = excel.save();

      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes, flush: true);

        print("Saved in $path");

        await OpenFile.open(path);
      }

    } catch (e) {
      print(e);
    }
  }

  // قراءة ملف Excel
  Excel readExcel(File file) {

    var bytes = file.readAsBytesSync();
    Excel excelFile = Excel.decodeBytes(bytes);

    for (var table in excelFile.tables.keys) {

      print("Sheet Name: $table");

      for (var row in excelFile.tables[table]!.rows) {
        print(row);
      }
    }

    return excelFile;
  }

  // إضافة منتج داخل ملف Excel مختار
  Future<void> addProductToExistingExcel({
    required File file,
    required String productName,
    required String price,
  }) async {

    var bytes = file.readAsBytesSync();
    Excel excelFile = Excel.decodeBytes(bytes);

    String sheetName = excelFile.tables.keys.first;
    Sheet sheet = excelFile[sheetName];

    sheet.appendRow([productName, price]);

    var fileBytes = excelFile.save();

    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes, flush: true);
      await OpenFile.open(file.path);
    }
  }
}
