import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class ExcelProductManager extends StatefulWidget {
  const ExcelProductManager({super.key});

  @override
  State<ExcelProductManager> createState() => _ExcelProductManagerState();
}

class _ExcelProductManagerState extends State<ExcelProductManager> {

  File? selectedFile;
  Excel? excel;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // اختيار ملف Excel
  Future<void> pickExcelFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {

      selectedFile = File(result.files.single.path!);

      var bytes = selectedFile!.readAsBytesSync();
      excel = Excel.decodeBytes(bytes);

      print("Excel Loaded ✔");
    }
  }

  // إضافة منتج داخل Excel
  Future<void> addProductToExcel() async {

    if (selectedFile == null || excel == null) {
      print("Pick Excel file first");
      return;
    }

    String name = nameController.text.trim();
    String price = priceController.text.trim();

    if (name.isEmpty || price.isEmpty) return;

    // اختيار أول Sheet
    String sheetName = excel!.tables.keys.first;
    Sheet sheet = excel![sheetName];

    // إضافة صف جديد
    sheet.appendRow([name, price]);

    // حفظ الملف
    var fileBytes = excel!.save();

    if (fileBytes != null) {
      await selectedFile!.writeAsBytes(fileBytes, flush: true);
      print("Product Added ✔");

      // فتح الملف بعد التعديل
      await OpenFile.open(selectedFile!.path);
    }

    nameController.clear();
    priceController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Excel Product Manager"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            ElevatedButton(
              onPressed: pickExcelFile,
              child: const Text("Pick Excel File"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: addProductToExcel,
              child: const Text("Add Product To Excel"),
            ),

          ],
        ),
      ),
    );
  }
}
