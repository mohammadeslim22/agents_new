import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/config.dart';
import 'package:agent_second/providers/global_variables.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:agent_second/models/ben.dart';
import 'package:agent_second/util/dio.dart';

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (config.looded) {
      return const DashBoard();
    }
    {
      return FutureBuilder<BeneficiariesModel>(
        future: getIt<GlobalVars>().getBenData(),
        builder:
            (BuildContext ctx, AsyncSnapshot<BeneficiariesModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            config.looded = true;
            return const DashBoard();
          } else {
            return SplashScreen();
          }
        },
      );
    }
  }
}

class DashBoard extends StatefulWidget {
  const DashBoard({Key key, this.long, this.lat}) : super(key: key);
  final double long;
  final double lat;
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  StreamSubscription<dynamic> getPositionSubscription;
  GoogleMapController mapController;
  Location location = Location();
  double lat;
  double long;
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    lat = widget.lat ?? 25.063054;
    long = widget.long ?? 55.170010;
    location.onLocationChanged.listen((LocationData currentLocation) {
      latTosend = currentLocation.latitude;
      longTosend = currentLocation.longitude;
      print(
          "hola hola lat ${currentLocation.latitude} hola hola long ${currentLocation.longitude}");
    });
    getIt<GlobalVars>().beneficiaries.data.forEach((Ben element) {
      if (element.latitude != null && element.longitude != null)
        _addMarker(element);
    });
  }

  Future<void> _addMarker(Ben element) async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/locationMarkerblue.png', 100);
    final Marker marker = Marker(
        markerId: MarkerId(element.id.toString()),
        position: LatLng(element.latitude, element.longitude),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: InfoWindow(
          title: element.name.toString(),
        ));

    final MarkerId markerId = MarkerId(element.id.toString());
    markers[markerId] = marker;
  }

  @override
  void dispose() {
    super.dispose();
    getPositionSubscription?.cancel();
  }

  Widget card(String picPath, String header, Widget widget) {
    return Container(
      width: 156,
      child: Card(
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SvgPicture.asset(
                  picPath,
                  width: 60.0,
                  height: 60.0,
                ),
                const SizedBox(height: 6),
                Text(header, style: styles.underHead),
                const SizedBox(height: 6),
                widget
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    // serviceEnabled = await location.serviceEnabled();
    // if (!serviceEnabled) {
    // } else {
    //   permissionGranted = await location.hasPermission();
    //   if (permissionGranted == PermissionStatus.denied) {
    //   } else {
    //     _animateToUser();
    //   }
    // }
    serviceEnabled = await location.serviceEnabled();
    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
    } else {
      if (!serviceEnabled) {
      } else {
        _animateToUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                title: Text(trans(context, "altariq"), style: styles.appBar),
                centerTitle: true),
            // drawer: GlobalDrawer(sourceContext: context),
            body: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    // padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text("agentName", style: styles.underHeadwhite),
                              ],
                            ),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(80.0),
                                child: CircleAvatar(
                                  maxRadius: 45,
                                  minRadius: 30,
                                  backgroundColor: colors.white,
                                  child: Image.asset('assets/images/logo.png',
                                      width: 80.0, height: 80.0),
                                ))
                          ],
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/Home", (_) => false);
                        },
                        title: Text(trans(context, "home"),
                            style: styles.globalDrawer),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/Beneficiaries",
                              (Route<dynamic> r) => r.isFirst);
                        },
                        title: Text(trans(context, "beneficiaries"),
                            style: styles.globalDrawer),
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () {
                          final double x = MediaQuery.of(context).size.width;
                          Navigator.pushNamedAndRemoveUntil(context,
                              "/Agent_Orders", (Route<dynamic> r) => r.isFirst,
                              arguments: <String, dynamic>{
                                "expand": true,
                                "width": x
                              });
                        },
                        title: Text(trans(context, "stock_transaction"),
                            style: styles.globalDrawer),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, "/items",
                              (Route<dynamic> r) => r.isFirst);
                        },
                        title: Text(trans(context, "items"),
                            style: styles.globalDrawer),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      Consumer<GlobalVars>(builder: (BuildContext context,
                          GlobalVars golbalValues, Widget child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            card(
                                'assets/images/remain_bin.svg',
                                trans(context, 'remain_transaction'),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: colors.orange)),
                                    child: Text(golbalValues.benRemaining,
                                        style: styles.redstyle))),
                            card(
                              'assets/images/order_transaction.svg',
                              trans(context, 'order_transaction'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: const Color(0xFF008585),
                                      )),
                                      child: Text(
                                          golbalValues.orderscount ?? "",
                                          style: styles.greenstyle)),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: const Color(0xFF008585),
                                      )),
                                      child: Text(golbalValues.orderTotal,
                                          style: styles.greenstyle))
                                ],
                              ),
                            ),
                            card(
                              'assets/images/return_transaction.svg',
                              trans(context, 'return_transaction'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: colors.purple,
                                      )),
                                      child: Text(golbalValues.returnscount,
                                          style: styles.purplestyle)),
                                  const SizedBox(width: 12),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                        color: colors.purple,
                                      )),
                                      child: Text(golbalValues.returnTotal,
                                          style: styles.purplestyle))
                                ],
                              ),
                            ),
                            card(
                                'assets/images/collection.svg',
                                trans(context, 'collection_transaction'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                          color: colors.blue,
                                        )),
                                        child: Text(
                                            golbalValues.collectionscount,
                                            style: styles.darkbluestyle)),
                                    const SizedBox(width: 12),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                          color: colors.blue,
                                        )),
                                        child: Text(
                                            golbalValues.collectionTotal,
                                            style: styles.darkbluestyle))
                                  ],
                                )),
                            card(
                                'assets/images/login_time.svg',
                                trans(context, 'time_since_login'),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: colors.green,
                                    )),
                                    child: Text(golbalValues.timeSinceLogin,
                                        style: styles.darkgreenstyle))),
                            // card(
                            //     'assets/images/last_trip_time.svg',
                            //     trans(context, 'time_since_last_trip'),
                            //     Container(
                            //         padding: const EdgeInsets.symmetric(
                            //             horizontal: 8),
                            //         decoration: BoxDecoration(
                            //             border: Border.all(
                            //           color: const Color(0xFF00158F),
                            //         )),
                            //         child: Text(golbalValues.timeSinceLastTrans,
                            //             style: styles.bluestyle))),
                          ],
                        );
                      }),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            GoogleMap(
                              onMapCreated: _onMapCreated,
                              mapType: MapType.normal,
                              markers: Set<Marker>.of(markers.values),
                              initialCameraPosition: CameraPosition(
                                target: LatLng(lat, long),
                                zoom: 13,
                              ),
                              onCameraMove: (CameraPosition pos) {
                                setState(() {
                                  lat = pos.target.latitude;
                                  long = pos.target.longitude;
                                });
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, bottom: 69),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: Material(
                                    color: colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(6),
                                      onTap: () {},
                                      child: GestureDetector(
                                        child: const Center(
                                          child: Icon(
                                            Icons.my_location,
                                            color: Color.fromARGB(
                                                1023, 150, 150, 150),
                                          ),
                                        ),
                                        onTap: () async {
                                          serviceEnabled =
                                              await location.serviceEnabled();
                                          if (!serviceEnabled) {
                                            serviceEnabled =
                                                await location.requestService();
                                            if (!serviceEnabled) {
                                            } else {
                                              permissionGranted = await location
                                                  .hasPermission();
                                              if (permissionGranted ==
                                                  PermissionStatus.denied) {
                                                permissionGranted =
                                                    await location
                                                        .requestPermission();
                                                if (permissionGranted ==
                                                    PermissionStatus.granted) {
                                                  _animateToUser();
                                                }
                                              } else {
                                                _animateToUser();
                                              }
                                            }
                                          } else {
                                            permissionGranted =
                                                await location.hasPermission();
                                            if (permissionGranted ==
                                                PermissionStatus.denied) {
                                              permissionGranted = await location
                                                  .requestPermission();
                                              if (permissionGranted ==
                                                  PermissionStatus.granted) {
                                                _animateToUser();
                                              }
                                            } else {
                                              _animateToUser();
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    final FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<void> _animateToUser() async {
    try {
      await location.getLocation().then((LocationData value) {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 13,
        )));
        setState(() {
          lat = value.latitude;
          long = value.longitude;
        });
      });
    } catch (e) {
      return;
    }
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.black,
      extendBody: true,
      body: Stack(
        children: const <Widget>[
          FlareActor("assets/images/LiquidDownloaddemo.flr",
              alignment: Alignment.center,
              fit: BoxFit.cover,
              animation: "Demo"),
        ],
      ),
    );
  }
}
