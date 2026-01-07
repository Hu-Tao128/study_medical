import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/auth/data/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // This will fail if firebase_options.dart is missing, which is expected until user runs config
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Fallback for development if file missing, or let it crash to prompt user
    print("Firebase init failed (expected if not configured): $e");
    // We might want to await Firebase.initializeApp() without options if we rely on auto-config?
    // But usually options are needed.
    // For now, let's assume user will run the command. We can comment out the options if needed.
    // However, to compile, we need the import to exist or be handled.
    // If firebase_options.dart doesn't exist yet, this file will fail analysis. This is a Catch-22.
    // I will write the code assuming it exists, but user needs to generate it.
  }

  runApp(
    ChangeNotifierProvider(create: (_) => AuthService(), child: const MyApp()),
  );
}
