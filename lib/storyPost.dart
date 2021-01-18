import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socialmedia/progressIndecators.dart';
import 'package:uuid/uuid.dart';
import 'home.dart';
import 'package:image/image.dart' as Im;

class StoryPost extends StatefulWidget {
  final File file;
  final List<String> ides;
  StoryPost({this.file, this.ides});

  @override
  _StoryPostState createState() => _StoryPostState();
}

class _StoryPostState extends State<StoryPost> {
  File _file;
  String postId = Uuid().v4();
  bool isLoading = false;

  handleSubmit() async {
    setState(() {
      isLoading = true;
    });
    await compressedImage();
    final medeiaUrl = await uploadImage(_file);
    await createPostInFirestore(
      imageFile: medeiaUrl,
    );
    setState(() {
      isLoading = false;
      postId = Uuid().v4();
    });
    Navigator.pop(context);
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = ref.child('post_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;
    Future<String> downloadUrl = storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String imageFile}) {
    //1) adding the post to the user posts collection
    storyRef.doc(currentUser.id).collection('userStories').doc(postId).set({
      'postId': postId,
      'ownerId': currentUser.id,
      'userName': currentUser.userName,
      'mediaUrl': imageFile,
      'timeStamp': DateTime.now(),
      'userPhoto': currentUser.photoUrl,
    });
    //2)adding the post to the user time line collection
    timelineStoryRef
        .doc(currentUser.id)
        .collection('timeLinePosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': currentUser.id,
      'userName': currentUser.userName,
      'mediaUrl': imageFile,
      'timeStamp': DateTime.now(),
      'userPhoto': currentUser.photoUrl,
    });
//3)adding the post to the userFollowers time line collection
    if (widget.ides.isNotEmpty && widget.ides != null) {
      widget.ides.forEach((id) {
        print('$id');
        timelineStoryRef.doc(id).collection('timeLinePosts').doc(postId).set({
          'postId': postId,
          'ownerId': currentUser.id,
          'userName': currentUser.userName,
          'mediaUrl': imageFile,
          'timeStamp': DateTime.now(),
          'userPhoto': currentUser.photoUrl,
        });
      });
    }
  }

  compressedImage() async {
    final timDir = await getTemporaryDirectory();
    final path = timDir.path;
    Im.Image imageFile = Im.decodeImage(widget.file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytes(
        Im.encodeJpg(imageFile, quality: 85),
      );
    setState(() {
      _file = compressedImageFile;
    });
  }

  uploadPost() {
    return Scaffold(
      body: SafeArea(
        child: Container(
            decoration: BoxDecoration(
                color: Colors.black87,
                image: DecorationImage(
                  image: FileImage(widget.file),
                  fit: BoxFit.contain,
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 5),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            CachedNetworkImageProvider(currentUser.photoUrl),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        currentUser.userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                isLoading ? circularProgress() : Text(''),
                Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancle',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                      FlatButton(
                          onPressed: () => handleSubmit(),
                          child: Text(
                            'Post',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: uploadPost(),
    );
  }
}
