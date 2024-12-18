import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:servicefield/utils/firestore_service.dart';
import 'components/service_request_provider.dart'; // Import your provider
import 'pages/AuthPage.dart'; // Import your AuthPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Sync from local database to Firestore
  await FirestoreService().syncLocalToFirestore();

  // Sync from Firestore to local database
  await FirestoreService().syncFirestoreToLocal();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ServiceRequestProvider(), // Initialize provider
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Service Management',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Start with SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}

// SplashScreen widget
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set a timer to navigate to AuthPage after 3 seconds
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFffffff), // Background color of the splash screen
      body: Center(
        child: Image.asset('lib/assets/icon/two.png'), // Splash screen logo
      ),
    );
  }
}
