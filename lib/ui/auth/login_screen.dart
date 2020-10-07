import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/providers/auth.dart';
import 'package:agent_second/providers/counter.dart';
import 'package:agent_second/widgets/text_form_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flare_flutter/flare_actor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isButtonEnabled = true;
  static List<String> validators = <String>[null, null];
  static List<String> keys = <String>['username', 'password'];
  Map<String, String> validationMap =
      Map<String, String>.fromIterables(keys, validators);

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the App'),
            actionsOverflowButtonSpacing: 50,
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  bool _obscureText = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode focus1 = FocusNode();
  final FocusNode focus2 = FocusNode();
  Widget customcard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Form(
        key: _formKey,
        onWillPop: () {
          return _onWillPop();
        },
        child: Column(
          children: <Widget>[
            TextFormInput(
                text: trans(context, 'username'),
                cController: usernameController,
                prefixIcon: Icons.person_outline,
                kt: TextInputType.emailAddress,
                obscureText: false,
                readOnly: false,
                onTab: () {},
                nextfocusNode: focus1,
                onFieldSubmitted: () {
                  focus1.requestFocus();
                },
                validator: (String value) {
                  if (value.isEmpty) {
                    return trans(context, 'plz_enter_username');
                  }
                  return validationMap['username'];
                }),
            const SizedBox(height: 16),
            TextFormInput(
                text: trans(context, 'pin_code'),
                cController: passwordController,
                prefixIcon: Icons.lock_outline,
                kt: TextInputType.number,
                readOnly: false,
                onTab: () {},
                suffixicon: IconButton(
                  icon: Icon(
                    (_obscureText == false)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                onFieldSubmitted: () {
                  focus2.requestFocus();
                },
                obscureText: _obscureText,
                focusNode: focus1,
                validator: (String value) {
                  if (value.isEmpty) {
                    return trans(context, 'plz_enter_pass');
                  }
                  return validationMap['password'];
                }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Auth auth = Provider.of<Auth>(context);

    final MyCounter bolc = Provider.of<MyCounter>(context);
    return Scaffold(
        backgroundColor: colors.blue,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: <Widget>[
                            SvgPicture.asset(
                              'assets/images/welcomeback.svg',
                              width: 80.0,
                              height: 80.0,
                            ),
                            const SizedBox(height: 24),
                            Text(trans(context, 'welcome_back'),
                                textAlign: TextAlign.center,
                                style: styles.mystyle2),
                            customcard(context),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: colors.myBlue)),
                                  onPressed: () async {
                                    if (_isButtonEnabled) {
                                      if (_formKey.currentState.validate()) {
                                        checkInternetConnection(bolc);
                                        bolc.togelf(true);
                                        setState(() {
                                          _isButtonEnabled = false;
                                        });
                                        await auth
                                            .login(
                                                usernameController.text,
                                                passwordController.text,
                                                context)
                                            .then((dynamic value) {
                                          if (value != null) {
                                            value.forEach(
                                                (String k, dynamic vv) {
                                              setState(() {
                                                validationMap[k] =
                                                    vv[0].toString();
                                              });
                                            });
                                            _formKey.currentState.validate();
                                            validationMap.updateAll(
                                                (String key, String value) {
                                              return null;
                                            });
                                          }
                                        });
                                        setState(() {
                                          _isButtonEnabled = true;
                                        });
                                        bolc.togelf(false);
                                      }
                                    }
                                  },
                                  color: colors.blue,
                                  textColor: colors.white,
                                  child: bolc
                                      .returnchild(trans(context, 'login'))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                        ClipRRect(
                                borderRadius: BorderRadius.circular(80.0),
                                child: CircleAvatar(
                                  maxRadius: 45,
                                  minRadius: 30,
                                  backgroundColor: colors.white,
                                  child: SvgPicture.asset(
                                      'assets/images/drawer_logo.svg',
                                      width: 80.0,
                                      height: 80.0),
                                )),
                          const SizedBox(height: 64),
                          SvgPicture.asset(
                            'assets/images/mainLogo.svg',
                            width: 240.0,
                            height: 240.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Text("ALTARIQ Systems & Projects",
                      style: styles.underHeadwhite)),
            ],
          ),
        ));
  }

  Future<void> checkInternetConnection(MyCounter bolc) async {
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      } else {
        showAWAITINGSENDOrderTruck();
        setState(() {
          _isButtonEnabled = true;
        });
        bolc.togelf(false);
      }
    } on SocketException catch (_) {
      showAWAITINGSENDOrderTruck();
      setState(() {
        _isButtonEnabled = true;
      });
      bolc.togelf(false);
    }
  }

  void showAWAITINGSENDOrderTruck() {
    showGeneralDialog<dynamic>(
        barrierLabel: "Label",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.73),
        transitionDuration: const Duration(milliseconds: 350),
        context: context,
        pageBuilder: (BuildContext context, Animation<double> anim1,
            Animation<double> anim2) {
          return InkWell(
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              height: 250,
              width: 250,
              child: const FlareActor("assets/images/Wifianimation.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                  animation: "loading"),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          );
        });
  }
}
