import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialmedia/activity.dart';
import 'package:socialmedia/createUsername.dart';
import 'package:socialmedia/notification.dart';
import 'package:socialmedia/profile.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:socialmedia/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmedia/timeline.dart';
import 'package:socialmedia/user.dart';
import 'package:socialmedia/usernamelist.dart';

final googleSignIn = GoogleSignIn();

final userRef = FirebaseFirestore.instance.collection('users');
final storyRef = FirebaseFirestore.instance.collection('stories');
final ref = FirebaseStorage.instance.ref();
final postsRef = FirebaseFirestore.instance.collection('posts');
final userFollowRef = FirebaseFirestore.instance.collection('followers');
final userFollowingRef = FirebaseFirestore.instance.collection('following');
final feedRef = FirebaseFirestore.instance.collection('activityFeed');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final timelineRef = FirebaseFirestore.instance.collection('timeLine');
final timelineStoryRef = FirebaseFirestore.instance.collection('timeLineStory');

LocalUser currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> followingId = [];
  createUser() async {
    //check if user is exists or not if not then we will create it
    final user = googleSignIn.currentUser;
    final DocumentSnapshot doc = await userRef.doc(user.id).get();
    if (!doc.exists) {
      final userName = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateUserName(),
        ),
      );
      userRef.doc(user.id).set({
        "id": user.id,
        "username": userName,
        "photoUrl": user.photoUrl,
        "displyName": user.displayName,
        "email": user.email,
        "bio": ""
      });
    }
    setState(() {
      currentUser = LocalUser.userFromDoc(doc);
      userNames.add(currentUser.userName);
    });
  }

  int pageIndex = 0;
  PageController pageController;
  isSignedin() async {
    final result = await googleSignIn.isSignedIn();
    if (result) {
      googleSignIn.signInSilently(suppressErrors: false).then((account) {
        if (account != null) {
          createUser();
          setState(() {
            isAuth = true;
          });
        } else {
          setState(() {
            isAuth = false;
          });
        }
      }).catchError((onError) {
        print(onError);
      });
    }
  }

  run() {}

  void initState() {
    pageController = PageController();
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) {
        createUser();
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
    }, onError: ((error) {
      print(error);
    }));
    isSignedin();
  }

  onChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(
        microseconds: 500,
      ),
      curve: Curves.easeInOut,
    );
  }

  bool isAuth = false;
  Scaffold authBuild() {
    return Scaffold(
        body: PageView(
          children: [
            TimeLine(
              currentUser: currentUser,
            ),
            Search(),
            Activity(currentUser: currentUser),
            Notify(),
            Profile(
              profileId: currentUser?.id,
            ),
          ],
          controller: pageController,
          onPageChanged: onChanged,
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              child: CupertinoTabBar(
                inactiveColor: Colors.blueGrey,
                backgroundColor: Colors.white,
                currentIndex: pageIndex,
                onTap: onTap,
                activeColor: Colors.orange,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.whatshot),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.photo_camera,
                      size: 40.0,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_active),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget unAuthBuild() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange,
            Colors.purple,
          ],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('images/appIcon.png'),
              width: 90,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'HashTag',
              style: TextStyle(
                fontFamily: 'Signatra',
                color: Colors.white,
                fontSize: 60.0,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                try {
                  await googleSignIn.signIn();
                } on PlatformException catch (platformerror) {
                  print(platformerror);
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Material(
                  elevation: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 7, top: 7, bottom: 7, right: 0),
                        child: Image(
                          image: AssetImage('images/google.png'),
                          width: 50,
                        ),
                      ),
                      Container(
                        color: Colors.black,
                        width: 1,
                        height: 40,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Sign In with Google',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      Image(
                        color: Colors.transparent,
                        image: AssetImage('images/google.png'),
                        width: 50,
                      ),
                    ],
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return isAuth ? home() : unAuthBuild();
  }

  home() {
    if (currentUser == null) {
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange,
            Colors.purple,
          ],
        )),
        child: circularProgress(),
      );
    } else {
      return authBuild();
    }
  }
}
