import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/storyresult.dart';

class Story extends StatefulWidget {
  final String postId;
  final String userphoto;
  final String mediaPhoto;
  final String username;
  final Timestamp timestamp;
  Story(
      {this.postId,
      this.timestamp,
      this.mediaPhoto,
      this.username,
      this.userphoto});

  @override
  _StoryState createState() => _StoryState();
}
//this is just a mukup not a real story class its just design

class _StoryState extends State<Story> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StoryResult(
                              userPhoto: widget.userphoto,
                              username: widget.username,
                              mediaUrl: widget.mediaPhoto,
                              timeStamp: widget.timestamp,
                            )));
              },
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 40,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 36,
                  child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey,
                      backgroundImage: widget.userphoto == null
                          ? AssetImage('images/girl.jpeg')
                          : CachedNetworkImageProvider(widget.userphoto)),
                ),
              ),
            ),
            Text(
              widget.username,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ));
    ;
  }
}
