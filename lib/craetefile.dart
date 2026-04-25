import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
Future<void> createExcelFile(BuildContext context) async {
  try {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // 📌 العناوين
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue('اسم المنتج');

    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = TextCellValue('السعر');

    // 📌 البيانات
    List<List<String>> data = [
      ['آيفون 15 برو', '4500'],
      ['سماعات سوني', '1200'],
      ['ماك بوك إير', '5200'],
      ['ساعة أبل', '3100'],
      ['لوحة مفاتيح', '450'],
      ['شاشة سامسونج', '1800'],
    ];

    for (int i = 0; i < data.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(data[i][0]);

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(data[i][1]);
    }

    // 📌 حفظ الملف داخل التطبيق (Android)
    final directory = await getExternalStorageDirectory();
    final downloadsPath = directory!.path.replaceAll(
      'Android/data/com.marwan.exsail5/files',
      'Download',
    );

    final filePath = "$downloadsPath/store_data.xlsx";
    final file = File(filePath);

    await file.writeAsBytes(excel.encode()!);

    // 📢 رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إنشاء الملف في:\n$filePath')),
    );

    print("تم حفظ الملف في: $filePath");
  } catch (e) {
    print("خطأ أثناء إنشاء الملف: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ: $e')),
    );
  }
}