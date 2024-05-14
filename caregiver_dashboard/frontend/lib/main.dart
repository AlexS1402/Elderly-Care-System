import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'patient_list_screen.dart';
import 'patient_detail_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elderly Care System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CheckAuth(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/patient-list': (context) => PatientListScreen(),
        '/patient-detail': (context) => PatientDetailScreen(),
      },
    );
  }
}

class CheckAuth extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    String? jwt = await storage.read(key: 'jwt');
    return jwt != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.data == true) {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
          } else {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
          }
          return Container();
        }
      },
    );
  }
}
