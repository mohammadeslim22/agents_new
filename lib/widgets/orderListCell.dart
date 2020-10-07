import 'package:flutter/material.dart';
import 'package:agent_second/models/transactions.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/constants/styles.dart';

class OrderListCell extends StatelessWidget {
  const OrderListCell({Key key, this.items}) : super(key: key);
  final List<MiniItems> items;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 26,
              columns: <DataColumn>[
                DataColumn(
                  label: Text(trans(context, '#'), style: styles.bill),
                  numeric: true,
                ),
                DataColumn(
                    label: Text(trans(context, 'product_name'),
                        style: styles.bill)),
                DataColumn(
                  label: Text(trans(context, 'quantity'), style: styles.bill),
                  numeric: true,
                ),
                DataColumn(
                    label: Text(trans(context, 'unit'), style: styles.bill)),
                DataColumn(
                  label: Text(trans(context, 'unit_price'), style: styles.bill),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(trans(context, 'total'), style: styles.bill),
                  numeric: true,
                )
              ],
              rows: items.map((MiniItems e) {
                return DataRow(cells: <DataCell>[
                  DataCell(Text(e.itemId.toString())),
                  DataCell(Text(e.item)),
                  DataCell(Text(e.quantity.toString())),
                  DataCell(Text(e.unit.toString())),
                  DataCell(Text(e.itemPrice.toString())),
                  DataCell(Text(e.total.toString()))
                ]);
              }).toList(),
            )));
  }
}
