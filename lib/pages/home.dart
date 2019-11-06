import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final storageRef = FirebaseStorage.instance.ref();

final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');

final timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      // print('Error signin: $err');
    });

    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      // print('Error signin: $err');
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
      configurePushNotification();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  configurePushNotification() {
    final user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      // print('Firebase Messging Token: $token\n');
      userRef.document(user.id).updateData({'androidNotificationToken': token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume:  (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        // print('on message: $message\n');
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          // print('Notification shown!');
          SnackBar snackbar = SnackBar(
            content: Text(
              body,
              overflow: TextOverflow.ellipsis,
            ),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
        } else {
          // print('Notification NOT shown');
        }
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
      alert: true,
      badge: true,
      sound: true,
    ));
    _firebaseMessaging.onIosSettingsRegistered.listen((setting) {
      // print("Setting registered: $setting");
    });
  }

  createUserInFirestore() async {
    //1) check if user exists in users collection in database
    final user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    //2) if the user doesn't exist, then we want to take them to the create account page
    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
      //3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp,
      });

      //make new user their own follower (to include their posts in their timeline)
      await followersRef
          .document(user.id)
          .collection('userFollowers')
          .document(user.id)
          .setData({});

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );
  }

  Scaffold _buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        controller: pageController,
        children: <Widget>[
          Timeline(currentUser: currentUser),
          Search(),
          Upload(currentUser: currentUser),
          ActivityFeed(),
          Profile(profiledId: currentUser?.id),
        ],
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 35),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.account_circle,
          )),
        ],
      ),
    );
  }

  Scaffold _buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'iVlog',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              onTap: () {
                login();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? _buildAuthScreen() : _buildUnAuthScreen();
  }
}
