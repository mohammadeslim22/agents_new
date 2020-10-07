import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/models/Items.dart';
import 'package:agent_second/providers/export.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:flutter/material.dart';

class UnitsCooficientsDialog extends StatefulWidget {
  const UnitsCooficientsDialog({Key key, this.item}) : super(key: key);
  final SingleItem item;
  @override
  _UnitsCooficientsDialogState createState() => _UnitsCooficientsDialogState();
}

class _UnitsCooficientsDialogState extends State<UnitsCooficientsDialog> {
  int groupValue = 0;
  String selected = "";
  List<int> grouplist = <int>[];
  int selectedId;
  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= widget.item.units.length; i++) {
      if (i == widget.item.unit) {
        grouplist.add(0);
      } else {
        grouplist.add(1);
      }
    }
    print(grouplist);
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(trans(context, "unit"), style: styles.thirtyblack),
                    Text(trans(context, "coefficient_stability"),
                        style: styles.thirtyblack)
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: widget.item.units.map<Widget>(
                    (Units u) {
                      return FlatButton(
                          onPressed: () {
                            setState(() {
                              for (int i = 0; i < grouplist.length; i++) {
                                if (i == u.id - 1) {
                                  widget.item.unit = u.id;
                                  selectedId = u.id;
                                  grouplist[i] = 0;
                                } else {
                                  grouplist[i] = 1;
                                }
                              }

                              selected = u.name;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 200,
                                child: Row(
                                  children: <Widget>[
                                    Radio<int>(
                                      value: grouplist[u.id - 1],
                                      groupValue: groupValue,
                                      onChanged: (int t) {
                                        setState(() {
                                          for (int i = 0;
                                              i < grouplist.length;
                                              i++) {
                                            if (i == u.id - 1) {
                                              grouplist[i] = 0;
                                              selectedId = u.id;
                                              widget.item.unit = u.id;
                                            } else {
                                              grouplist[i] = 1;
                                            }
                                          }

                                          selected = u.name;
                                        });
                                      },
                                    ),
                                    Text(u.name, style: styles.smallbluestyle)
                                  ],
                                ),
                              ),
                              Text(u.id.toString(),
                                  style: styles.underHeadgray),
                              const SizedBox(width: 12),
                            ],
                          ));
                    },
                  ).toList(),
                ),
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
                            getIt<OrderListProvider>().changeUnit(
                              widget.item.id,
                              selected,selectedId
                            );
                            Navigator.pop(context);
                          },
                          child: Text(trans(context, "ok_unit"),
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
                          onPressed: () {},
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
