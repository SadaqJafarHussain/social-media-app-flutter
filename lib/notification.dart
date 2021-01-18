import 'package:flutter/material.dart';
import 'package:socialmedia/home.dart';
import 'package:socialmedia/notificationmodel.dart';
import 'package:socialmedia/progressIndecators.dart';

class Notify extends StatefulWidget {
  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  List<NotifyModel> notificationsList = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Notifications',
            style: TextStyle(
                color: Colors.black, fontFamily: 'Signatra', fontSize: 40),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            Divider(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 10,
              height: MediaQuery.of(context).size.height * 0.8,
              child: FutureBuilder(
                future:
                    feedRef.doc(currentUser.id).collection('feedItems').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress();
                  }
                  snapshot.data.docs.forEach((doc) {
                    notificationsList.add(NotifyModel.fromFirestore(doc));
                  });
                  return ListView(
                    children: notificationsList,
                  );
                },
              ),
            ),
          ],
        ));
  }
}
