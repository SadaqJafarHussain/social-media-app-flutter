import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/postscreen.dart';
import 'package:socialmedia/profile.dart';
import 'package:timeago/timeago.dart' as timego;

Widget mediaPreview;
String activityFeedType;

class NotifyModel extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String userId;
  final String photoUrl;
  final String mediaUrl;
  final String postId;
  final Timestamp timestamp;

  NotifyModel({
    this.username,
    this.type,
    this.commentData,
    this.userId,
    this.photoUrl,
    this.mediaUrl,
    this.postId,
    this.timestamp,
  });

  static NotifyModel fromFirestore(DocumentSnapshot data) {
    return NotifyModel(
      type: data['type'],
      commentData: data['commentData'],
      username: data['username'],
      userId: data['userId'],
      photoUrl: data['photoUrl'],
      mediaUrl: data['mediaUrl'],
      postId: data['postId'],
      timestamp: data['timestamp'],
    );
  }

  configureMediaPreview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = FlatButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostScreen(
                        postId: postId,
                        userId: userId,
                        username: username,
                      )));
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (type == 'like') {
      activityFeedType = 'liked your post ';
    } else if (type == 'comment') {
      activityFeedType = 'commented : $commentData';
    } else if (type == 'follow') {
      activityFeedType = 'following you';
    } else {
      activityFeedType = 'error:';
    }
  }

  textTitle({String username, String line}) {
    return Row(
      children: [
        Text(
          username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          line,
          style: TextStyle(fontSize: 14, color: Colors.blueAccent),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(profileId: userId)));
          },
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(profileId: userId)));
          },
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' $activityFeedType',
                ),
              ],
            ),
          ),
        ),
        subtitle: Text(
          timego.format(timestamp.toDate()).toString(),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: GestureDetector(
          child: mediaPreview,
        ),
      ),
    );
  }
}
