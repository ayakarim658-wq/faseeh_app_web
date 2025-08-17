import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'add_word_page.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فصيح الصغير',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const WordsPage(),
    );
  }
}

class WordsPage extends StatefulWidget {
  const WordsPage({super.key});

  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  int? selectedGrade;
  int? selectedUnit;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("معجم فصيح الصغير"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWordPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // فلترة وبحث
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<int>(
                  hint: const Text("اختر الصف"),
                  value: selectedGrade,
                  items: List.generate(6, (index) => index + 1)
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text("صف $g"),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedGrade = val;
                    });
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  hint: const Text("اختر الوحدة"),
                  value: selectedUnit,
                  items: List.generate(10, (index) => index + 1)
                      .map((u) => DropdownMenuItem(
                            value: u,
                            child: Text("وحدة $u"),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedUnit = val;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "ابحث عن الكلمة أو المعنى",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchText = val.trim();
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('words').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final allDocs = snapshot.data!.docs;
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final word = data['word'] ?? '';
                  final meaning = data['meaning'] ?? '';
                  final grade = data['grade'] ?? 0;
                  final unit = data['unit'] ?? 0;

                  bool matchesGrade = selectedGrade == null || grade == selectedGrade;
                  bool matchesUnit = selectedUnit == null || unit == selectedUnit;
                  bool matchesSearch = searchText.isEmpty ||
                      word.contains(searchText) ||
                      meaning.contains(searchText);

                  return matchesGrade && matchesUnit && matchesSearch;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("لا توجد كلمات"));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final word = data['word'] ?? '';
                    final meaning = data['meaning'] ?? '';
                    final type = data['type'] ?? '';
                    final grade = data['grade'] ?? '';
                    final unit = data['unit'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      color: Colors.blue[50],
                      child: ListTile(
                        title: Text(word, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("المعنى: $meaning\nالنوع: $type\nصف: $grade وحدة: $unit"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
