import 'package:agent_second/models/ben.dart';
import 'package:agent_second/models/transactions.dart';
import 'package:agent_second/ui/agent_orders.dart';
import 'package:agent_second/ui/auth/login_screen.dart';
import 'package:agent_second/ui/ben_center.dart';
import 'package:agent_second/ui/beneficiaries.dart';
import 'package:agent_second/ui/home.dart';
import 'package:agent_second/ui/oder_screen.dart';
import 'package:agent_second/ui/payment_screen.dart';
import 'package:agent_second/ui/show_items.dart';
import 'package:agent_second/util/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

// Generate all application routes with simple transition
Route<PageController> onGenerateRoute(RouteSettings settings) {
  Route<PageController> page;

  final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;

  switch (settings.name) {
    case "/Home":
      page = PageTransition<PageController>(
        child: const Home(),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
    case "/Beneficiaries":
      page = PageTransition<PageController>(
        child: const Beneficiaries(),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
    case "/Beneficiary_Center":
      page = PageTransition<PageController>(
        child: BeneficiaryCenter(ben: args['ben'] as Ben),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
    case "/Order_Screen":
      page = PageTransition<PageController>(
        child: OrderScreen(
            ben: args['ben'] as Ben,
            isORderOrReturn: args['isORderOrReturn'] as bool,isAgentOrder:  args['isAgentOrder']as bool??false,transId: args['transId']as int),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
    case "/Payment_Screen":
      page = PageTransition<PageController>(
        child:
            PaymentScreen(orderTotal: args['orderTotal'] as double,returnTotal: args['returnTotal'] as double,cashTotal:args['cashTotal']as double),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;

    case "/login":
      page = PageTransition<PageController>(
        child: const LoginScreen(),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
      
    case "/items":
      page = PageTransition<PageController>(
        child: const ShowItems(),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
          case "/Agent_Orders":
      page = PageTransition<PageController>(
        child:  AgentOrders(expand: args['expand']as bool,width: args['width'] as double),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
            case "/Bluetooth":
      page = PageTransition<PageController>(
        child:  Bluetooth(transaction : args['transaction'] as Transaction),
        type: PageTransitionType.rightToLeftWithFade,
      );
      break;
  }

  
  return page;
}
