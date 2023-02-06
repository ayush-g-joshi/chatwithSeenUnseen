// import 'dart:async';
// import 'package:chatbox/homepage.dart';
// import 'package:chatbox/loginpage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//
//   void initState() {
//     splashScreen();
//     super.initState();
//   }
//
//   splashScreen() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var status = prefs.getBool('isLoggedIn') ?? false;
//     print(status);
//
//     Timer(Duration(seconds: 3),
//             () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                 status == true ? HomeScreen() : LoginPage(),
//               ),
//             ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
//     return MaterialApp(
//       child: Scaffold(
//         backgroundColor: Color(0xff113162),
//         body: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "CHATTER",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   "Be Connected With Your World !",
//                   style: TextStyle(color: Colors.white, fontSize: 20),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 5,
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:chatbox/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
