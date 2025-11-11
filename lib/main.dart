import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:attendance_app/ui/absent/absent_screen.dart';
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/ui/attendance/attendance_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // Add your own Firebase project configuration from google-services.json
        apiKey: 'AIzaSyAlBQoNsjV5tZ48mxA3yNiw3zQVH2ym4YI', // api_key
        appId:
            '1:592629517735:android:d8b74979d29534d58cfa82', // mobilesdk_app_id
        messagingSenderId: '592629517735', // project_number
        projectId: 'attendance-app-a050a', // project_id
      ),
    );
    // Firebase connection success
    print("Firebase Terhubung ke:");
    print("API Key: ${Firebase.app().options.apiKey}");
    print("Project ID: ${Firebase.app().options.projectId}");
  } catch (e) {
    // Firebase connection failed
    print("Firebase gagal terhubung: $e");
  }
  // runApp(const HomeScreen());
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
