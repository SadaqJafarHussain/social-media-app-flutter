import 'package:flutter/material.dart';

AppBar appbar(String text) {
  return AppBar(
    backgroundColor: Colors.deepPurple[300],
    title: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    centerTitle: true,
  );
}
