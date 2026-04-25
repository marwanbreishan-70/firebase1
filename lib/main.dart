import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exsail5/craetefile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExcelReaderScreen(),
    );
  }
}

class ExcelReaderScreen extends StatefulWidget {
  const ExcelReaderScreen({super.key});

  @override
  State<ExcelReaderScreen> createState() => _ExcelReaderScreenState();
}
class _ExcelReaderScreenState extends State<ExcelReaderScreen> {
  List<Map<String, dynamic>> _products = [];

  // 📌 قراءة Excel ورفع البيانات إلى Firebase
  Future<void> _pickAndUploadExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.single.path == null) return;

      final path = result.files.single.path!;
      final bytes = File(path).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        for (int i = 1; i < sheet.rows.length; i++) {
          var row = sheet.rows[i];

          if (row.length < 2) continue;

          String name = row[0]?.value?.toString() ?? 'بدون اسم';
          double price =
              double.tryParse(row[1]?.value?.toString() ?? '0') ?? 0;

          // 📤 رفع إلى Firebase
          await FirebaseFirestore.instance.collection('products').add({
            'name': name,
            'price': price,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم رفع البيانات إلى Firebase")),
      );
    } catch (e) {
      debugPrint("Error reading Excel: $e");
    }
  }

  // 📌 جلب البيانات من Firebase مع شرط السعر
  Future<void> _loadProductsFromFirebase() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('price', isGreaterThanOrEqualTo: 500) // 🔥 الشرط المطلوب
          .get();

      List<Map<String, dynamic>> loaded = [];

      for (var doc in snapshot.docs) {
        loaded.add({
          'name': doc['name'],
          'price': doc['price'],
        });
      }

      setState(() {
        _products = loaded;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(' Excel + Firebase')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => createExcelFile(context),
            child: const Text("إنشاء ملف Excel"),
          ),

          /// 📥 زر رفع Excel
          ElevatedButton.icon(
            onPressed: _pickAndUploadExcel,
            icon: const Icon(Icons.upload_file),
            label: const Text('رفع ملف Excel إلى Firebase'),
          ),

          const SizedBox(height: 10),

          /// ☁️ زر جلب البيانات
          ElevatedButton.icon(
            onPressed: _loadProductsFromFirebase,
            icon: const Icon(Icons.download),
            label: const Text('تحميل من Firebase'),
          ),

          const SizedBox(height: 20),
          const Divider(),

          /// 📋 عرض البيانات
          Expanded(
            child: _products.isEmpty
                ? const Center(child: Text('لا توجد بيانات'))
                : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(_products[index]['name']),
                  subtitle: Text(
                    'السعر: ${_products[index]['price']}',
                  ),
                  trailing: const Icon(Icons.shopping_bag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}