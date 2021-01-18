import 'package:flutter/material.dart';

Container linearProgress() {
  return Container(
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
    ),
  );
}

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(bottom: 10.0, top: 0.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
    ),
  );
}
