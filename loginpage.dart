import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/exitpopup.dart';
import '../menupage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
// creating firebase instance
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool showLoader = false;

  @override
  void initState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light,
    );
    return Scaffold(
      // appBar: AppBar(
      //
      //   systemOverlayStyle: SystemUiOverlayStyle(
      //     statusBarColor:Color(0xff113162),),
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   elevation: 0,
      //   backgroundColor:Color(0xff113162) ,
      //   title: Text("CHATTER"),centerTitle: true,),
      backgroundColor: Color(0xff113162),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: WillPopScope(
            onWillPop: () => showExitPopup(context),
            child: Builder(builder: (context) {
              return Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Container(
                            child: Image.asset(
                              'assets/images/google.png',
                            )),
                        onTap: () {
                          signup();
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Chatter",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 45,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Made by",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "InstaItTechnology",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              );
            }),
          ),
        ),
      ),
    );
  }

  // signup() async {
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //   final GoogleSignInAccount? googleSignInAccount =
  //   await googleSignIn.signIn();
  //
  //   if (googleSignInAccount != null) {
  //     // SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // var status = prefs?.setBool("isLoggedIn", true);
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //     await googleSignInAccount.authentication;
  //     print("Below Mention User Login-");
  //     print(googleSignIn.currentUser!.displayName);
  //     FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).set({
  //       "name": auth.currentUser!.displayName,
  //       "email": auth.currentUser!.email,
  //       "image":auth.currentUser!.photoURL,
  //       "status": "Unavalible",
  //       "uid": auth.currentUser!.uid,
  //     });
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => HomeScreen()));
  //     Fluttertoast.showToast(
  //       msg: "${auth.currentUser?.displayName} is successfully login", // message
  //       toastLength: Toast.LENGTH_SHORT, // length
  //       gravity: ToastGravity.CENTER, // location
  //       timeInSecForIosWeb: 1, // duration
  //     );
  //   }
  // }
  signup() async {
    debugPrint("SIGNUP FUNCTION IS CALLED--------------------");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs?.setBool("isLoggedIn", true);

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;
      print("USER INFORMATION IS AS FOLLOWS--------------------");

      if (user != null) {
        // print(result.user?.displayName);

        FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser!.uid)
            .set({
          "name": auth.currentUser!.displayName,
          "email": auth.currentUser!.email,
          "image": auth.currentUser!.photoURL,
          "status": "Unavalible",
          "uid": auth.currentUser!.uid,
        });

        print(
            " _auth.currentUser ============================$auth.currentUser");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MenuPage()));
        Fluttertoast.showToast(
          msg: "${auth.currentUser?.displayName} is successfully login",
          // message
          toastLength: Toast.LENGTH_SHORT,
          // length
          gravity: ToastGravity.CENTER,
          // location
          timeInSecForIosWeb: 1, // duration
        );
      } else if (user == null) {
        print(result.user?.displayName);

        Fluttertoast.showToast(
          msg: "Something Went Wrong!", // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.CENTER, // location
          timeInSecForIosWeb: 1, // duration
        );
      }
    }
  }
}
// signup() async {
//   setState(() {
//     showLoader = true;
//   });
//   debugPrint("SIGNUP FUNCTION IS CALLED--------------------");
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var status = prefs?.setBool("isLoggedIn", true);
//
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//   final GoogleSignInAccount? googleSignInAccount =
//   await googleSignIn.signIn();
//
//   if (googleSignInAccount != null) {
//     final GoogleSignInAuthentication googleSignInAuthentication =
//     await googleSignInAccount.authentication;
//     final AuthCredential authCredential = GoogleAuthProvider.credential(
//
//         idToken: googleSignInAuthentication.idToken,
//         accessToken: googleSignInAuthentication.accessToken);
//
//     // Getting users credential
//     UserCredential result = await auth.signInWithCredential(authCredential);
//     User? user = result.user;
//     print("USER INFORMATION IS AS FOLLOWS--------------------");
//
//     if (user!=null) {
//       print(result.user?.displayName);
//
//       FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).set({
//         "name": auth.currentUser!.displayName,
//         "email": auth.currentUser!.email,
//         "image":auth.currentUser!.photoURL,
//         "status": "Unavalible",
//         "uid": auth.currentUser!.uid,
//       });
//       setState(() {
//         showLoader = false;
//       });
//       print(" _auth.currentUser ============================$auth.currentUser");
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => HomeScreen()));
//       Fluttertoast.showToast(
//         msg: "${auth.currentUser?.displayName} is successfully login", // message
//         toastLength: Toast.LENGTH_SHORT, // length
//         gravity: ToastGravity.CENTER, // location
//         timeInSecForIosWeb: 1, // duration
//       );
//     }else  if (user==null) {
//       print(result.user?.displayName);
//
//       Fluttertoast.showToast(
//         msg: "Something Went Wrong!", // message
//         toastLength: Toast.LENGTH_SHORT, // length
//         gravity: ToastGravity.CENTER, // location
//         timeInSecForIosWeb: 1, // duration
//       );
//     }
//   }
// }