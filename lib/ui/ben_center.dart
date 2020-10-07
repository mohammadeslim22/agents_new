import 'dart:async';
import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/models/ben.dart';
import 'package:agent_second/models/collection.dart';
import 'package:agent_second/models/finanical_records.dart';
import 'package:agent_second/models/transactions.dart';
import 'package:agent_second/providers/export.dart';
import 'package:agent_second/providers/transaction_provider.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:animated_card/animated_card.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:agent_second/widgets/orderListCell.dart';

class BeneficiaryCenter extends StatefulWidget {
  const BeneficiaryCenter({Key key, this.long, this.lat, this.ben})
      : super(key: key);
  final double long;
  final double lat;
  final Ben ben;
  @override
  _BeneficiaryCenterState createState() => _BeneficiaryCenterState();
}

class _BeneficiaryCenterState extends State<BeneficiaryCenter> {
  Ben ben;
  List<MiniItems> items;
  Transaction transaction;
  bool billIsOn = true;
  Collections collection;
  int indexedStack;
  Widget noItemFound;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
    } else {
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
      } else {
        _animateToUser();
      }
    }
  }

  Future<void> _animateToUser() async {
    try {
      if (mounted) {
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
      }
    } catch (e) {
      return;
    }
  }

  StreamSubscription<dynamic> getPositionSubscription;
  GoogleMapController mapController;
  Location location = Location();
  double lat;
  double long;
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  @override
  void initState() {
    super.initState();
    lat = widget.lat ?? 25.063054;
    long = widget.long ?? 55.170010;
    ben = widget.ben;
    billIsOn = true;
    indexedStack = 0;
    noItemFound = Container(
      width: 300,
      height: 250,
      child: const FlareActor("assets/images/empty.flr",
          alignment: Alignment.center, fit: BoxFit.fill, animation: "default"),
    );
    getIt<TransactionProvider>().pagewiseCollectionController =
        PagewiseLoadController<dynamic>(
            pageSize: 15,
            pageFuture: (int pageIndex) async {
              return getIt<TransactionProvider>()
                  .getCollectionTransactions(pageIndex, ben.id);
            });
    getIt<TransactionProvider>().pagewiseOrderController =
        PagewiseLoadController<dynamic>(
            pageSize: 15,
            pageFuture: (int pageIndex) async {
              return getIt<TransactionProvider>()
                  .getOrdersTransactions(pageIndex, ben.id);
            });
    getIt<TransactionProvider>().pagewiseReturnController =
        PagewiseLoadController<dynamic>(
            pageSize: 15,
            pageFuture: (int pageIndex) async {
              return getIt<TransactionProvider>()
                  .getReturnTransactions(pageIndex, ben.id);
            });
  }

  @override
  void dispose() {
    super.dispose();
    getPositionSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Consumer<GlobalVars>(
              builder: (BuildContext context, GlobalVars value, Widget child) {
                return Row(
                  children: <Widget>[
                    Text(trans(context, 'total_between_order_return') + "  ",
                        style: styles.littleangrywhitestyle),
                    Text((double.parse(ben.balance)).toString(),
                        style: styles.angrywhitestyle),
                    const SizedBox(width: 24),
                    Text(trans(context, 'total_orders_confirmed') + "  ",
                        style: styles.littleangrywhitestyle),
                    Text(ben.totalOrders.toStringAsFixed(2),
                        style: styles.angrywhitestyle),
                    const SizedBox(width: 24),
                    Text(trans(context, 'total_return_confirmed') + "  ",
                        style: styles.littleangrywhitestyle),
                    Text(ben.totalReturns.toStringAsFixed(2),
                        style: styles.angrywhitestyle),
                  ],
                );
              },
            ),
            Text(trans(context, "ben_center"), style: styles.appBar),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.person_outline,
                                  color: colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(ben.name, style: styles.beneficiresNmae)
                            ],
                          ),
                          const SizedBox(width: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.location_on,
                                  color: colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(ben.address, style: styles.underHeadgray)
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 64),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.call, color: colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                trans(context, "mobile_number") +
                                    " : ${ben.phone}",
                                style: styles.beneficiresNmae,
                              )
                            ],
                          ),
                          const SizedBox(width: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.email, color: colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                ben.email,
                                style: styles.underHeadgray,
                              )
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.my_location,
                            color: colors.blue, size: 24),
                        onPressed: () {
                          location.getLocation().then((LocationData value) {
                            print(value);
                            getIt<GlobalVars>().updateBenLocation(
                                ben.id, value.latitude, value.longitude);
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 110,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            color: colors.blue,
                            onPressed: () {
                              getIt<OrderListProvider>().clearOrcerList();
                              Navigator.pushNamed(context, "/Order_Screen",
                                  arguments: <String, dynamic>{
                                    "ben": ben,
                                    "isORderOrReturn": true,
                                    "isAgentOrder": false
                                  });
                            },
                            child: Text(trans(context, "order"),
                                style: styles.mywhitestyle),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 110,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            color: colors.red,
                            onPressed: () {
                              getIt<OrderListProvider>().clearOrcerList();
                              Navigator.pushNamed(context, "/Order_Screen",
                                  arguments: <String, dynamic>{
                                    "ben": ben,
                                    "isORderOrReturn": false,
                                    "isAgentOrder": false
                                  });
                            },
                            child: Text(trans(context, "return"),
                                style: styles.mywhitestyle),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 110,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            color: colors.green,
                            onPressed: () {
                              getIt<OrderListProvider>().setScreensToPop(2);
                              Navigator.pushNamed(context, "/Payment_Screen",
                                  arguments: <String, dynamic>{
                                    "orderTotal": ben.totalOrders,
                                    "returnTotal": ben.totalReturns,
                                    "cashTotal": double.parse(ben.balance),
                                  });
                            },
                            child: Text(trans(context, "collection"),
                                style: styles.mywhitestyle),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(trans(context, "show_chices"),
                          style: styles.mystyle),
                      Container(
                        width: 50,
                        height: 35,
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: indexedStack == 0
                                    ? colors.green
                                    : colors.trans),
                            color: indexedStack == 0
                                ? Colors.green[100]
                                : Colors.transparent),
                        child: FlatButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                indexedStack = 0;
                              });
                            },
                            child:
                                SvgPicture.asset("assets/images/invoice.svg")),
                      ),
                      Container(
                        width: 50,
                        height: 35,
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: indexedStack == 1
                                    ? colors.red
                                    : colors.trans),
                            color: indexedStack == 1
                                ? Colors.red[100]
                                : Colors.transparent),
                        child: FlatButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                indexedStack = 1;
                              });
                            },
                            child: SvgPicture.asset(
                                "assets/images/return_icon.svg")),
                      ),
                      Container(
                        width: 50,
                        height: 35,
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: indexedStack == 2
                                    ? colors.yellow
                                    : colors.trans),
                            color: indexedStack == 2
                                ? Colors.yellow[100]
                                : Colors.transparent),
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              indexedStack = 2;
                            });
                          },
                          child: SvgPicture.asset(
                              "assets/images/collection_icon.svg",
                              width: 40),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.blue[400]),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 4, 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                                child: Text(trans(context, "#"),
                                    style: styles.mystyle,
                                    textAlign: TextAlign.start)),
                            Expanded(
                              flex: 2,
                              child: Text(trans(context, "agent"),
                                  style: styles.mystyle,
                                  textAlign: TextAlign.start),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text(trans(context, "date"),
                                    style: styles.mystyle,
                                    textAlign: TextAlign.center)),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                            Expanded(
                                child: Text(trans(context, "total"),
                                    style: styles.mystyle,
                                    textAlign: TextAlign.end))
                          ],
                        ),
                      )),
                  Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      header: WaterDropHeader(
                          complete: Container(), waterDropColor: colors.blue),
                      controller: _refreshController,
                      onRefresh: () async {
                        if (mounted) {
                          if (indexedStack == 0) {
                            getIt<TransactionProvider>()
                                .pagewiseOrderController
                                .reset();
                          } else if (indexedStack == 1) {
                            getIt<TransactionProvider>()
                                .pagewiseReturnController
                                .reset();
                          } else {
                            getIt<TransactionProvider>()
                                .pagewiseCollectionController
                                .reset();
                          }
                          _refreshController.refreshCompleted();
                        }
                      },
                      onLoading: () async {
                        await Future<void>.delayed(
                            const Duration(milliseconds: 1000));
                        if (mounted) {
                          setState(() {});
                          _refreshController.loadComplete();
                        }
                      },
                      child: IndexedStack(
                        index: indexedStack,
                        children: <Widget>[
                          PagewiseListView<dynamic>(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            pageLoadController: getIt<TransactionProvider>()
                                .pagewiseOrderController,
                            loadingBuilder: (BuildContext context) {
                              return loadTransactions();
                            },
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            itemBuilder: (BuildContext context, dynamic entry,
                                int index) {
                              getIt<TransactionProvider>().incrementOrders();
                              return AnimatedCard(
                                direction: AnimatedCardDirection.left,
                                initDelay: const Duration(milliseconds: 0),
                                duration: const Duration(seconds: 1),
                                curve: Curves.ease,
                                child: _transactionBuilder(
                                    context, entry as Transaction),
                              );
                            },
                            noItemsFoundBuilder: (BuildContext context) {
                              return noItemFound;
                            },
                          ),
                          PagewiseListView<dynamic>(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            pageLoadController: getIt<TransactionProvider>()
                                .pagewiseReturnController,
                            loadingBuilder: (BuildContext context) {
                              return loadTransactions();
                            },
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            itemBuilder: (BuildContext context, dynamic entry,
                                int index) {
                              return AnimatedCard(
                                direction: AnimatedCardDirection.left,
                                initDelay: const Duration(milliseconds: 0),
                                duration: const Duration(seconds: 1),
                                curve: Curves.ease,
                                child: _transactionBuilder(
                                    context, entry as Transaction),
                              );
                            },
                            noItemsFoundBuilder: (BuildContext context) {
                              return noItemFound;
                            },
                          ),
                          PagewiseListView<dynamic>(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            loadingBuilder: (BuildContext context) {
                              return loadTransactions();
                            },
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                            itemBuilder: (BuildContext context, dynamic entry,
                                int index) {
                              return AnimatedCard(
                                direction: AnimatedCardDirection.left,
                                initDelay: const Duration(milliseconds: 0),
                                duration: const Duration(seconds: 1),
                                curve: Curves.ease,
                                child:
                                    collectionBuilder(entry as FinanicalRecord),
                              );
                            },
                            pageLoadController: getIt<TransactionProvider>()
                                .pagewiseCollectionController,
                            noItemsFoundBuilder: (BuildContext context) {
                              return noItemFound;
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (billIsOn)
              Expanded(
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      padding: const EdgeInsets.only(bottom: 6),
                      mapType: MapType.normal,
                      markers: Set<Marker>.of(markers.values),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat, long),
                        zoom: 11,
                      ),
                      onCameraMove: (CameraPosition pos) {},
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 69),
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
                                    color: Color.fromARGB(1023, 150, 150, 150),
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
                                      permissionGranted =
                                          await location.hasPermission();
                                      if (permissionGranted ==
                                          PermissionStatus.denied) {
                                        permissionGranted =
                                            await location.requestPermission();
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
                                      permissionGranted =
                                          await location.requestPermission();
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
              )
            else
              Expanded(child: bill(items)),
          ],
        ),
      ),
    );
  }

  Widget loadTransactions() {
    return Container(
      width: 400,
      height: 400,
      child: FlareActor("assets/images/new_intro.flr",
          alignment: Alignment.center,
          color: colors.blue,
          fit: BoxFit.fill,
          animation: "intro"),
    );
  }

  Widget _transactionBuilder(
    BuildContext context,
    Transaction entry,
  ) {
    return Slidable(
        actionPane: const SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Share',
            color: colors.blue,
            icon: Icons.share,
            onTap: () {},
          ),
          if (entry.status == 'draft')
            IconSlideAction(
              caption: 'Edit',
              color: colors.yellow,
              icon: Icons.edit,
              onTap: () {
                getIt<OrderListProvider>().setScreensToPop(2);

                getIt<OrderListProvider>().bringOrderToOrderScreen(entry);
                Navigator.pushNamed(context, "/Order_Screen",
                    arguments: <String, dynamic>{
                      "ben": ben,
                      "isORderOrReturn": entry.type == "order",
                      "transId": entry.type == "return" ? entry.id : null
                    });
              },
            )
          else
            IconSlideAction(
              caption: 'Reuse',
              color: colors.yellow,
              icon: Icons.refresh,
              onTap: () {
                getIt<OrderListProvider>().setScreensToPop(2);
                getIt<OrderListProvider>().bringOrderToOrderScreen(entry);
                Navigator.pushNamed(context, "/Order_Screen",
                    arguments: <String, dynamic>{
                      "ben": ben,
                      "isORderOrReturn": entry.type == "order",
                      "transId": entry.type == "return" ? entry.id : null
                    });
              },
            ),
          if (entry.status == 'draft')
            IconSlideAction(
              caption: 'Delete',
              color: colors.red,
              icon: Icons.delete,
              onTap: () {
                getIt<TransactionProvider>().deleteDradftTrans(entry.id);
              },
            )
          else
            IconSlideAction(
              caption: 'Return',
              color: colors.red,
              icon: Icons.keyboard_return,
              onTap: () {
                getIt<OrderListProvider>().setScreensToPop(2);
                getIt<OrderListProvider>().bringOrderToOrderScreen(entry);
                Navigator.pushNamed(context, "/Order_Screen",
                    arguments: <String, dynamic>{
                      "ben": ben,
                      "isORderOrReturn": entry.type == "return",
                      "transId": entry.type == "return" ? entry.id : null
                    });
              },
            ),
        ],
        child: Container(
          color: getIt<TransactionProvider>().orderTransColorIndecator % 2 == 0
              ? Colors.blue[100]
              : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: InkWell(
            onTap: () {
              setState(() {
                items = entry.details;
                billIsOn = false;
                transaction = entry;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Text(entry.id.toString(),
                        style: styles.mystyle, textAlign: TextAlign.start)),
                Expanded(
                    flex: 2, child: Text(entry.agent, style: styles.mystyle)),
                Expanded(
                    flex: 3,
                    child: Text(entry.transDate,
                        style: styles.mystyle, textAlign: TextAlign.center)),
                Expanded(
                  flex: 1,
                  child: (entry.status == 'draft')
                      ? const Icon(Icons.edit, color: Colors.amber)
                      : Container(),
                ),
                Expanded(
                    child: Text(entry.amount.toString(),
                        style: styles.mystyle, textAlign: TextAlign.end))
              ],
            ),
          ),
        ));
  }

  Widget collectionBuilder(FinanicalRecord collection) {
    return Slidable(
        actionPane: const SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Share',
            color: colors.blue,
            icon: Icons.share,
            onTap: () {
              sendMail(transaction);
            },
          ),
          IconSlideAction(
            caption: 'Delete',
            color: colors.red,
            icon: Icons.delete,
            onTap: () {},
          ),
        ],
        child: FlatButton(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: collection.id % 2 == 0 ? Colors.blue[100] : Colors.transparent,
          onPressed: () {},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: Text(collection.id.toString(),
                      style: styles.mystyle, textAlign: TextAlign.start)),
              Expanded(
                  flex: 2,
                  child: Text(collection.agent.name ?? "اسم المندوب هنا",
                      style: styles.mystyle)),
              Expanded(
                  flex: 2, child: Text(collection.date, style: styles.mystyle)),
              Expanded(
                  child: Text(collection.credit.toString(),
                      style: styles.mystyle, textAlign: TextAlign.end))
            ],
          ),
        ));
  }

  Widget bill(List<MiniItems> items) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(trans(context, "name"), style: styles.mybluestyle),
                      const SizedBox(height: 16),
                      Text(trans(context, "date"), style: styles.mybluestyle)
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(ben.name, style: styles.mystyle),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(transaction.transDate, style: styles.mystyle),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            if (!billIsOn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                width: 70,
                height: 50,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            billIsOn = !billIsOn;
                          });
                        },
                        child: const FlareActor("assets/images/maps.flr",
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            animation: "anim"),
                      ),
                    ),
                    Text(
                      trans(context, "back_to_map"),
                      style: TextStyle(color: colors.black, fontSize: 7),
                    )
                  ],
                ),
              )
            else
              Container(),
          ],
        ),
        OrderListCell(items: items),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: () async {
                if (transaction.status == "draft") {
                } else {
                  getIt<TransactionProvider>().getTransactionsToPrint(ben.id);
                  Navigator.pushNamed(context, "/Bluetooth",
                      arguments: <String, dynamic>{"transaction": transaction});
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(trans(context, "print"), style: styles.mybluestyle),
                  const Icon(Icons.print, size: 20)
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text(trans(context, "total"), style: styles.mybluestyle),
                const SizedBox(width: 12),
                Text(trans(context, transaction.amount.toString() + ".00"),
                    style: styles.mystyle),
                const SizedBox(width: 32),
              ],
            ),
          ],
        )
      ],
    );
  }

  Future<void> sendMail(Transaction t) async {
    final MailOptions mailOptions = MailOptions(
        subject: 'Transaction for ben ${ben.name}',
        recipients: <String>[ben.email],
        isHTML: true,
        body: t.toString());
    await FlutterMailer.send(mailOptions);
  }
}
