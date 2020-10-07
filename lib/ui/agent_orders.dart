import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/config.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/models/transactions.dart';
import 'package:agent_second/providers/export.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:animated_card/animated_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:agent_second/widgets/orderListCell.dart';

class AgentOrders extends StatefulWidget {
  const AgentOrders({Key key, this.expand, this.width}) : super(key: key);
  final bool expand;
  final double width;
  @override
  _AgentOrdersState createState() => _AgentOrdersState();
}

class _AgentOrdersState extends State<AgentOrders>
    with SingleTickerProviderStateMixin {
  AnimationController expandController;
  Animation<double> animation;
  @override
  void initState() {
    super.initState();
    getIt<TransactionProvider>().pagewiseAgentOrderController =
        PagewiseLoadController<dynamic>(
            pageSize: 15,
            pageFuture: (int pageIndex) async {
              return getIt<TransactionProvider>()
                  .getAgentOrderTransactions(pageIndex, config.agentId);
            });
    container1width = widget.width;
    container2width = 0;
  }

  List<MiniItems> items;
  Transaction transaction;
  bool billIsOn = false;
  int orderTransColorIndecator = 0;
  double container1width;
  double container2width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.blue,
        title: Text(trans(context, "stock_transaction")),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(billIsOn ? Icons.last_page : Icons.code),
              onPressed: () {
                setState(() {
                  if (items != null) {
                    if (billIsOn) {
                      container1width = MediaQuery.of(context).size.width;
                      container2width = 0;
                      billIsOn = false;
                    } else {
                      container1width = MediaQuery.of(context).size.width / 2;
                      container2width = MediaQuery.of(context).size.width / 2;
                      billIsOn = true;
                    }
                  }
                });
              })
        ],
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            alignment: Alignment.topCenter,
            width: container1width,
            child: PagewiseListView<dynamic>(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                pageLoadController:
                    getIt<TransactionProvider>().pagewiseAgentOrderController,
                itemBuilder: (BuildContext context, dynamic obj, int index) {
                  return AnimatedCard(
                    direction: AnimatedCardDirection.left,
                    initDelay: const Duration(milliseconds: 0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.ease,
                    child: agentTransactionBuilder(
                        context, obj as Transaction, index),
                  );
                }),
          ),
          if (billIsOn) bill(items) else Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            getIt<OrderListProvider>().clearOrcerList();
            Navigator.pushNamed(context, "/Order_Screen",
                arguments: <String, dynamic>{
                  "isORderOrReturn": false,
                  "isAgentOrder": true
                });
          }),
    );
  }

  Widget agentTransactionBuilder(
      BuildContext context, Transaction entry, int index) {
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
                      "isORderOrReturn": false,
                      "isAgentOrder": true
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
                      "ben":null,
                      "isORderOrReturn": false,
                      "isAgentOrder": true
                    });
              },
            ),
          if (entry.status == 'draft')
            IconSlideAction(
              caption: 'Delete',
              color: colors.red,
              icon: Icons.delete,
              onTap: () {
                // TODO(Mohammad): dio dlete request
              },
            )
        ],
        child: FlatButton(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: index % 2 == 0 ? Colors.blue[100] : Colors.transparent,
          onPressed: () {
            setState(() {
              container1width = MediaQuery.of(context).size.width / 2;
              container2width = MediaQuery.of(context).size.width / 2;
              billIsOn = true;
              items = entry.details;

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
        ));
  }

  Widget bill(List<MiniItems> items) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: container2width,
      child: Column(
        children: <Widget>[
           OrderListCell(items:items)
          // Expanded(
          //   child: SingleChildScrollView(
          //       scrollDirection: Axis.vertical,
          //       child: DataTable(
          //         columns: <DataColumn>[
          //           DataColumn(
          //             label: Text(trans(context, '#'),
          //                 style: const TextStyle(fontStyle: FontStyle.italic)),
          //           ),
          //           DataColumn(
          //             label: Text(trans(context, 'product_name'),
          //                 style: const TextStyle(fontStyle: FontStyle.italic)),
          //           ),
          //           DataColumn(
          //             label: Text(trans(context, 'quantity'),
          //                 style: const TextStyle(fontStyle: FontStyle.italic)),
          //           ),
          //           DataColumn(
          //             label: Text(trans(context, 'unit'),
          //                 style: const TextStyle(fontStyle: FontStyle.italic)),
          //           ),
          //           DataColumn(
          //             label: Text(trans(context, 'unit_price'),
          //                 style: const TextStyle(fontStyle: FontStyle.italic)),
          //           ),
          //           DataColumn(
          //             label: Text(trans(context, 'total'),
          //                 style: const TextStyle(fontStyle: FontStyle.italic)),
          //           ),
          //         ],
          //         rows: items.map((MiniItems e) {
          //           return DataRow(cells: <DataCell>[
          //             DataCell(Text(e.id.toString())),
          //             DataCell(Text(e.item)),
          //             DataCell(Text(e.quantity.toString())),
          //             DataCell(Text(e.unit.toString())),
          //             DataCell(Text(e.itemPrice.toString())),
          //             DataCell(
          //                 Text((e.itemPrice * e.quantity).toString()))
          //           ]);
          //         }).toList(),
          //       )),
          // ),
        ],
      ),
    );
  }
}
