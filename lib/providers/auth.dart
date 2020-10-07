import 'dart:async';
import 'package:agent_second/constants/config.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/util/data.dart';
import 'package:agent_second/util/dio.dart';
import 'package:agent_second/widgets/custom_toast_widget.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:cron/cron.dart';
import 'package:provider/provider.dart';
import 'package:agent_second/providers/global_variables.dart';

class Auth with ChangeNotifier {
  // Auth();
  Future<dynamic> login(
      String usernametext, String passwordText, BuildContext context) async {
    SystemChannels.textInput.invokeMethod<String>('TextInput.hide');

    await dio.post<dynamic>("login", data: <String, dynamic>{
      "username": usernametext.toString().trim(),
      "password": passwordText
    }).then<dynamic>((Response<dynamic> value) async {
      if (value.statusCode == 422) {
        return value.data['errors'];
      }

      if (value.statusCode == 200) {
        if (value.data != "fail") {
          print("am the token value : ${value.data['api_token']}");
          await data.setData(
              "authorization", "Bearer ${value.data['api_token']}");
          dio.options.headers['authorization'] =
              'Bearer ${value.data['api_token']}';
          config.verchilId = value.data['vehicle_board_no'].toString();
          data.setData(
              "verchil_id", value.data['vehicle_board_no'].toString());
          data.setData("agent_id", value.data['id'].toString());
          data.setData("company_name", value.data['company_name'].toString());
          data.setData("agent_name", value.data['username'].toString());
          data.setData("tax", value.data['tax'].toString());
          data.setData("trn", value.data['trn'].toString());
          config.companyName = value.data['company_name'].toString();
          config.trn = value.data['trn'].toString();
          config.tax = double.parse(value.data['tax'].toString());
          data.setData("agent_email", value.data['email'].toString());
          final GlobalVars globalVarsProv =
              Provider.of<GlobalVars>(context, listen: false);
          cron.schedule(Schedule.parse('*/1 * * * *'), () async {
            globalVarsProv.incrementTimeSinceLogin();
          });
          Navigator.popAndPushNamed(context, '/Home',
              arguments: <String, dynamic>{});
        } else {
          showToastWidget(
              IconToastWidget.fail(msg: trans(context, 'invalid_credentals')),
              context: context,
              position: StyledToastPosition.center,
              animation: StyledToastAnimation.scale,
              reverseAnimation: StyledToastAnimation.fade,
              duration: const Duration(seconds: 4),
              animDuration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              reverseCurve: Curves.linear);
        }
      } else {}
    });
  }

  Map<String, dynamic> user;
  StreamSubscription<dynamic> userAuthSub;

  @override
  void dispose() {
    if (userAuthSub != null) {
      userAuthSub.cancel();
      userAuthSub = null;
    }
    super.dispose();
  }

  bool get isAuthenticated {
    return user != null;
  }

  void signInAnonymously() {}

  void signOut() {}

  BluetoothDevice device;
  bool connected = false;
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
}
