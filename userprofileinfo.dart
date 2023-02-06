import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProfileInfo extends StatefulWidget {
  var name;
  var image;
  var email;

  UserProfileInfo({Key? key, this.name, this.image, this.email})
      : super(key: key);

  @override
  State<UserProfileInfo> createState() => _UserProfileInfoState();
}

class _UserProfileInfoState extends State<UserProfileInfo> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Color(0xff113162),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            backgroundColor: Color(0xff113162),
            title: Text("View Profile"),
            centerTitle: true),
        body: Builder(builder: (context) {
          return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                height: 20,
              ),
              ClipOval(
                child: Image.network(
                  "${widget.image}",
                  width: 200,
                  height: 200,
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "${widget.name} ",
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
                "${widget.email} ",
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
