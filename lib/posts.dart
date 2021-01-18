import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/comments.dart';
import 'package:socialmedia/home.dart';
import 'package:socialmedia/networkimage.dart';
import 'package:socialmedia/profile.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:socialmedia/user.dart';

class Posts extends StatefulWidget {
  final String ownerId;
  final String userName;
  final String location;
  final String mediaUrl;
  final String postId;
  final dynamic likes;
  final Timestamp timestamp;
  final String description;

  Posts({
    this.timestamp,
    this.description,
    this.likes,
    this.location,
    this.mediaUrl,
    this.ownerId,
    this.postId,
    this.userName,
  });
  factory Posts.fromDocument(DocumentSnapshot doc) {
    return Posts(
      description: doc.data()['description'],
      likes: doc.data()['likes'],
      location: doc.data()['location'],
      mediaUrl: doc.data()['mediaUrl'],
      ownerId: doc.data()['ownerId'],
      postId: doc.data()['postId'],
      userName: doc.data()['userName'],
      timestamp: doc.data()['timeStamp'],
    );
  }
  int getlikesCount(Map likes) {
    int count = 0;
    if (likes == null) {
      return 0;
    } else {
      likes.values.forEach((val) {
        if (val == true) {
          count++;
        }
      });
      return count;
    }
  }

  @override
  _PostsState createState() => _PostsState(
        description: this.description,
        ownerId: this.ownerId,
        userName: this.userName,
        location: this.location,
        mediaUrl: this.mediaUrl,
        postId: this.postId,
        likes: this.likes,
        likesCount: getlikesCount(likes),
        timestamp: this.timestamp,
      );
}

class _PostsState extends State<Posts> {
  final String ownerId;
  final String userName;
  final String location;
  final String mediaUrl;
  final String postId;
  int likesCount;
  Map likes;
  final String description;
  bool isLiked;
  Timestamp timestamp;

  _PostsState(
      {this.description,
      this.likes,
      this.location,
      this.mediaUrl,
      this.ownerId,
      this.postId,
      this.userName,
      this.likesCount,
      this.timestamp});

  final cuurentUserId = currentUser?.id;

  //this function responsible for adding the like to activity when user hit the like button
  addLikeToActivityFeed() {
    bool isNotPostOwner = ownerId != cuurentUserId;
    if (isNotPostOwner) {
      feedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        'type': 'like',
        'commentData': '',
        'username': currentUser.userName,
        'userId': ownerId,
        'photoUrl': currentUser.photoUrl,
        'mediaUrl': mediaUrl,
        'postId': postId,
        'timestamp': DateTime.now(),
        'description': description,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = ownerId != cuurentUserId;
    if (isNotPostOwner) {
      feedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get()
          .then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[cuurentUserId] == true);
    return Container(
      child: Column(
        children: [
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }

  handleLikesPost() {
    bool _isliked = likes[cuurentUserId] == true;

    if (_isliked) {
      postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
        'likes.$cuurentUserId': false,
      });
      setState(() {
        likesCount -= 1;
        isLiked = false;
        likes[cuurentUserId] = false;
      });
      removeLikeFromActivityFeed();
    } else if (!_isliked) {
      {
        postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
          'likes.$cuurentUserId': true,
        });
        setState(() {
          likesCount += 1;
          isLiked = true;
          likes[cuurentUserId] = true;
        });
        addLikeToActivityFeed();
      }
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikesPost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                child: Material(
                  elevation: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 10,
                    child: cashedNetworkImage(mediaUrl),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: handleLikesPost,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.pink,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            IconButton(
              icon: Icon(
                Icons.chat,
                color: Colors.blueAccent,
              ),
              onPressed: () => goToComments(
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
                description: description,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Text(
                likesCount.toString(),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),
              Text('Likes'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Text(
                userName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),
              Text(description),
              Divider(
                height: 5,
              ),
            ],
          ),
        ),
        Text(timestamp.toDate().toString()),
      ],
    );
  }

  buildPostHeader() {
    return FutureBuilder(
        future: userRef.doc(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          LocalUser user = LocalUser.userFromDoc(snapshot.data);
          return ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(profileId: user.id),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(profileId: user.id),
                  ),
                );
              },
              child: Text(
                user.userName,
                style: TextStyle(
                  color: Color(0xff242240),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(location),
          );
        });
  }

  goToComments(
      {String description, String postId, String mediaUrl, String ownerId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Comments(
                postId: postId,
                postOwnerId: ownerId,
                mediaUrl: mediaUrl,
              )),
    );
  }
}
