import 'package:flutter/material.dart';

class Item {
  final Color color;
  final List<int> subItems = List.generate(4, ((index) => index));
  double get height => subItems.length * 50 + 60;

  Item(this.color);
}
