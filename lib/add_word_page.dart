import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController wordController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  int? grade;
  int? unit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة كلمة جديدة")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: wordController,
                decoration: const InputDecoration(labelText: "الكلمة"),
                validator: (val) => val == null || val.isEmpty ? "ادخل الكلمة" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: meaningController,
                decoration: const InputDecoration(labelText: "المعنى"),
                validator: (val) => val == null || val.isEmpty ? "ادخل المعنى" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "النوع"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "الصف"),
                value: grade,
                items: List.generate(6, (index) => index + 1)
                    .map((g) => DropdownMenuItem(value: g, child: Text("صف $g")))
                    .toList(),
                onChanged: (val) => setState(() => grade = val),
                validator: (val) => val == null ? "اختر الصف" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "الوحدة"),
                value: unit,
                items: List.generate(10, (index) => index + 1)
                    .map((u) => DropdownMenuItem(value: u, child: Text("وحدة $u")))
                    .toList(),
                onChanged: (val) => setState(() => unit = val),
                validator: (val) => val == null ? "اختر الوحدة" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance.collection('words').add({
                      'word': wordController.text,
                      'meaning': meaningController.text,
                      'type': typeController.text,
                      'grade': grade,
                      'unit': unit,
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("إضافة الكلمة"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
