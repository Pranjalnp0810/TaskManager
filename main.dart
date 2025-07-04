import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_manager/signin.dart';
import 'package:task_manager/taskmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ghpdmasbwqmtxyrrvhij.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdocGRtYXNid3FtdHh5cnJ2aGlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkxMDk0MTIsImV4cCI6MjA2NDY4NTQxMn0.34Q5MVSiGOVSnv-YPtDGlSbu3AIXn-ky_dKNKXUHNFk',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: session != null ? MyTaskManager() : MySignIn(),
    );
  }
}
