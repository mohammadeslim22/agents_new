import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/models/Items.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:agent_second/widgets/text_form_input.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agent_second/providers/order_provider.dart';

class ShowItems extends StatefulWidget {
  const ShowItems({Key key}) : super(key: key);
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<ShowItems> {
  int indexedStackId = 0;
  int colorIndex;
  double animatedHight = 0;

  final TextEditingController searchController = TextEditingController();
  Map<String, String> itemsBalances = <String, String>{};
  List<int> prices = <int>[];

  Widget childForDragging(Balance item) {
    if (item.id % 2 == 0) {
      colorIndex++;
    }
    return Card(
      shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Colors.green),
          borderRadius: BorderRadius.circular(8.0)),
      color: colorIndex % 2 == 1 ? colors.white : colors.grey,
      child: InkWell(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const SizedBox(width: 80),
          Text(item.name, style: styles.bluestyle, textAlign: TextAlign.start),
          const Spacer(),
          Text(item.balance.toString(),
              style: styles.bluestyle, textAlign: TextAlign.start),
          const SizedBox(width: 40)
        ],
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    colorIndex = 0;
    if (getIt<OrderListProvider>().itemsBalanceDataLoaded) {
    } else {
      getIt<OrderListProvider>().indexedStackBalance = 0;
      getIt<OrderListProvider>().getItemsBalances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: colors.blue,
        title: Text(trans(context, "items")),
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, size: 32),
            onPressed: () {
              getIt<OrderListProvider>().getItemsBalances();
            },
          ),
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 2, right: 6, left: 6),
                width: 300,
                child: TextFormInput(
                  text: trans(context, 'type'),
                  cController: searchController,
                  prefixIcon: Icons.search,
                  kt: TextInputType.emailAddress,
                  obscureText: false,
                  readOnly: false,
                  onTab: () {},
                  onFieldChanged: (String st) {
                    setState(() {});
                  },
                  onFieldSubmitted: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: Consumer<OrderListProvider>(
              builder: (BuildContext context, OrderListProvider orderProvider,
                  Widget child) {
                return Container(
                  child: IndexedStack(
                      index: orderProvider.indexedStackBalance,
                      children: <Widget>[
                        Container(
                          child: FlareActor("assets/images/analysis_new.flr",
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              isPaused: orderProvider.itemsBalanceDataLoaded,
                              animation: "analysis"),
                        ),
                        if (orderProvider.itemsBalanceDataLoaded)
                          GridView.count(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              primary: true,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                              crossAxisCount: 2,
                              childAspectRatio: 10,
                              addRepaintBoundaries: true,
                              children: orderProvider.itemsBalances
                                  .where((Balance element) {
                                return element.name
                                    .trim()
                                    .toLowerCase()
                                    .contains(searchController.text
                                        .trim()
                                        .toLowerCase());
                              }).map((Balance item) {
                                return childForDragging(item);
                              }).toList()),
                        // ListView.builder(
                        //     shrinkWrap: true,
                        //     itemCount: orderProvider.itemsList.length - 1,
                        //     itemBuilder: (BuildContext ctxt, int index) {
                        //       if (index == 0) {

                        //        if (orderProvider.itemsList[index].name
                        //             .trim()
                        //             .toLowerCase()
                        //             .contains(searchController.text
                        //                 .trim()
                        //                 .toLowerCase())) {
                        //           return childForDragging(
                        //               orderProvider.itemsList[index]);
                        //         } else {
                        //           return Container();
                        //         }
                        //       } else if (index % 2 == 0   ) {
                        //         if (orderProvider.itemsList[index].name
                        //             .trim()
                        //             .toLowerCase()
                        //             .contains(searchController.text
                        //                 .trim()
                        //                 .toLowerCase()))
                        //           return Row(
                        //             children: <Widget>[
                        //               Expanded(
                        //                 child: childForDragging(
                        //                     orderProvider.itemsList[index]),
                        //               ),
                        //               // const SizedBox(width: 200),
                        //               Expanded(
                        //                 child: childForDragging(orderProvider
                        //                     .itemsList[index + 1]),
                        //               ),
                        //             ],
                        //           );
                        //         else
                        //           return Container();
                        //       } else {
                        //         // if (orderProvider.itemsList[index].name
                        //         //     .trim()
                        //         //     .toLowerCase()
                        //         //     .contains(searchController.text
                        //         //         .trim()
                        //         //         .toLowerCase()))
                        //         //   return Row(
                        //         //     children: <Widget>[
                        //         //       Expanded(
                        //         //         child: childForDragging(
                        //         //             orderProvider.itemsList[index]),
                        //         //       ),
                        //         //       // const SizedBox(width: 200),
                        //         //       Expanded(
                        //         //         child: childForDragging(orderProvider
                        //         //             .itemsList[index + 1]),
                        //         //       ),
                        //         //     ],
                        //         //   );
                        //         // else
                        //           return Container();
                        //       }
                        //     })
                        // else
                        //   Container()
                      ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
