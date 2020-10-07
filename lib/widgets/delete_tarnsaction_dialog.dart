import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/providers/order_provider.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionDeleteDialog extends StatefulWidget {
  const TransactionDeleteDialog({Key key, this.downCacel, this.c}) : super(key: key);
  final bool downCacel;
  final BuildContext c;

  @override
  _TransactionDeleteDialogState createState() =>
      _TransactionDeleteDialogState();
}

class _TransactionDeleteDialogState extends State<TransactionDeleteDialog> {
  int groupValue = 0;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 400,
        width: 600,
        margin: const EdgeInsets.only(bottom: 200, left: 12, right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox.expand(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child:
                      SvgPicture.asset("assets/images/transaction_delete.svg"),
                ),
                Text(trans(context, "are_u_sure_cancel"),
                    style: styles.thirtyblack),
                const Spacer(),
                const Divider(thickness: 2, color: Colors.grey),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: colors.trans,
                        child: FlatButton(
                          autofocus: true,
                          onPressed: () {
                            getIt<OrderListProvider>().clearOrcerList();
                            Navigator.pop(context);
                            if (widget.downCacel) {
                              Navigator.pop(widget.c);
                            }
                          },
                          child: Text(trans(context, "ok_delete"),
                              style: styles.underHeadgreen),
                        ),
                      ),
                    ),
                    verticalDiv(),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          color: colors.trans,
                        ),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(trans(context, "cancel"),
                              style: styles.underHeadred),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget verticalDiv() {
  return Container(
      padding: EdgeInsets.zero,
      child: const VerticalDivider(
        color: Colors.grey,
        thickness: 2,
      ),
      height: 80);
}
