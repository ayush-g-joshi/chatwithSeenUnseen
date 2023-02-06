import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({Key? key}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(

        // appBar: AppBar(
        //
        //     systemOverlayStyle: SystemUiOverlayStyle(
        //       statusBarColor:Color(0xff113162),),
        //     iconTheme: const IconThemeData(color: Colors.white),
        //     elevation: 0,
        //     backgroundColor:Color(0xff113162) ,
        //
        //     title: Text("View Profile"),centerTitle: true),
        body: Builder(builder: (context) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(
            height: 20,
          ),
          ClipOval(
            child: Image.network(
              "${auth.currentUser?.photoURL}",
              width: 200,
              height: 200,
              fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "${auth.currentUser?.displayName} ",
            style: TextStyle(
              color: Color(
                0xff113162,
              ),
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "${auth.currentUser?.email} ",
            style: TextStyle(
              color: Color(
                0xff113162,
              ),
              fontSize: 20,
            ),
          ),
        ]),
      );
    }));
  }
}
