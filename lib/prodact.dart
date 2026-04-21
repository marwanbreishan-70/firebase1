import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  // Controllers للمدخلات
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // قائمة لحفظ البيانات
  List<Map<String, String>> products = [];

  // إضافة منتج
  void addProduct() {

    String name = nameController.text.trim();
    String price = priceController.text.trim();

    if (name.isEmpty || price.isEmpty) return;

    setState(() {
      products.add({
        "name": name,
        "price": price,
      });
    });

    nameController.clear();
    priceController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products Manager"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // إدخال اسم المنتج
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // إدخال السعر
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // زر الإضافة
            ElevatedButton(
              onPressed: addProduct,
              child: const Text("Add Product"),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            // عرض البيانات
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: Text(products[index]["name"]!),
                      subtitle: Text("Price: ${products[index]["price"]}"),
                    ),
                  );

                },
              ),
            )

          ],
        ),
      ),
    );
  }
}
