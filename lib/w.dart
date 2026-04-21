import 'dart:io';
import 'package:excel/excel.dart' show TextCellValue, Excel, CellIndex, Sheet;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ScaffoldMessenger, Text, SnackBar;
import 'package:path_provider/path_provider.dart'; // تأكد من استيرادها

Future<void> createExcelFile(BuildContext context) async {
  try {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // العناوين والبيانات
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('اسم المنتج');
    sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('السعر');

    List<List<String>> data = [
      ['آيفون 15 برو', '4500'],
      ['سماعات سوني', '1200'],
      ['ماك بوك إير', '5200'],
      ['ساعة أبل', '3100'],
      ['لوحة مفاتيح', '450'],
      ['شاشة سامسونج', '1800'],
      ['فأرة لوجيتك', '380'],
      ['كاميرا كانون', '8500'],
      ['حقيبة ظهر', '250'],
      ['شاحن لاسلكي', '150'],
    ];

    for (int i = 0; i < data.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue(data[i][0]);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = TextCellValue(data[i][1]);
    }

    // --- التعديل هنا ليعمل على المحاكي والماك معاً ---
    final directory = Directory('/Users/${Platform.environment['USER']}/Downloads');
    final String filePath = "${directory.path}/store_data.xlsx";
    final file = File(filePath);

    await file.writeAsBytes(excel.encode()!);

    print("تم حفظ الملف في: $filePath"); // سيظهر لك المسار في Console

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إنشاء الملف بنجاح في: Documents')),
    );
  } catch (e) {
    print("خطأ أثناء إنشاء الملف: $e");
  }
}