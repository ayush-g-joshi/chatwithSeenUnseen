import 'package:chatbox/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Widgets/exitpopup.dart';
import 'auth/loginpage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool showLoader = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore
        .collection('users')
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        // isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(onPressed: () {
      //       Navigator.push(context, MaterialPageRoute(
      //         builder: (context) {
      //           return ViewProfile();
      //         },
      //       ));
      //     }, icon:const Icon(Icons.more_vert),),
      //     WillPopScope(
      //       onWillPop: () => showAlertDialog(context),
      //       child: IconButton(onPressed: () {
      //         showAlertDialog(context);
      //
      //       }, icon:const Icon(Icons.logout),),
      //     )
      //   ],
      //   systemOverlayStyle: SystemUiOverlayStyle(
      //     statusBarColor:Color(0xff113162),),
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   elevation: 0,
      //   backgroundColor:Color(0xff113162) ,
      //   title: Text("CHATTER",style: TextStyle(fontSize: 20)),centerTitle: true,),
      body:
          // isLoading
          //     ? WillPopScope(
          //   onWillPop: () => showExitPopup(context),
          //       child: Center(
          //   child: Container(
          //       height: size.height / 20,
          //       width: size.height / 20,
          //       child: CircularProgressIndicator(),
          //   ),
          // ),
          //     )
          //     :
          ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        progressIndicator: const CircularProgressIndicator(),
        child: WillPopScope(
          onWillPop: () => showExitPopup(context),
          child: Form(
            child: Builder(builder: (context) {
              return Column(
                children: [
                  SizedBox(
                    height: size.height / 10,
                  ),
                  Container(
                    height: size.height / 14,
                    width: size.width,
                    alignment: Alignment.center,
                    child: Container(
                      height: size.height / 14,
                      width: size.width / 1.15,
                      child: TextFormField(
                        controller: _search,
                        validator: (CurrentValue) {
                          var nonNullValue = CurrentValue ?? '';
                          if (nonNullValue.isEmpty) {
                            return ("Search Is Empty");
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xff113162),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (Form.of(context)?.validate() ?? false) {
                        onSearch();
                      }
                    },
                    child: Text("Search"),
                  ),
                  SizedBox(
                    height: size.height / 20,
                  ),
                  userMap != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.white,
                            child: ListTile(
                              onTap: () {
                                String roomId = chatRoomId(
                                    _auth.currentUser!.displayName!,
                                    userMap!['name']);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoom(
                                      chatRoomId: roomId,
                                      userMap: userMap!,
                                    ),
                                  ),
                                );
                              },
                              leading: ClipOval(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: FittedBox(
                                    child:
                                        Image.network('${userMap!['image']}'),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              title: Text(
                                userMap!['name'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                userMap!['email'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              );
            }),
          ),
        ),
      ),
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
}
