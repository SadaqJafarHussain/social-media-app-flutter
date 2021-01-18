const functions = require('firebase-functions');
const admin=require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCreateFollower=functions.firestore.document("/followers/{userId}/userFollowers/{followerId}")
.onCreate(async(snapshot,context)=>{
const userId =context.params.userId;
const followerId =context.params.followerId;

//create followed users posts
const followedUsersPostsRef= admin
.firestore()
.collection('posts')
.document(userId)
.collection('userPosts');

//create following users timeline
const timelinePostsRef = admin 
.firestore()
.collection('timeline')
.document(followerId)
.collection('timelinePosts');
//get followed users posts
const querySnapshot= await followedUsersPostsRef.get();

querySnapshot.forEach(doc => {
    if(doc.exists){
        const postId=doc.id;
        const postData=doc.data();
        timelinePostsRef.document(postId).set(postData);
    }
});
});
