import 'package:flutter/material.dart';
import 'package:socialmedia/networkimage.dart';
import 'package:socialmedia/posts.dart';
import 'package:socialmedia/postscreen.dart';

class PostTile extends StatelessWidget {
  PostTile({this.post});
  final Posts post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostScreen(
                      postId: post.postId,
                      userId: post.ownerId,
                      username: post.userName,
                    )));
      },
      child: cashedNetworkImage(post.mediaUrl),
    );
  }
}
