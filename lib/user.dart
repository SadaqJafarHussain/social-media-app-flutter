import 'package:cloud_firestore/cloud_firestore.dart';

class LocalUser {
  String id;
  String email;
  String userName;
  String photoUrl;
  String bio;
  String displayName;
  LocalUser(
      {this.bio,
      this.email,
      this.id,
      this.photoUrl,
      this.userName,
      this.displayName});
  static userFromDoc(DocumentSnapshot doc) {
    return LocalUser(
      id: doc['id'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
      userName: doc['username'],
      displayName: doc['displyName'],
    );
  }
}
