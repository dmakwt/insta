import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';

void main() {
  // enable timestamps in snapshot Firestore
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    // print('Timestamps enabled in snapshots\n');
  }, onError: (_) {
    // print('Error enabling timestamps in snapshots\n');
  });
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.greenAccent,
      ),
      home: Home(),
    );
  }
}
