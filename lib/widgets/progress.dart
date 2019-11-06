import 'package:flutter/material.dart';

Container circularProgress(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
    ),
  );
}

Container linearProgress(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
    ),
  );
}
