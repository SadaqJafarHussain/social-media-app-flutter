import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/home.dart';
import 'package:socialmedia/posts.dart';
import 'package:socialmedia/progressIndecators.dart';

class PostScreen extends StatefulWidget {
  PostScreen({this.postId, this.userId, this.username});
  final String userId;
  final String postId;
  final String username;

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Posts post;
  getAllPosts() async {
    QuerySnapshot snapshot =
        await postsRef.doc(widget.userId).collection('userPosts').get();

    snapshot.docs.forEach((doc) {
      if (doc['postId'] == widget.postId) {
        setState(() {
          post = Posts.fromDocument(doc);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '${widget.username}\'s post',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          children: [
            Container(
              child: post == null ? circularProgress() : post,
            ),
          ],
        ),
      ),
    );
  }
}
