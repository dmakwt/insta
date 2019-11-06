import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search> {
  final searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: (value) {
          handleSearch(value);
        },
      ),
    );
  }

  handleSearch(String value) {
    Future<QuerySnapshot> users = usersRef
        .where('username', isGreaterThanOrEqualTo: value)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  Container buildNoContent() {
    final oriantation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: oriantation == Orientation.portrait ? 300 : 200,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: oriantation == Orientation.portrait ? 50  : 20,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }

        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult userResult = UserResult(user);
          searchResults.add(userResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () => showProfile(context, profileId: user.id),
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: Text(
              user.displayName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Divider(
            height: 2,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}


showProfile(BuildContext context, {@required String profileId}){
  Navigator.push(context, MaterialPageRoute(
    builder: (context)=> Profile(profiledId: profileId,)
  ),);
}