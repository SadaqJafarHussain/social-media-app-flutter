import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/editprofile.dart';
import 'package:socialmedia/postTile.dart';
import 'package:socialmedia/posts.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:socialmedia/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socialmedia/home.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({
    @required this.profileId,
  });
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Posts> posts = [];
  bool isFollowing = false;
  bool isItGrid = true;
  List<Posts> postlist = [];
  int postCount = 0;
  String username;
  int followersCount = 0;
  int followingCount = 0;
  bool isLoading = false;
  List<String> choices = <String>[
    'Logout',
    'Cancel',
  ];
  getAllPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timeStamp')
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
    });

    snapshot.docs.forEach((doc) {
      postlist.add(Posts.fromDocument(doc));
    });
    DocumentSnapshot snap = await userRef.doc(widget.profileId).get();
    username = snap['username'];
  }

  @override
  void initState() {
    super.initState();
    getAllPosts();
    checkFollowing();
    getFollowers();
    getfollowing();
  }

  final String currentUserId = currentUser?.id;
  bool isItTheProfileOwner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Material(
        color: Color(0xfff5f5f5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ListView(
          children: [
            buildLayout(),
            // Divider(),
            postToggleOrentation(),
            // Divider(
            // height: 0.0,
            //),
            buildPosts(),
          ],
        ),
      ),
    );
  }

  logOut(String choice) {
    if (choice == 'Logout') {
      googleSignIn.signOut();
      googleSignIn.disconnect();
    }
  }

  postToggleOrentation() {
    return Container(
      color: Color(0xff242240),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.grid_on),
                color: isItGrid ? Colors.deepOrange : null,
                onPressed: () {
                  setState(() {
                    isItGrid = true;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.list,
                  size: 30,
                ),
                color: isItGrid ? null : Colors.deepOrange,
                onPressed: () {
                  setState(() {
                    isItGrid = false;
                  });
                },
              ),
            ],
          )),
    );
    ;
  }

  buildPosts() {
    if (isLoading == true) {
      return circularProgress();
    } else {
      if (postlist.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 50),
          child: Center(
            child: Column(
              children: [
                Image(
                  image: AssetImage(
                    'images/no-post.jpeg',
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      } else {
        if (isItGrid == true) {
          List<GridTile> gridTiles = [];
          postlist.forEach((post) {
            gridTiles.add(
              GridTile(
                child: PostTile(
                  post: post,
                ),
              ),
            );
          });
          return GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 1.5,
            crossAxisSpacing: 1.5,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: gridTiles,
          );
        } else if (isItGrid == false) {
          return Column(
            children: postlist,
          );
        }
      }
    }
  }

  buildLayout() {
    return FutureBuilder(
        future: userRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }
          LocalUser user = LocalUser.userFromDoc(snapshot.data);
          return Container(
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff242240),
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(40))),
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0.0,
                        title: Text(
                          username ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          PopupMenuButton<String>(
                              color: Colors.white30,
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.orange,
                              ),
                              onSelected: logOut,
                              itemBuilder: (context) {
                                return choices.map((String choice) {
                                  return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(
                                        choice,
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold),
                                      ));
                                }).toList();
                              }),
                        ],
                        centerTitle: true,
                        leading: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 40,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  buildCount('Posts', postCount),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  buildCount('Followers', followersCount),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  buildCount('Following', followingCount),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: buildButton(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        user.displayName,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Container(
                        width: 400,
                        child: Text(
                          user.bio,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  buildCount(String name, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          name,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfile(
                currentId: currentUserId,
              )),
    );
  }

  buildContent({String text, Function function, Color color, Color tcolor}) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      onPressed: function,
      color: color,
      child: Text(
        text,
        style: TextStyle(
          color: tcolor,
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  buildButton() {
    isItTheProfileOwner = widget.profileId == currentUserId;

    if (isItTheProfileOwner) {
      return buildContent(
        text: 'Edit profile',
        function: editProfile,
        color: Colors.white,
        tcolor: Colors.black,
      );
    } else if (isFollowing) {
      return buildContent(
        text: 'UnFollow ',
        function: handlunfollowUser,
        color: Colors.white,
        tcolor: Colors.black,
      );
    } else if (!isFollowing) {
      return buildContent(
        text: 'Follow +',
        function: handfollwouser,
        color: Colors.blueAccent,
        tcolor: Colors.white,
      );
    }
  }

  handfollwouser() {
    setState(() {
      isFollowing = true;
    });
    addUserTotimelinePosts();
    addUserTotimelineStories();
    //add followers to the user followers collection
    userFollowRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    //now we put that followers in his following collection
    userFollowingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    //now we send notification to that user
    feedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'commentData': '',
      'username': currentUser.userName,
      'userId': widget.profileId,
      'photoUrl': currentUser.photoUrl,
      'mediaUrl': '',
      'postId': '',
      'timestamp': DateTime.now(),
    });
  }

  removeUserFromTimeLine() async {
    QuerySnapshot snap =
        await timelineRef.doc(currentUserId).collection('timeLinePosts').get();

    if (snap.docs.isNotEmpty) {
      snap.docs.forEach((element) {
        element.reference.delete();
      });
    } else {
      print('nooooooooooo');
    }
  }

  addUserTotimelineStories() async {
    QuerySnapshot snapshot =
        await storyRef.doc(widget.profileId).collection('userStories').get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        timelineStoryRef
            .doc(currentUserId)
            .collection('timeLinePosts')
            .doc(doc['postId'])
            .set({
          'postId': doc['postId'],
          'ownerId': doc['ownerId'],
          'userName': doc['userName'],
          'mediaUrl': doc['mediaUrl'],
          'timeStamp': doc['timeStamp'],
          'userPhoto': doc['userPhoto'],
        });
      });

      setState(() {
        posts = [];
      });
    } else {
      print('no content');
    }
  }

  addUserTotimelinePosts() async {
    QuerySnapshot snapshot =
        await postsRef.doc(widget.profileId).collection('userPosts').get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        posts.add(Posts.fromDocument(doc));
      });
      posts.forEach((pos) {
        timelineRef
            .doc(currentUserId)
            .collection('timeLinePosts')
            .doc(pos.postId)
            .set({
          'postId': pos.postId,
          'ownerId': pos.ownerId,
          'userName': pos.userName,
          'mediaUrl': pos.mediaUrl,
          'location': pos.location,
          'description': pos.description,
          'timeStamp': pos.timestamp,
          'likes': pos.likes,
        });
      });

      setState(() {
        posts = [];
      });
    } else {
      print('no content');
    }
  }

  handlunfollowUser() {
    setState(() {
      isFollowing = false;
    });
    removeUserFromTimeLine();
    userFollowRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    userFollowingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    feedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  checkFollowing() async {
    DocumentSnapshot doc = await userFollowRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await userFollowRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followersCount = snapshot.docs.length;
    });
  }

  getfollowing() async {
    QuerySnapshot snapshot = await userFollowingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }
}
