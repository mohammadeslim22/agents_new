import 'package:flutter/material.dart';

class MyColors {
  factory MyColors() {
    return _colors;
  }

  MyColors._internal();

  static final MyColors _colors = MyColors._internal();
  Color pink = Colors.pink;
  Color white = const Color(0xffffffff);
  Color grey = const Color(0xFFCCCCCC);
  Color black = const Color(0xff101010);
  Color yellow = const Color(0xffFFC000);
  Color green = const Color(0xff007C40);
  Color red = const Color(0xffFC531C);
  Color blue = Colors.blue;
  Color myBlue = const Color(0xFF0085C7);
  Color redOpacity = const Color(0xffFC531C);
  Color orange = Colors.orange;
  Color trans = Colors.transparent;
  Color ggrey = Colors.grey;
  Color purple = Colors.purple;
}

final MyColors colors = MyColors();
