import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:timeago/timeago.dart' as timego;
import 'home.dart';

class StoryResult extends StatefulWidget {
  final String mediaUrl;
  final String username;
  final Timestamp timeStamp;
  final String userPhoto;
  final String postId;
  StoryResult({
    this.postId,
    this.userPhoto,
    this.mediaUrl,
    this.timeStamp,
    this.username,
  });

  @override
  _StoryResultState createState() => _StoryResultState();
}

class _StoryResultState extends State<StoryResult> {
  bool isItYou;

  @override
  void initState() {
    super.initState();
    isItYou = widget.username == currentUser.userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: widget.mediaUrl == null
            ? circularProgress()
            : Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.mediaUrl),
                        fit: BoxFit.contain)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                CachedNetworkImageProvider(widget.userPhoto),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.username,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  timego
                                      .format(widget.timeStamp.toDate())
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              size: 30,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    isItYou
                        ? Center(
                            child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: () => deleteStory(context),
                          ))
                        : Text(''),
                  ],
                ),
              ),
      ),
    );
  }

  deleteStory(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          elevation: 10,
          title: Text(
            'Are you sure ? ',
            style: TextStyle(color: Colors.blueGrey, fontSize: 30),
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
          children: [
            SimpleDialogOption(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                      onPressed: () => deletStoryFromFirestore(),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.orange,
                        ),
                      )),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('No',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.orange,
                          ))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  deletStoryFromFirestore() async {
    QuerySnapshot snapshot = await timelineStoryRef
        .doc(currentUser.id)
        .collection('timeLinePosts')
        .where('postId', isEqualTo: widget.postId)
        .get();
    snapshot.docs.first.reference.delete();
    Navigator.pop(context);
  }
}
