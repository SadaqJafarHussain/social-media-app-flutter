import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/home.dart';
import 'package:timeago/timeago.dart' as timego;

class Comments extends StatefulWidget {
  final postId;
  final postOwnerId;
  final mediaUrl;
  final description;
  Comments({this.description, this.mediaUrl, this.postId, this.postOwnerId});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blueAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 10.0,
        title: Text(
          'Comments',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'type a comment..',
                labelStyle: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
            ),
            trailing: OutlineButton(
              onPressed: pushComment,
              borderSide: BorderSide.none,
              child: Text(
                'post',
                style: TextStyle(fontSize: 18, color: Colors.deepOrange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pushComment() {
    commentsRef.doc(widget.postId).collection('comments').add({
      'username': currentUser.userName,
      'avatarUrl': currentUser.photoUrl,
      'comment': commentController.text,
      'timeStamp': DateTime.now(),
      'userId': currentUser.id,
    });
    bool isNotPostOwner = widget.postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      feedRef.doc(widget.postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentController.text,
        'username': currentUser.userName,
        'userId': widget.postOwnerId,
        'photoUrl': currentUser.photoUrl,
        'mediaUrl': widget.mediaUrl,
        'postId': widget.postId,
        'timestamp': DateTime.now(),
        'description': widget.description,
      });
      commentController.clear();
    }
  }

  buildComments() {
    return StreamBuilder(
        stream: commentsRef
            .doc(widget.postId)
            .collection('comments')
            .orderBy('timeStamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<Comment> comments = [];
          snapshot.data.docs.forEach((doc) {
            comments.add(Comment.fromFirestore(doc));
          });

          return ListView(
            children: comments,
          );
        });
  }
}

class Comment extends StatelessWidget {
  const Comment({
    this.avatarUrl,
    this.comment,
    this.timestamp,
    this.userId,
    this.username,
  });
  final String username;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final String userId;

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    return Comment(
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timeStamp'],
      username: doc['username'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(avatarUrl),
            ),
            title: Text(username),
            trailing: Text(timego.format(timestamp.toDate())),
            subtitle: Text(comment),
          ),
          Divider(),
        ],
      ),
    );
  }
}
