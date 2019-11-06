import 'package:flutter/material.dart';

AppBar header(BuildContext context, {bool isAppTitle = false, titleText, removeBackButton = false}) {
  return AppBar(
    
    automaticallyImplyLeading: removeBackButton? false : true,
    title: Text(
      isAppTitle? 'iVlog' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle? 'Signatra' : '',
        fontSize: isAppTitle? 50 : 22,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
