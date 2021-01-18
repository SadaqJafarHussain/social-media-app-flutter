import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/usernamelist.dart';

class CreateUserName extends StatefulWidget {
  @override
  _CreateUserNameState createState() => _CreateUserNameState();
}

class _CreateUserNameState extends State<CreateUserName> {
  Future<QuerySnapshot> searchResult;
  final key = GlobalKey<FormState>();

  String username;
  submit() {
    final form = key.currentState;
    if (form.validate()) {
      form.save();
      Navigator.pop(context, username);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Hashtag',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60.0,
                      fontFamily: 'Signatra',
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Form(
                  key: key,
                  child: TextFormField(
                    validator: (val) {
                      if (val.trim().length < 3 || val.isEmpty) {
                        return 'User name  too short';
                      } else if (val.trim().length > 12) {
                        return 'User name too long';
                      } else if (isUserUniqe(val) == false) {
                        return 'username is already exists';
                      } else
                        return null;
                    },
                    onSaved: (value) => username = value.trim(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      hintText: 'username must be at least 3 charcters',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                      labelText: 'user name',
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 50,
                  child: RaisedButton(
                    color: Colors.blueAccent,
                    elevation: 10,
                    onPressed: submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
