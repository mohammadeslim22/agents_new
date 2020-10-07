import 'package:agent_second/constants/config.dart';
import 'package:flutter/material.dart';

class AppBarTextTitle extends StatelessWidget {
  const AppBarTextTitle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(config.companyName);
  }
}
