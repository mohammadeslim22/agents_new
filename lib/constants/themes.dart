import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData mainThemeData() {
  return ThemeData(
    primaryColor: colors.blue,
    primaryTextTheme: const TextTheme(),
    scaffoldBackgroundColor:const Color(0xFFF2FBFF),
    appBarTheme: AppBarTheme(
      color: colors.myBlue,

      elevation: 0.0,
      iconTheme: IconThemeData(color: colors.white),
      textTheme: const TextTheme(),
    ),
    fontFamily: "Almarai",
    canvasColor: Colors.white,
    
    cursorColor: colors.myBlue,
    hintColor: colors.white,
   // bottomSheetTheme:  BottomSheetThemeData(elevation: 10,backgroundColor: Colors.white.withOpacity(.75)),
    textTheme: TextTheme(
      bodyText2: TextStyle(
        color: colors.white,
        fontSize: 14.0,
      ),
    ),
  );
}
