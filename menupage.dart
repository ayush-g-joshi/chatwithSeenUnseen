import 'dart:io';

import 'package:chatbox/friendlist.dart';
import 'package:chatbox/profiles/viewprofile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/loginpage.dart';
import 'homepage.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _currentIndex = 0;
  var token;
  DateTime? currentBackPressTime;

  Future<bool> onWillPopS(BuildContext context) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "Press Again To Exit", // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.CENTER, // location
          timeInSecForIosWeb: 1 // duration
          );
      return Future.value(false);
    }
    return exit(0);
  }

  @override
  void initState() {
    FirebaseMessaging.instance.getToken().then((value) {
      token = value;
      print("fcm token===>$token");
    });
    setState(() {
      checkInternetConnection();
    });
  }

  checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      Fluttertoast.showToast(
          msg: "You are connected to a mobile network.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      Fluttertoast.showToast(
          msg: "You are connected to a wifi network.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
          msg: "You Are Not Connected To Internet!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return WillPopScope(
      onWillPop: () => onWillPopS(context),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                // Tab(icon: Icon(Icons.search)),
                Tab(icon: Icon(Icons.list_rounded)),
                Tab(icon: Icon(Icons.more_vert)),
              ],
            ),
            actions: [
              // IconButton(onPressed: () {
              //   Navigator.push(context, MaterialPageRoute(
              //     builder: (context) {
              //       return ViewProfile();
              //     },
              //   ));
              // }, icon:const Icon(Icons.more_vert),),
              WillPopScope(
                onWillPop: () => showAlertDialog(context),
                child: IconButton(
                  onPressed: () {
                    showAlertDialog(context);
                  },
                  icon: const Icon(Icons.logout),
                ),
              )
            ],
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Color(0xff113162),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            backgroundColor: Color(0xff113162),
            title: Text("CHATTER", style: TextStyle(fontSize: 20)),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: const TabBarView(
            children: [
              // HomeScreen(),
              FriendList(),
              ViewProfile(),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      content: Container(
        height: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Do you want to logout?"),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      signOut();
                      print('yes selected');
                    },
                    child: Text("Yes"),
                    style:
                        ElevatedButton.styleFrom(primary: Colors.red.shade800),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    print('no selected');
                    Navigator.of(context).pop();
                  },
                  child: Text("No", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                  ),
                ))
              ],
            )
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //signout function
  signOut() async {
    print("SIGNOUT FUNCTION IS CALLED-----------");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs?.setBool("isLoggedIn", false);

    print("Below Mention User Logout-");
    print(_auth.currentUser!.displayName);

    Fluttertoast.showToast(
      msg: "${_auth.currentUser?.displayName} is successfully logout",
      // message
      toastLength: Toast.LENGTH_SHORT,
      // length
      gravity: ToastGravity.CENTER,
      // location
      timeInSecForIosWeb: 1, // duration
    );

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
