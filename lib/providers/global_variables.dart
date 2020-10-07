import 'package:agent_second/constants/config.dart';
import 'package:agent_second/models/ben.dart';
import 'package:agent_second/util/data.dart';
import 'package:agent_second/util/dio.dart';
import 'package:agent_second/util/functions.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GlobalVars with ChangeNotifier {
  BeneficiariesModel beneficiaries;
  Ben benInFocus;
  String benRemaining = "0/0";
  String orderscount = "0";
  String orderTotal = "0.00";
  String returnscount = "0";
  String returnTotal = "0.00";
  String collectionscount = "0";
  String collectionTotal = "0.00";
  List<int> benReached = <int>[];
  bool bensIsOpen = false;
  static DateTime timeSinceLoginn = DateTime(2020);
  String timeSinceLogin = DateFormat.Hm().format(timeSinceLoginn);
  static DateTime timeSinceLastTranss = DateTime(2020);
  String timeSinceLastTrans = DateFormat.Hm().format(timeSinceLoginn);
  void setBenInFocus(Ben ben) {
    benInFocus = ben;
    notifyListeners();
  }

  Ben getbenInFocus() {
    return benInFocus;
  }

  Future<BeneficiariesModel> getBenData() async {
    final Response<dynamic> response = await dio.get<dynamic>("beneficaries");
    getIt<GlobalVars>().setBens(BeneficiariesModel.fromJson(response.data));
    await Future<void>.delayed(const Duration(seconds: 3), () {});

    getUserData();
    config.agentId = int.parse(await data.getData("agent_id"));
    return beneficiaries;
  }

  Future<void> getUserData() async {
    final Response<dynamic> response = await dio.get<dynamic>("day_log");
    setDayLog(response, null);
  }

  void setBens(BeneficiariesModel x) {
    beneficiaries = x;
    notifyListeners();
  }

  Future<void> updateBenLocation(int benId, double lat, double long) async {
    final Response<dynamic> response = await dio
        .post<dynamic>("beneficiary/update_location", data: <String, dynamic>{
      "beneficiary_id": benId,
      "latitude": lat,
      "longitude": long
    });
    print(response);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "تم تحديث بيانات الموقع");
    } else {
      Fluttertoast.showToast(msg: "حدث خطأ");
    }
  }

  void setBalanceForBen(int benId, String balance) {
    if (benId != null) {
      beneficiaries.data.firstWhere((Ben element) {
        return element.id == benId;
      }, orElse: () {
        return;
      }).balance = double.parse(balance ?? "0.0").toString();
    }
  }

  void setDailyLog(
      int benId,
      String ben,
      String orders,
      String orderTot,
      String rturned,
      String rturnTot,
      String collection,
      String collectionTot,
      List<int> bens,
      String balance) {
    benRemaining = "$ben / ${beneficiaries.data.length}";
    orderscount = orders;
    orderTotal = "$orderTot";
    returnscount = rturned;
    returnTotal = "$rturnTot";
    collectionscount = collection;
    collectionTotal = "$collectionTot";
    beneficiaries.data.where((Ben element) {
      return bens.contains(element.id);
    }).forEach((Ben element) {
      element.visited = true;
    });
    setBalanceForBen(benId, balance);

    // if (totOrd != null && totRet != null) {
    //   totalOrders = double.parse(totOrd);
    //   totalReturns = double.parse(totRet);
    // }

    notifyListeners();
  }

  void setOrderTotalsAfterPay(String ordertot, int benId) {
    beneficiaries.data.firstWhere((Ben element) {
      return element.id == benId;
    }, orElse: () {
      return;
    }).totalOrders += double.parse(ordertot ?? "0.0");
    notifyListeners();
  }

  void setReturnTotalsAfterPay(String returntot, int benId) {
    beneficiaries.data.firstWhere((Ben element) {
      return element.id == benId;
    }, orElse: () {
      return;
    }).totalReturns += double.parse(returntot ?? "0.0");
    notifyListeners();
  }
void clearOrderTotAndReturnTotal(int benId){
  beneficiaries.data.firstWhere((Ben element) {
      return element.id == benId;
    }, orElse: () {
      return;
    })..totalReturns = 0.0..totalOrders=0.0;
    notifyListeners();
}
  void incrementTimeSinceLogin() {
    timeSinceLoginn = timeSinceLoginn.add(const Duration(minutes: 1));
    timeSinceLogin = DateFormat.Hm().format(timeSinceLoginn);

    notifyListeners();
  }

  void incrementTimeSinceLastTransaction() {
    timeSinceLastTranss = timeSinceLoginn.add(const Duration(minutes: 1));
    timeSinceLastTrans = DateFormat.Hm().format(timeSinceLoginn);

    notifyListeners();
  }

  void startLastTransactionTimeCounter() {
    cron.schedule(Schedule.parse('*/1 * * * *'), () async {
      incrementTimeSinceLastTransaction();
    });
  }
}

// background proccess service
final Cron cron = Cron();
