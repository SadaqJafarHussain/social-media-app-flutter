import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socialmedia/home.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:socialmedia/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  final String currentId;

  EditProfile({@required this.currentId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String imageId = Uuid().v4();
  File file;
  LocalUser user;
  bool isLoading = false;
  String imageFile;
  bool isDataLoading = false;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.doc(widget.currentId).get();
    user = LocalUser.userFromDoc(doc);

    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    imageFile = user.photoUrl;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        title: Text(
          'Edit profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 40,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: file == null
                        ? CachedNetworkImageProvider(user.photoUrl)
                        : FileImage(file),
                  ),
                ),
                Center(
                  child: FlatButton(
                    onPressed: () => getImage(),
                    child: Text(
                      'Change photo',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Display Name',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: displayNameController,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Bio',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: bioController,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                isDataLoading
                    ? Center(
                        child: circularProgress(),
                      )
                    : Text(''),
                Center(
                  child: RaisedButton(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed:
                        isDataLoading ? null : () => updateUserInfirestore(),
                    child: Text(
                      'Update profile',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.blueAccent[200],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
    );
  }

  compressedImage() async {
    final timDir = await getTemporaryDirectory();
    final path = timDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$imageId.jpg')
      ..writeAsBytes(
        Im.encodeJpg(imageFile, quality: 85),
      );
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = ref.child('post_$imageId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    Future<String> downloadUrl = storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  updateUserInfirestore() async {
    if (file == null) {
      setState(() {
        isDataLoading = true;
      });
      Timer(
          Duration(seconds: 3),
          writeInFirestore(
              displayNameController.text, bioController.text, null));
      imageId = Uuid().v4();
      setState(() {
        isDataLoading = false;
      });
    } else {
      setState(() {
        isDataLoading = true;
      });
      await compressedImage();
      final mediaData = await uploadImage(file);
      writeInFirestore(
          displayNameController.text, bioController.text, mediaData);
      imageId = Uuid().v4();
      setState(() {
        isDataLoading = false;
      });
    }
    SnackBar snackBar = SnackBar(
      content: Text('profile updated !'),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  writeInFirestore(String displayName, String bio, String media) {
    userRef.doc(currentUser.id).update({
      'displyName': displayName == null ? currentUser.displayName : displayName,
      'bio': bio,
      'photoUrl': media == null ? currentUser.photoUrl : media,
    });
  }
}
