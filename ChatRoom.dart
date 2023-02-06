import 'dart:io';

import 'package:chatbox/helper/my_date_util.dart';
import 'package:chatbox/profiles/userprofileinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
    FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    DateTime date = DateTime.now();
    String time = "${date.hour}:${date.minute}";
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "date": DateTime.now().millisecondsSinceEpoch,
        "read": false,

      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }
  Future<void> updateRead() async{
    final query = await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .where('sendby', isEqualTo:userMap['name'])
        .where('read', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      doc.reference.update({'read': true});
    }

  }
  var count;
  Future<void> CountUnReadMessage() async{
    QuerySnapshot productCollection = await
    FirebaseFirestore.instance.collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .where('read', isEqualTo: false).get();
    int productCount = productCollection.size;
    print("COUNT OF UNSEEN MESSAGE IS-----------------$productCount");

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xff113162),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Color(0xff113162),
        title: StreamBuilder<DocumentSnapshot>(
          stream:
          _firestore.collection("users").doc(userMap['uid']).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => UserProfileInfo(
                            email: userMap['email'],
                            image: userMap['image'],
                            name: userMap['name'])));
                  },
                  child: Row(
                    children: [
                      Center(
                        child: ClipOval(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: FittedBox(
                              child: Image.network('${userMap['image']}'),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userMap['name']),
                          Text(
                            snapshot.data!['status'],
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(

                stream: _firestore
                    .collection('chatroom')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy("date", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {

                    updateRead();
                    CountUnReadMessage();


                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        return messages(size, map, context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      // height: size.height / 12,
                      width: size.width / 1.3,
                      child: TextField(

                        controller: _message,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8),
                          // suffixIcon: IconButton(
                          //   onPressed: () => getImage(),
                          //   icon: const Icon(Icons.photo, color: Color(0xff113162)),
                          // ),
                          hintText: "Send Message",
                          border: const OutlineInputBorder(),),

                        maxLines: 6,
                        minLines: 1,

                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send),
                        onPressed: onSendMessage,
                        color: Color(0xff113162)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    // UpdateIsseen(map);


    return map['type'] == "text" &&  map['sendby'] == _auth.currentUser!.displayName
        ? Container(
      width: size.width,
      alignment:  Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xff113162)),
        child: Column(
          children: [
            Text(
              map['message'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              MyDateUtil.getFormattedTime(context: context, time: map["date"].toString()),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            map["read"]==false?Icon( Icons.check_circle_sharp,
              size: 20,color: Colors.white,):Icon( Icons.check_circle_sharp,
              size: 20,color: Colors.blue,)
          ],
        ),
      ),
    )
        : Container(
      width: size.width,
      alignment:  Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xff113162)),
        child: Column(
          children: [
            Text(
              map['message'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              MyDateUtil.getFormattedTime(context: context, time: map["date"].toString()),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

          ],
        ),
      ),
    );
  }

}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}

// void UpdateIsseen(Map<String, dynamic> map) async {
//   if(map['sendby'] == _auth.currentUser!.displayName){
//     print("statusof iseen-true");
//     await _firestore.collection('chatroom').doc(chatRoomId).collection('chats').doc("isSeen").set({
//       "status": false,
//     });
//   }else{
//     print("statusof iseen-false");
//     await _firestore.collection('chatroom').doc(chatRoomId).collection('chats').doc("isSeen").set({
//       "status": true,
//     });
//   }}