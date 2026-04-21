import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_exal/w.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExcelReaderScreen(),
    );
  }
}

class ExcelReaderScreen extends StatefulWidget {
  @override
  _ExcelReaderScreenState createState() => _ExcelReaderScreenState();
}

class _ExcelReaderScreenState extends State<ExcelReaderScreen> {
  List<Map<String, dynamic>> _products = [];

  // دالة اختيار وقراءة الملف
  Future<void> _pickAndReadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        for (int i = 1; i < sheet.maxRows; i++) {
          var row = sheet.rows[i];

          String name = row[0]?.value?.toString() ?? 'بدون اسم';
          double price = double.tryParse(row[1]?.value.toString() ?? '0') ?? 0;

          // 🚀 رفع إلى Firebase
          await FirebaseFirestore.instance.collection('products').add({
            'name': name,
            'price': price,
          });
        }
      }

      // بعد الرفع → نجيب البيانات
      _loadProductsFromFirebase();
    }
  }
  Future<void> _loadProductsFromFirebase() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('price', isGreaterThanOrEqualTo: 1000) // ✅ فلترة
        .get();

    List<Map<String, dynamic>> loadedProducts = [];

    for (var doc in snapshot.docs) {
      loadedProducts.add({
        'name': doc['name'],
        'price': doc['price'].toString(),
      });
    }

    setState(() {
      _products = loadedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قارئ ملفات المتجر')),
      body: Column(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => createExcelFile(context),
                    icon: const Icon(Icons.create_new_folder),
                    label: const Text('1. إنشاء ملف Excel'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _pickAndReadExcel, // الدالة من الكود السابق
                    icon: const Icon(Icons.upload_file),
                    label: const Text('2. قراءة الملف'),
                  ),
                ],
              ),
              // ... باقي الكود لعرض القائمة
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 40),
          Expanded(
            child: _products.isEmpty
                ? const Center(child: Text('لا توجد بيانات حالياً'))
                : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(_products[index]['name']),
                  subtitle: Text('السعر: ${_products[index]['price']}'),
                  trailing: const Icon(Icons.shopping_bag_outlined),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}