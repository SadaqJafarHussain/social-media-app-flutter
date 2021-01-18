import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia/home.dart';
import 'package:socialmedia/posts.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:socialmedia/stories.dart';
import 'package:socialmedia/storyPost.dart';
import 'package:socialmedia/user.dart';

class TimeLine extends StatefulWidget {
  final LocalUser currentUser;
  TimeLine({this.currentUser});
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  List<String> ides;
  File file;
  Story myStory;
  List<Story> userstories;
  List<Posts> posts = [];
  bool isLoading;
  takePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675.0,
      maxWidth: 960.0,
    );
    setState(() {
      this.file = file;
    });

    if (file != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StoryPost(
                    file: file,
                  )));
    } else {
      return;
    }
  }

  getFollowers() async {
    QuerySnapshot snapshot = await userFollowRef
        .doc(currentUser.id)
        .collection('userFollowers')
        .get();
    if (snapshot.docs.isNotEmpty) {
      List<String> values = [];
      snapshot.docs.forEach((doc) {
        values.add(doc.id);
      });
      setState(() {
        ides = values;
      });
    }
  }

  photoFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 675.0,
      maxWidth: 960.0,
    );
    setState(() {
      this.file = file;
    });
    if (file != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StoryPost(
                    file: file,
                    ides: ides,
                  )));
    } else {
      return;
    }
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))),
            children: [
              SimpleDialogOption(
                child: Container(
                  height: 3,
                  color: Colors.orange,
                ),
              ),
              SimpleDialogOption(
                  onPressed: takePhoto,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        'camera',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )),
              SimpleDialogOption(
                  onPressed: photoFromGallery,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'gallery',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        });
  }

  getAllStories() async {
    //get the current user story
    QuerySnapshot snapshot = await timelineStoryRef
        .doc(currentUser?.id)
        .collection('timeLinePosts')
        .where('ownerId', isEqualTo: currentUser.id)
        .get();
    if (snapshot.docs.isNotEmpty) {
      Story story = Story(
        username: snapshot.docs.first['userName'],
        userphoto: snapshot.docs.first['userPhoto'],
        timestamp: snapshot.docs.first['timeStamp'],
        mediaPhoto: snapshot.docs.first['mediaUrl'],
        postId: snapshot.docs.first['postId'],
      );
      setState(() {
        myStory = story;
      });
    }

    //get the other who i follow stories
    QuerySnapshot snap = await timelineStoryRef
        .doc(currentUser.id)
        .collection('timeLinePosts')
        .where('ownerId', isNotEqualTo: currentUser.id)
        .get();
    if (snap.docs.isNotEmpty) {
      List<Story> stories = [];
      snap.docs.forEach((story) {
        stories.add(Story(
          username: story['userName'],
          userphoto: story['userPhoto'],
          timestamp: story['timeStamp'],
          mediaPhoto: story['mediaUrl'],
          postId: story['postId'],
        ));
      });
      setState(() {
        userstories = stories;
      });
    }
  }

  noStoryYet(BuildContext parentContext) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => selectImage(parentContext),
          child: CircleAvatar(
            radius: 37,
            backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
            child: Padding(
              padding: EdgeInsets.only(top: 40, left: 40),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  radius: 15,
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          'Your Story',
          style: TextStyle(
            color: Colors.grey,
          ),
        )
      ],
    );
  }

  getAllPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await timelineRef.doc(currentUser.id).collection('timeLinePosts').get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((post) {
        posts.add(Posts.fromDocument(post));
      });
      setState(() {
        this.posts = posts;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFollowers();
    getAllPosts();
    getAllStories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 40, left: 10, right: 10),
            child: Material(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(top: 40, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'HashTag',
                            style: TextStyle(
                              fontFamily: 'Signatra',
                              color: Color(0xff242240),
                              fontSize: 40.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Icons.send_rounded,
                            color: Color(0xff242240),
                            size: 30,
                          )
                        ],
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        myStory == null ? noStoryYet(context) : myStory,
                        userstories == null
                            ? Text('')
                            : Expanded(
                                child: SizedBox(
                                  height: 100.0,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: userstories.length,
                                    itemBuilder: (context, index) {
                                      return userstories[index];
                                    },
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Divider(
                    height: 10,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                ],
              ),
            ),
          ),
          buildtimeline(),
        ],
      ),
    );
  }

  buildtimeline() {
    if (posts.isEmpty) {
      return circularProgress();
    } else {
      return Expanded(
          child: ListView(
        children: posts,
      ));
    }
  }
}
