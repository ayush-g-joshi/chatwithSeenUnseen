import 'package:chatbox/profiles/userprofileinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'message.dart';

class chatpage extends StatefulWidget {
  var name;
  var senderemail;
  var image;
  var receiveremail;
  chatpage({Key? key,this.name,this.senderemail,this.image,this.receiveremail});
  @override
  _chatpageState createState() => _chatpageState();
}

class _chatpageState extends State<chatpage> {

  _chatpageState();

  final fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController message = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xff113162),),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          backgroundColor: Color(0xff113162),
          title: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      UserProfileInfo(email: widget.senderemail,
                        image: widget.image,
                        name: widget.name,)));
            },
            child: Row(
              children: [
                Center(
                  child: ClipOval(
                    child: Container(
                      height: 50,
                      width: 50,
                      child: FittedBox(
                        child:
                        Image.network('${widget.image}'),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Text("${widget.name}"),
              ],
            ),
          ),
          centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.79,
              child: messages(
                receiveremail: widget.receiveremail,
                senderemail: widget.senderemail,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: message,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xff113162),
                      hintText: 'message',
                      enabled: true,
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 8.0, top: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white),
                        borderRadius: new BorderRadius.circular(10),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white),
                        borderRadius: new BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {},
                    onSaved: (value) {
                      message.text = value!;
                    },
                  ),
                ),
                IconButton(
                  color: Color(0xff113162),
                  onPressed: () {
                    if (message.text.isNotEmpty) {
                      fs.collection('Messages').doc().set({
                        'message': message.text.trim(),
                        'time': DateTime.now(),
                        'senderemail': widget.senderemail,
                        'receiveremail': widget.receiveremail,
                      });

                      message.clear();
                    }
                  },
                  icon: Icon(Icons.send_sharp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}