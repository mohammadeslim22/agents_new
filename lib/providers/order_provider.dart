import 'package:agent_second/models/ben.dart';
import 'package:agent_second/models/transactions.dart';
import 'package:agent_second/providers/export.dart';
import 'package:agent_second/util/dio.dart';
import 'package:agent_second/util/functions.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:agent_second/models/Items.dart';
import 'package:vibration/vibration.dart';

class OrderListProvider with ChangeNotifier {
  List<SingleItemForSend> ordersList = <SingleItemForSend>[];
  List<SingleItem> itemsList;
  List<Balance> itemsBalances;
  bool itemsDataLoaded = false;
  bool itemsBalanceDataLoaded = false;
  int indexedStack = 0;
  int indexedStackBalance = 0;
  Set<int> selectedOptions = <int>{};
  double sumTotal = 0;
  List<SingleItemForSend> get currentordersList => ordersList;
  ItemsCap dummyItemCap = ItemsCap(balanceCap: 99999999);
  SingleItem dummySiglItem = SingleItem(balanceInventory: 99999999);
  int howManyscreensToPop;
  List<int> transactionTopAyIds = <int>[];
  double progress = 0.0;
  String getUnitNme(int itemId, int unitId) {
    String name;
    name = itemsList
        .firstWhere((SingleItem element) {
          return element.id == itemId;
        })
        .units
        .firstWhere((Units element) {
          return element.id == unitId;
        })
        .name;
    return name;
  }

  // void changeProgress(double d) {
  //   progress = d;
  //   notifyListeners();
  // }
  // void addIdTOTransactionToPayIdsList(int id) {
  //   transactionTopAyIds.add(id);
  //   notifyListeners();
  // }

  void setScreensToPop(int x) {
    howManyscreensToPop = x;
    notifyListeners();
  }

  void addItemToList(int id, String name, String note, int queantity, int unit,
      String unitPrice, String image) {
    if (selectedOptions.contains(id)) {
    } else {
      ordersList.add(SingleItemForSend(
          id: id,
          name: name,
          notes: note,
          queantity: queantity,
          unit: getUnitNme(id, unit),
          unitId: unit,
          unitPrice: unitPrice,
          image: image));
      sumTotal += double.parse(unitPrice);
      notifyListeners();
    }
  }

  void clearOrcerList() {
    ordersList.clear();
    selectedOptions.clear();
    sumTotal = 0.0;
    notifyListeners();
  }

  void changeUnit(int itemId, String unit, int unitId) {
    ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    })
      ..unitId = unitId
      ..unit = unit;

    notifyListeners();
  }

  void incrementQuantity(int itemId) {
    final int quantity = ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    }).queantity;
//  if (checkValidation(itemId, quantity + 1)) {
    ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    }).queantity += 1;
    sumTotal += double.parse(ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    }).unitPrice);
    // } else {
    //   Vibration.vibrate(duration: 600);
    // }

    notifyListeners();
  }

  void incrementQuantityForAgentOrder(int itemId) {
    // final int quantity = ordersList.firstWhere((SingleItemForSend element) {
    //   return element.id == itemId;
    // }).queantity;
    // if (checkValidation(itemId, quantity + 1)) {

    ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    }).queantity += 1;
    sumTotal += double.parse(ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    }).unitPrice);

    // } else {
    //   Vibration.vibrate(duration: 600);
    // }

    notifyListeners();
  }

  void setQuantityForAgentOrder(int itemId, int quantity) {
    // TODO(MOhammad): check balance in the car
    // if (checkValidation(itemId, quantity)) {
    ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    }).queantity = quantity;
    getTotla();
    // } else {
    //   Vibration.vibrate(duration: 600);
    // }

    notifyListeners();
  }

  void setQuantity(int itemId, int quantity) {
    if (quantity > 0) {
      // if (checkValidation(itemId, quantity)) {
      ordersList.firstWhere((SingleItemForSend element) {
        return element.id == itemId;
      }).queantity = quantity;
      getTotla();
    } else {
      Vibration.vibrate(duration: 600);
    }

    notifyListeners();
  }

  void decrementQuantity(int itemId) {
    if (ordersList.firstWhere((SingleItemForSend element) {
          return element.id == itemId;
        }).queantity >
        1) {
      ordersList.firstWhere((SingleItemForSend element) {
        return element.id == itemId;
      }).queantity -= 1;

      sumTotal -=
          double.parse(ordersList.firstWhere((SingleItemForSend element) {
        return element.id == itemId;
      }).unitPrice);
    } else {
      Vibration.vibrate(duration: 600);
    }
    notifyListeners();
  }

  void removeItemFromList(int itemId) {
    ordersList.removeWhere((SingleItemForSend element) {
      return element.id == itemId;
    });
    selectedOptions.remove(itemId);
    getTotla();
    notifyListeners();
  }

  void modifyItemUnit(String unit, int itemId) {
    ordersList.firstWhere((SingleItemForSend element) {
      return element.id == itemId;
    }).unit = unit;
    notifyListeners();
  }

  double getTotla() {
    void sumtoTotal(double price) {
      sumTotal += price;
    }

    sumTotal = 0.0;
    // ignore: avoid_function_literals_in_foreach_calls
    ordersList.forEach((SingleItemForSend element) {
      sumtoTotal(double.parse(element.unitPrice) * element.queantity);
    });
    return sumTotal;
  }

  void picksForbringOrderToOrderScreen() {
    if (ordersList.isEmpty) {
    } else {
      ordersList.forEach((SingleItemForSend element) {
        element.image = itemsList.firstWhere((SingleItem e) {
          return e.id == element.id;
        }).image;
      });
    }
  }

  void bringOrderToOrderScreen(Transaction transaction) {
    clearOrcerList();
    sumTotal = transaction.amount.toDouble();

    transaction.details.forEach((MiniItems element) {
      print("mini element item ${element.item}");
      selectedOptions.add(element.itemId);
      ordersList.add(SingleItemForSend(
          id: element.itemId,
          name: element.item,
          queantity: element.quantity,
          unit: element.unit,
          unitPrice: element.itemPrice.toString()));
    });
    notifyListeners();
  }

  bool checkItemsBalancesBrforeLeaving() {
    for (int i = 0; i < ordersList.length; i++) {
      if (ordersList[i].queantity >
          itemsBalances.firstWhere((Balance e) {
            return e.id == ordersList[i].id;
          }, orElse: () {
            return Balance(id: 99999, balance: 0);
          }).balance) {
        return false;
      }
    }
    return true;
  }

  Future<bool> sendCollection(
      BuildContext c, int benId, int amount, String status) async {
    final Response<dynamic> response =
        await dio.post<dynamic>("collection", data: <String, dynamic>{
      "beneficiary_id": benId,
      "amount": amount,
      "status": status,
    });
    if (response.statusCode == 200) {
      setDayLog(response, benId);
      if (getIt<TransactionProvider>().pagewiseCollectionController != null)
        getIt<TransactionProvider>().pagewiseCollectionController.reset();
      Navigator.of(c).pushNamedAndRemoveUntil("/Beneficiary_Center",
          (Route<dynamic> route) {
        return howManyscreensToPop-- == 0;
      }, arguments: <String, dynamic>{
        "ben": getIt<GlobalVars>().getbenInFocus()
      });
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOrder(int benId, double ammoutn, int shortage, String type,
      String status, int fromTransactionId) async {
    final List<int> itemsId = <int>[];
    final List<int> itemsQuantity = <int>[];
    final List<double> itemsPrice = <double>[];
    final List<int> itemsUnit = <int>[];
    final List<String> itemsNote = <String>[];
    for (int i = 0; i < ordersList.length; i++) {
      itemsId.add(ordersList[i].id);
      itemsQuantity.add(ordersList[i].queantity);
      itemsPrice.add(double.parse(ordersList[i].unitPrice));
      itemsUnit.add(ordersList[i].unitId);
      itemsNote.add(ordersList[i].notes);
    }

    final Response<dynamic> response = await dio.post<dynamic>(
      "btransactions",
      data: <String, dynamic>{
        "beneficiary_id": benId,
        "status": status,
        "type": type,
        "notes": "",
        "amount": ammoutn,
        "shortage": shortage,
        "item_id": itemsId,
        "item_price": itemsPrice,
        "quantity": itemsQuantity,
        "unit": itemsUnit,
        "from_transaction_id": fromTransactionId
      },
      onSendProgress: (int count, int total) {
        progress = count.toDouble() / total.toDouble() / 2.0;
        print('progress send: $progress');
      },
      onReceiveProgress: (int count, int total) {
        // progress = count.toDouble() / total.toDouble()/2.0;
        print('progress receive: $count');
      },
    );
    print("respons ::::::::: $response");

    if (response.statusCode == 200) {
      clearOrcerList();
      setDayLog(response, benId);

      // لتحديث رصيد الصنف فقط
      getItemsBalances();
      // addIdTOTransactionToPayIdsList(
      //     int.parse(response.data['transaction_id'].toString()));

      // howManyscreensToPop++;
      // Navigator.of(c).pushNamedAndRemoveUntil("/Beneficiary_Center",
      //     (Route<dynamic> route) {
      //   return howManyscreensToPop-- == 0;
      // }, arguments: <String, dynamic>{
      //   "ben": getIt<GlobalVars>().getbenInFocus()
      // });
      //     howManyscreensToPop = 2;
      if (type == "order") {
        getIt<GlobalVars>().setOrderTotalsAfterPay((ammoutn).toString(), benId);
      } else {
        getIt<GlobalVars>()
            .setReturnTotalsAfterPay((ammoutn).toString(), benId);
      }
      if (getIt<TransactionProvider>().pagewiseOrderController != null) {
        print("انت بتفوت هنا يسطا ؟ ");
        if (type == "order") {
          getIt<TransactionProvider>().pagewiseOrderController.reset();
        } else {
          getIt<TransactionProvider>().pagewiseReturnController.reset();
        }
      }
      notifyListeners();
      return true;
    } else if (response.statusCode == 422) {
      // Fluttertoast.showToast(
      //     msg: trans(c, "some_items_quantities are more than_u_have"));

      notifyListeners();
      return false;
// Find the Scaffold in the widget tree and use it to show a SnackBar.

    } else {
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendAgentOrder(
      double ammoutn, int shortage, String type, String status) async {
    final List<int> itemsId = <int>[];
    final List<int> itemsQuantity = <int>[];
    final List<double> itemsPrice = <double>[];
    final List<int> itemsUnit = <int>[];
    final List<String> itemsNote = <String>[];
    for (int i = 0; i < ordersList.length; i++) {
      itemsId.add(ordersList[i].id);
      itemsQuantity.add(ordersList[i].queantity);
      itemsPrice.add(double.parse(ordersList[i].unitPrice));
      itemsUnit.add(ordersList[i].unitId);
      itemsNote.add(ordersList[i].notes);
    }

    final Response<dynamic> response =
        await dio.post<dynamic>("stocktransactions", data: <String, dynamic>{
      "status": status,
      "type": type,
      "notes": "",
      "amount": ammoutn,
      "shortage": shortage,
      "item_id": itemsId,
      "item_price": itemsPrice,
      "quantity": itemsQuantity,
      "unit": itemsUnit,
    });
    if (response.statusCode == 200) {
      clearOrcerList();

      getIt<TransactionProvider>().pagewiseAgentOrderController.reset();
      notifyListeners();
      return true;
    } else if (response.statusCode == 422) {
      notifyListeners();
      return false;
// Find the Scaffold in the widget tree and use it to show a SnackBar.

    } else {
      return false;
    }
  }

  Future<void> payMYOrdersAndReturnList(
      BuildContext c, int benId, double amount, String note) async {
    final Response<dynamic> response = await dio
        .post<dynamic>("transaction/pay", data: <String, dynamic>{
      "amount": amount,
      "beneficiary_id": benId,
      "note": note
    });
    if (response.statusCode == 200) {
      Navigator.of(c).pushNamedAndRemoveUntil("/Beneficiary_Center",
          (Route<dynamic> route) {
        return howManyscreensToPop-- == 0;
      }, arguments: <String, dynamic>{
        "ben": getIt<GlobalVars>().getbenInFocus()
      });
      getIt<GlobalVars>()
          .setBalanceForBen(benId, response.data['balance'].toString());
      getIt<GlobalVars>().clearOrderTotAndReturnTotal(benId);
      getIt<TransactionProvider>().pagewiseCollectionController.reset();
      print("pay response value :  ${response.data}");
      // transactionTopAyIds.clear();
      notifyListeners();
    }
  }

  Future<void> getItems() async {
    itemsDataLoaded = false;
    indexedStack = 0;
    notifyListeners();
    await dio.get<dynamic>("items").then((Response<dynamic> value) {
      itemsList = Items.fromJson(value.data).itemsList;
      itemsDataLoaded = true;
      indexedStack = 1;
      picksForbringOrderToOrderScreen();
      notifyListeners();
      return null;
    });
  }

  // Future<void> getPricesForBen(int benId) async {
  //   final Response<dynamic> response = await dio.get<dynamic>("item_caps",
  //       queryParameters: <String, dynamic>{"beneficiary_id": benId});
  //   itemsCaps = ItemCap.fromJson(response.data).itesmcaps;
  //   if (response.statusCode == 200) {
  //     itemsList.forEach((SingleItem signleItem) {
  //       signleItem..unitPrice = itemsCaps.firstWhere((SingleItemCap element) {
  //         return signleItem.id == element.itemId;
  //       }).price;
  //     });
  //   }
  // }

  Future<void> getItemsBalances() async {
    itemsBalanceDataLoaded = false;
    indexedStackBalance = 0;
    notifyListeners();
    await dio
        .get<dynamic>("items_info/balance")
        .then((Response<dynamic> value) {
      itemsBalances = ItemsBalance.fromJson(value.data).itemsList;
      itemsBalanceDataLoaded = true;
      indexedStackBalance = 1;
      notifyListeners();
      return null;
    });
  }

  SingleItem getItemForUnit(int itemId) {
    return itemsList.firstWhere((SingleItem element) {
      return element.id == itemId;
    });
  }

  bool checkValidation(int itemId, int quantity) {
    print(quantity);

    print(itemId);
    if ((quantity <=
            itemsList.firstWhere((SingleItem element) {
              return element.id == itemId;
            }, orElse: () {
              return dummySiglItem;
            }).balanceInventory) &&
        quantity > 0) {
      if (quantity <=
          getIt<GlobalVars>().benInFocus.itemsCap.firstWhere(
              (ItemsCap element) {
            return element.itemId == itemId;
          }, orElse: () {
            return dummyItemCap;
          }).balanceCap) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool loadingStar = false;
  void changeLoadingStare(bool state) {
    loadingStar = state;
    notifyListeners();
  }
}
