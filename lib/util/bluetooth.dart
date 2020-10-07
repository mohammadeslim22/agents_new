import 'dart:io';
import 'dart:typed_data';
import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/config.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/models/transactions.dart';
import 'package:agent_second/providers/auth.dart';
import 'package:agent_second/providers/global_variables.dart';
import 'package:agent_second/providers/transaction_provider.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Bluetooth extends StatefulWidget {
  const Bluetooth({Key key, this.transaction}) : super(key: key);

  final Transaction transaction;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Bluetooth> {
  List<BluetoothDevice> _devices = <BluetoothDevice>[];
  // BluetoothDevice _device;
  // bool _connected = false;
  String pathImage;
  Transaction transaction;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    transaction = widget.transaction;
  }

  Future<void> initPlatformState() async {
    final bool isConnected = await getIt<Auth>().bluetooth.isConnected;
    List<BluetoothDevice> devices = <BluetoothDevice>[];
    try {
      devices = await getIt<Auth>().bluetooth.getBondedDevices();
    } on PlatformException {
      print("exception happened");
    }

    getIt<Auth>().bluetooth.onStateChanged().listen((int state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            getIt<Auth>().connected = true;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            getIt<Auth>().connected = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) {
      return;
    }

    setState(() {
      _devices = devices;
    });

    if (isConnected) {
      setState(() {
        getIt<Auth>().connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          trans(context, 'invoice_printing'),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10),
                  const Text(
                    'Device:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: DropdownButton<dynamic>(
                      items: _getDeviceItems(),
                      onChanged: (dynamic value) => setState(() =>
                          getIt<Auth>().device = value as BluetoothDevice),
                      value: getIt<Auth>().device,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.brown,
                    onPressed: () {
                      initPlatformState();
                    },
                    child: Text(
                      'Refresh',
                      style: TextStyle(color: colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  RaisedButton(
                    color: getIt<Auth>().connected ? colors.red : colors.green,
                    onPressed: getIt<Auth>().connected ? _disconnect : _connect,
                    child: Text(
                      getIt<Auth>().connected ? 'Disconnect' : 'Connect',
                      style: TextStyle(color: colors.white),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                child: RaisedButton(
                  color: colors.blue,
                  onPressed: () async {
                    if (getIt<TransactionProvider>()
                            .printingOrdersDataArrived &&
                        getIt<TransactionProvider>()
                            .printingReturnsDataArrived) {
                      printTodayTransactions(
                          getIt<TransactionProvider>().ordersToPrint,
                          getIt<TransactionProvider>().returnsToPrint);
                    } else {
                      await getIt<TransactionProvider>()
                          .getTransactionsToPrint(transaction.beneficiaryId);
                      Fluttertoast.showToast(msg: "Failed to get data");
                    }
                  },
                  child: Text(trans(context, 'print_today_invoices'),
                      style: TextStyle(color: colors.white)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                child: RaisedButton(
                  color: colors.green,
                  onPressed: () {
                    _tesPrint(transaction);
                  },
                  child: Text(trans(context, 'print_invoice'),
                      style: TextStyle(color: colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    final List<DropdownMenuItem<BluetoothDevice>> items =
        <DropdownMenuItem<BluetoothDevice>>[];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem<BluetoothDevice>(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((BluetoothDevice device) {
        items.add(DropdownMenuItem<BluetoothDevice>(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (getIt<Auth>().device == null) {
      show('No device selected.');
    } else {
      getIt<Auth>().bluetooth.isConnected.then((bool isConnected) {
        if (!isConnected) {
          getIt<Auth>()
              .bluetooth
              .connect(getIt<Auth>().device)
              .catchError((dynamic error) {
            setState(() => getIt<Auth>().connected = false);
          });
          setState(() => getIt<Auth>().connected = true);
        }
      });
    }
  }

  void _disconnect() {
    getIt<Auth>().bluetooth.disconnect();
    setState(() => getIt<Auth>().connected = true);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final ByteBuffer buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<void> show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  Future<void> _tesPrint(Transaction transaction) async {
    getIt<Auth>().bluetooth.isConnected.then((bool isConnected) {
       double taxMony = 0.0;
      if (isConnected) {
        getIt<Auth>().bluetooth.printImage("asstes/images/logo_trans.svg");
        getIt<Auth>().bluetooth.printCustom("AL SAHARI BAKERY", 1, 1);

        getIt<Auth>()
            .bluetooth
            .printCustom("MD BIN SALEM STREET RAK.UAE ", 1, 1);
        getIt<Auth>()
            .bluetooth
            .printCustom("Tel:072226355 ,Mob: 0544117087", 1, 1);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom("TRN : ${config.trn}", 1, 1);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printLeftRight(
            "TAX INVOICE  ${transaction.agent.substring(0, 2)}  / #${transaction.id}",
            "",
            0);
        // getIt<Auth>().bluetooth.printCustom("Invoice Type\nCredit", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>()
            .bluetooth
            .printCustom("CUST : ${transaction.beneficiary}", 1, 0);
        getIt<Auth>().bluetooth.printCustom(
            "CUST TRN : ${getIt<GlobalVars>().getbenInFocus().trn ?? "N/A"}",
            1,
            0);
        getIt<Auth>()
            .bluetooth
            .printCustom("Date : ${transaction.transDate}", 1, 0);
        getIt<Auth>()
            .bluetooth
            .printCustom("Place : ${transaction.address}", 1, 0);
        getIt<Auth>().bluetooth.printNewLine();

        getIt<Auth>()
            .bluetooth
            .printCustom("SLNO  PRODUCT NAME           OYT  RATE  TOTAL", 1, 1);
        for (int i = 0; i < transaction.details.length; i++) {
          String itemName = transaction.details[i].item;
          for (int u = itemName.length; u < 24; u++) {
            itemName = itemName + " ";
          }
          getIt<Auth>().bluetooth.printCustom(
              "$i  $itemName    ${transaction.details[i].quantity}    ${transaction.details[i].itemPrice}   ${transaction.details[i].total.toStringAsFixed(2)}",
              1,
              0);
            
        }
        final double taxMony =  transaction.amount/(1+config.tax / 100 );
        final double totalBeforTax =
            transaction.amount - config.tax / 100 * transaction.amount;

        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom("DISCOUNT 0.0", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom("SUB TOTAL $totalBeforTax", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>()
            .bluetooth
            .printCustom("VAT AMOUNT ${taxMony.toStringAsFixed(2)}", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>()
            .bluetooth
            .printCustom("NET TOTAL  ${transaction.amount.toStringAsFixed(2)}", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printLeftRight("Salesman:${transaction.agent}",
            "     Car No:${config.verchilId}", 0);
        getIt<Auth>().bluetooth.printLeftRight("SIGNATURE", "", 0);

        getIt<Auth>().bluetooth.paperCut();
      } else {
        print("iam not connected ");
      }
    });
  }

  Future<void> printTodayTransactions(List<Transaction> orderTransactions,
      List<Transaction> returnTransactions) async {
    double orderAmount = 0.0;
    double returnAmount = 0.0;
    double taxMony = 0.0;
    // orderTransactions.forEach((Transaction element) {
    //   taxMony += element.tax;

    //   for (int i = 0; i < element.details.length; i++) {
    //     String itemName = element.details[i].item;
    //     for (int u = itemName.length; u < 21; u++) {
    //       itemName = itemName + " ";
    //     }
    //     print(itemName);
    //     print(
    //         "$i  ${element.details[i].item}  ${element.details[i].quantity}   ${element.details[i].itemPrice}   ${element.details[i].total}");
    //   }
    //   orderAmount += element.amount;
    //   print("new line");
    // });
    // print("RETURN");
    // returnTransactions.forEach((Transaction element) {
    //   for (int i = 0; i < element.details.length; i++) {
    //     print(
    //         "$i  ${element.details[i].item}  ${element.details[i].quantity}   ${element.details[i].itemPrice}   ${element.details[i].total}");
    //   }
    //   returnAmount += element.amount;
    //   print("new line");
    // });
    // print("config.tax: ${config.tax}");
    // // final double taxMony = (config.tax / 100) * orderAmount;
    // final double totalfterReturn = orderAmount - returnAmount;
    // print(
    //     "tax money ${taxMony.toStringAsFixed(2)}  total: ${totalfterReturn.toStringAsFixed(2)}");
    getIt<Auth>().bluetooth.isConnected.then((bool isConnected) {
      if (isConnected) {
        getIt<Auth>().bluetooth.printCustom("AL SAHARI BAKERY", 1, 1);

        getIt<Auth>()
            .bluetooth
            .printCustom("MD BIN SALEM STREET RAK.UAE ", 1, 1);
        getIt<Auth>()
            .bluetooth
            .printCustom("Tel: 072226355 ,Mob: 0544117087", 1, 1);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom("TRN : ${config.trn}", 1, 1);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printLeftRight(
            "TAX INVOICE  ${transaction.agent.substring(0, 2)}  / #${transaction.id}",
            "",
            0);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>()
            .bluetooth
            .printCustom("CUST : ${transaction.beneficiary}", 1, 0);
        final String custTRN =
            (getIt<GlobalVars>().getbenInFocus().trn) != "null"
                ? getIt<GlobalVars>().getbenInFocus().trn
                : "N/A";
        getIt<Auth>().bluetooth.printCustom("CUST TRN : $custTRN", 1, 0);
        getIt<Auth>()
            .bluetooth
            .printCustom("Date : ${transaction.transDate}", 1, 0);
        getIt<Auth>()
            .bluetooth
            .printCustom("Place : ${transaction.address}", 1, 0);
        getIt<Auth>().bluetooth.printNewLine();

        getIt<Auth>()
            .bluetooth
            .printCustom("SLNO  PRODUCT NAME          OYT  RATE  TOTAL", 1, 0);

        // getIt<Auth>().bluetooth.printCustom("OYT  RATE  TOTAL", 1, 2);

        orderTransactions.forEach((Transaction element) {
          taxMony += element.tax;

          for (int i = 0; i < element.details.length; i++) {
            String itemName = element.details[i].item;
            for (int u = itemName.length; u < 24; u++) {
              itemName = itemName + " ";
            }
            getIt<Auth>().bluetooth.printCustom(
                "$i  $itemName  ${element.details[i].quantity}    ${element.details[i].itemPrice}   ${element.details[i].total.toStringAsFixed(2)}",
                1,
                0);

            // getIt<Auth>().bluetooth.printCustom(
            //     "${element.details[i].quantity}   ${element.details[i].itemPrice}   ${element.details[i].total}",
            //     1,
            //     2);
            // getIt<Auth>()
            // .bluetooth.printLeftRight(string1, string2, size)
          }
          orderAmount += element.amount;
          getIt<Auth>().bluetooth.printNewLine();
        });
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom("RETURN", 1, 1);
        getIt<Auth>().bluetooth.printNewLine();
        returnTransactions.forEach((Transaction element) {
           taxMony += element.tax;
          for (int i = 0; i < element.details.length; i++) {
            String itemName = element.details[i].item;
            for (int u = itemName.length; u < 24; u++) {
              itemName = itemName + " ";
            }
            getIt<Auth>().bluetooth.printCustom(
                "$i  $itemName  ${element.details[i].quantity}    ${element.details[i].itemPrice}   ${element.details[i].total.toStringAsFixed(2)}",
                1,
                0);
            // getIt<Auth>().bluetooth.printCustom(
            //     "${element.details[i].quantity}   ${element.details[i].itemPrice}   ${element.details[i].total}",
            //     1,
            //     2);
          }
          returnAmount += element.amount;
          getIt<Auth>().bluetooth.printNewLine();
        });
        // final double taxMony = (config.tax / 100) * orderAmount;
        final double totalfterReturn = orderAmount - returnAmount;

        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom("DISCOUNT: 0.0", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom(
            "ORDER with Tax: ${orderAmount.toStringAsFixed(2)}", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom(
            "RETURN with Tax: ${returnAmount.toStringAsFixed(2)}", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>()
            .bluetooth
            .printCustom("VAT AMOUNT: ${taxMony.toStringAsFixed(2)}", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printCustom(
            "NET TOTAL:  ${totalfterReturn.toStringAsFixed(2)}", 1, 2);
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printNewLine();
        getIt<Auth>().bluetooth.printLeftRight("Salesman:${transaction.agent}",
            "    Car No:${config.verchilId}", 0);
        getIt<Auth>().bluetooth.printLeftRight("SIGNATURE", "", 0);
        getIt<Auth>().bluetooth.paperCut();
      } else {
        print("iam not connected ");
      }
    });
  }
}
