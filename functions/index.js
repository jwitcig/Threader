var functions = require('firebase-functions');

// // Start writing Firebase Functions
// // https://firebase.google.com/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// })

var firebase = require("firebase");

// Initialize Firebase
// TODO: Replace with your project's customized code snippet
var config = {
   apiKey: "AIzaSyB-AwnXkZcorCMjpF7O0_hRXmlK3z3SjDk",
   authDomain: "threader-dev.firebaseapp.com",
   databaseURL: "https://threader-dev.firebaseio.com",
   storageBucket: "threader-dev.appspot.com",
   messagingSenderId: "418943937573"
 };
var defaultApp = firebase.initializeApp(config);

console.log(defaultApp.name);  // "[DEFAULT]"

// You can retrieve services via the defaultApp variable...
var defaultDatabase = defaultApp.database();

// ... or you can use the equivalent shorthand notation
defaultDatabase = firebase.database();

var tagsRef = firebase.database().ref('tag');
  tagsRef.on('value', function(snapshot) {
    var tags = snapshot.val();

    console.log(tags);

    // Send the email to the user.
    // [START_EXCLUDE]
    // if (email) {
    //   sendNotificationEmail(email).then(function() {
    //     // Save the date at which we sent that notification.
    //     // [START write_fan_out]
    //     var update = {};
    //     update['/posts/' + postId + '/lastNotificationTimestamp'] =
    //         firebase.database.ServerValue.TIMESTAMP;
    //     update['/user-posts/' + uid + '/' + postId + '/lastNotificationTimestamp'] =
    //         firebase.database.ServerValue.TIMESTAMP;
    //     firebase.database().ref().update(update);
    //     // [END write_fan_out]
    //   });
    // }
    // [END_EXCLUDE]
  });
