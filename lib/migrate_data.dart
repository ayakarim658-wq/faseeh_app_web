import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await migrateData();
  print("✅ تم نقل البيانات بنجاح");

  // بعد ما يخلص، نقدر نقفل التطبيق
}

Future<void> migrateData() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('words');

  // جلب كل المستندات
  final snapshot = await collection.get();

  for (var doc in snapshot.docs) {
    final data = doc.data();

    // لو فيه حقل text ومفيش word
    if (data.containsKey('text') && !data.containsKey('word')) {
      final oldText = data['text'];

      // تحديث المستند بالحقول الجديدة
      await doc.reference.update({
        'word': oldText, // نقل الكلمة
        'meaning': '—',  // نضيف معنى افتراضي مؤقت
      });

      // حذف الحقل القديم
      await doc.reference.update({
        'text': FieldValue.delete(),
      });

      print("✔️ تم تحديث المستند: ${doc.id}");
    }
  }
}
