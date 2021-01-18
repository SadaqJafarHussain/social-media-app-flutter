import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/home.dart';
import 'package:socialmedia/profile.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:socialmedia/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  bool get wantKeepAlive => true;
  clear() {
    serchController.clear();
  }

  TextEditingController serchController = TextEditingController();
  Future<QuerySnapshot> searchResult;
  handlSearch(String userName) {
    Future<QuerySnapshot> users =
        userRef.where("username", isGreaterThanOrEqualTo: userName).get();
    if (users != null) {
      setState(() {
        searchResult = users;
      });
    } else {
      setState(() {
        searchResult = null;
      });
    }
  }

  Widget users() {
    return FutureBuilder(
      future: searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<UserContents> result = [];
          snapshot.data.documents.forEach((doc) {
            LocalUser user = LocalUser.userFromDoc(doc);
            result.add(UserContents(
              user: user,
            ));
          });
          return ListView(
            children: result,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: serchController,
                    onChanged: (value) => handlSearch(value),
                    decoration: InputDecoration(
                      fillColor: Color(0xff242240),
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            40,
                          ),
                          bottomRight: Radius.circular(
                            40,
                          ),
                        ),
                      ),
                      hintText: 'Type to search...',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.search),
                        color: Colors.orange,
                        iconSize: 30,
                      ),
                      suffixIcon: IconButton(
                        onPressed: clear,
                        icon: Icon(
                          Icons.close,
                          color: Colors.orange,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                )),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: searchResult == null ? noUsers() : users(),
            )
          ],
        ),
      ),
    );
  }

  Column noUsers() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          alignment: Alignment.center,
          child: Center(
            child: Image(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.3,
              image: AssetImage('images/no-content.png'),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'No users found',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}

class UserContents extends StatelessWidget {
  final LocalUser user;
  UserContents({this.user});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(profileId: user.id),
            ),
          );
        },
        child: Material(
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: Text(
              user.displayName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              user.userName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
