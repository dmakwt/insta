import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;

    setState(() {
      isLoading = false;
    });
  }

  Column buildDisPlayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Display Name',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: 'Update Display Name',
            errorText: _displayNameValid ? null : 'Display Name too short',
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Bio',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Update Bio',
            errorText: _bioValid ? null : 'Bio is too long',
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;

      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.document(widget.currentUserId).updateData({
        'disPlayName': displayNameController.text,
        'bio': bioController.text,
      });

      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Profile updated!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              size: 30,
              color: Colors.green,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: isLoading
          ? circularProgress(context)
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom: 8,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: CachedNetworkImageProvider(
                              user.photoUrl,
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            buildDisPlayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      RaisedButton(
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: updateProfileData,
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: FlatButton.icon(
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.redAccent,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 20,
                            ),
                          ),
                          onPressed: logout,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
