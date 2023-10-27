import 'package:flutter/material.dart';

AppBar appBarWidget(String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text(title),
  );
}
