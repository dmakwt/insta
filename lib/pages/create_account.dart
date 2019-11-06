import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username;

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(
        content: Text('Welcome $username'),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: 'Create User', removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  'Create User',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidate: true,
                  child: TextFormField(
                    onChanged: (value) => username = value,
                    validator: (value) {
                      if (value.trim().length < 3 || value.isEmpty) {
                        return 'Username too short';
                      } else if (value.trim().length > 12) {
                        return 'Username too long';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      labelStyle: TextStyle(fontSize: 15),
                      hintText: 'Must be at least 3 characters',
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: submit,
                child: Container(
                  height: 50,
                  width: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
