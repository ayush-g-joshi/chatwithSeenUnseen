import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatRoom.dart';

class FriendList extends StatefulWidget {
  const FriendList({Key? key}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList>with WidgetsBindingObserver  {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  var currentuser;
  var count;
  @override
  void initState() {
     currentuser=_auth.currentUser?.displayName;
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
//Function to get uncount message
//   Future<void> CountUnReadMessage(String chatRoomId) async{
//     QuerySnapshot productCollection = await
//     FirebaseFirestore.instance.collection('chatroom')
//         .doc(chatRoomId)
//         .collection('chats')
//         .where('read', isEqualTo: false).get();
//     int productCount = productCollection.size;
//     print("COUNT OF List OF------- UNSEEN MESSAGE of users IS-----------------$productCount");
//     count=productCount;
//   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
          "email",
          isNotEqualTo: _auth.currentUser?.email,
        )
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              String listofroomId = chatRoomId(
                  currentuser.toString(),document['name']);

              // CountUnReadMessage(listofroomId);
              // print("${currentuser.toString()}-${document['name']}");
              return Container(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Row(
                          children: [
                            const SizedBox(
                              width: 15,
                              height: 20,
                            ),
                            document['image'] == null ||
                                document['image'].isEmpty
                                ? Center(
                              child: ClipOval(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: const FittedBox(
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            )
                                : Center(
                              child: ClipOval(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: FittedBox(
                                    child: Image.network(
                                        '${document['image']}'),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                    child: Text(document['name'].toString())),
                              ],
                            )
                          ],
                        ),
                        onTap: () {
                          userMap = {
                            "image": document["image"],
                            "uid": document["uid"],
                            "name": document["name"],
                            "email": document["email"],
                            "status": document["status"],
                          };

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
                        trailing:count!=0 && count!=null?Badge(
                         badgeStyle: BadgeStyle(badgeColor: Colors.green),
                          child: Icon(Icons.message, size: 40, color: Color(0xff113162),), //icon style
                          badgeContent: Center(  //aligh badge content to center
                            child:Text(count.toString(), style: TextStyle(
                                color: Colors.white,  fontSize: 15,
                            )
                            ),
                          ),
                        ): Icon(Icons.message, size: 40, color: Color(0xff113162),),
                      ),
                    ),
                    Divider(
                      color: Colors.black38,
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}