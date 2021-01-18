import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:socialmedia/user.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:socialmedia/home.dart';

class Activity extends StatefulWidget {
  final LocalUser currentUser;
  Activity({this.currentUser});
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  Geolocator geolocator = Geolocator();
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  bool isLoading = false;
  List<String> ides = [];
  bool islocationLoading = false;
  String postId = Uuid().v4();
  File file;
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
  }

  getFollowers() async {
    QuerySnapshot snapshot = await userFollowRef
        .doc(widget.currentUser.id)
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
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'Create Post',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff242240),
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
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

  @override
  void initState() {
    super.initState();
    getFollowers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: file == null ? buildLayout() : uploadPost(),
    );
  }

  uploadPost() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: clearImage,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blueAccent,
            size: 30,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: isLoading ? null : handleSubmit,
            child: Text(
              'Post',
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 10.0,
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          isLoading ? linearProgress() : Text(''),
          Container(
            height: 280,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  )),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: TextField(
              controller: captionController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write your Caption here...',
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.blueAccent,
              size: 35,
            ),
            title: TextField(
              controller: locationController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Where this Photo Was Taken?'),
            ),
          ),
          islocationLoading
              ? circularProgress()
              : SizedBox(
                  height: 20.0,
                ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  30.0,
                ),
              ),
              color: Colors.blue,
              label: Text(
                'Use the current location',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              onPressed: islocationLoading ? null : getLocation,
            ),
          ),
        ],
      ),
    );
  }

//clear image function make file = null which means cancel the operation of post an image
  clearImage() {
    setState(() {
      file = null;
    });
  }

  //compressed image function to reduce the size of the image
  compressedImage() async {
    final timDir = await getTemporaryDirectory();
    final path = timDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytes(
        Im.encodeJpg(imageFile, quality: 85),
      );
    setState(() {
      file = compressedImageFile;
    });
  }

  getLocation() async {
    setState(() {
      islocationLoading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final coordinates = Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    String address = "${first.locality} : ${first.countryName}";
    setState(() {
      locationController.text = address;
      islocationLoading = false;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = ref.child('post_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    Future<String> downloadUrl = storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String imageFile, String location, String caption}) {
    //1) adding the post to the user posts collection
    postsRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'userName': widget.currentUser.userName,
      'mediaUrl': imageFile,
      'location': location,
      'description': caption,
      'timeStamp': DateTime.now(),
      'likes': {}
    });
    //2)adding the post to the user time line collection
    timelineRef
        .doc(widget.currentUser.id)
        .collection('timeLinePosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'userName': widget.currentUser.userName,
      'mediaUrl': imageFile,
      'location': location,
      'description': caption,
      'timeStamp': DateTime.now(),
      'likes': {}
    });
//3)adding the post to the userFollowers time line collection
    ides.forEach((id) {
      timelineRef.doc(id).collection('timeLinePosts').doc(postId).set({
        'postId': postId,
        'ownerId': widget.currentUser.id,
        'userName': widget.currentUser.userName,
        'mediaUrl': imageFile,
        'location': location,
        'description': caption,
        'timeStamp': DateTime.now(),
        'likes': {}
      });
    });
  }

  handleSubmit() async {
    setState(() {
      isLoading = true;
    });
    await compressedImage();
    final medeiaUrl = await uploadImage(file);
    await createPostInFirestore(
      imageFile: medeiaUrl,
      location: locationController.text,
      caption: captionController.text,
    );
    locationController.clear();
    captionController.clear();
    setState(() {
      file = null;
      isLoading = false;
      postId = Uuid().v4();
    });
  }

  buildLayout() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xff242240), Colors.white],
      )),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30),
            ),
            Text(
              'Create New Post !',
              style: TextStyle(
                color: Colors.black38,
                fontFamily: 'HachiMaruPop',
                fontSize: 70,
              ),
              textAlign: TextAlign.center,
            ),
            Material(
              color: Colors.white,
              elevation: 10,
              child: FlatButton(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.add,
                    color: Colors.orange,
                    size: 60,
                  ),
                  radius: 50.0,
                ),
                onPressed: () => selectImage(context),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)),
            ),
          ],
        ),
      ),
    );
  }
}
