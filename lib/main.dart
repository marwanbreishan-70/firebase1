import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'display.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class textfiledcoustm extends StatelessWidget {
  const textfiledcoustm({
    super.key,
    required this.lable,
    required this.textEditingController,
  });

  final String lable;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: lable,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
class home_pag1 extends StatefulWidget {
  const home_pag1({super.key});

  @override
  State<home_pag1> createState() => _home_pag1State();
}

class _home_pag1State extends State<home_pag1> {
  final TextEditingController name = TextEditingController();
  final TextEditingController seat_number = TextEditingController();
  final TextEditingController dip = TextEditingController();

  void saveStudent() async {
    try {
      await FirebaseFirestore.instance.collection("students").add({
        "name": name.text,
        "seat_number": seat_number.text,
        "department": dip.text,
        "createdAt": Timestamp.now(),
      });

      print("SUCCESS SAVED");
    } catch (e) {
      print("ERROR: $e");
    }
  }
  @override
  void dispose() {
    name.dispose();
    seat_number.dispose();
    dip.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("student info"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textfiledcoustm(
                  lable: "enter the name of student ",
                  textEditingController: name,),
                SizedBox(height: 10,),
                textfiledcoustm(lable: "enter seat of number" ,
                  textEditingController: seat_number,),
                SizedBox(height: 10,),
                textfiledcoustm(lable: "enter the department" ,
                  textEditingController: dip,),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: saveStudent, child: Text("حفظ معلومات الطالب ")),
                    ElevatedButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentsPage()),
                      );
                    }, child: Text("عرض معلومات جميع الطلاب "))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home_pag1(),
    );
  }
}