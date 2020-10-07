class Transactions {
  Transactions({this.transactions});

  Transactions.fromJson(dynamic json) {
    if (json['data'] != null) {
      transactions = <Transaction>[];
      json['data'].forEach((dynamic v) {
        transactions.add(Transaction.fromJson(v));
      });
    }
  }

  dynamic toJson() {
    final dynamic data = <dynamic>{};
    if (data != null) {
      data['data'] = data.map<dynamic>((dynamic v) => v.toJson()).toList();
    }
    return data;
  }

  List<Transaction> transactions;
}

class Transaction {
  Transaction(
      {this.id,
      this.beneficiary,
      this.beneficiaryId,
      this.agent,
      this.transDate,
      this.address,
      this.vehicleId,
      this.status,
      this.type,
      this.notes,
      this.amount,
      this.shortage,
      this.latitude,
      this.longitude,
      this.createdAt,
      this.tax,
      this.details});

  Transaction.fromJson(dynamic json) {
    id = json['id'] as int;
    beneficiary = json['beneficiary'].toString();
    beneficiaryId = json['beneficiary_id'] as int;
    agent = json['agent'].toString();
    transDate = json['transaction_date'].toString();
    address = json['address'].toString();
    vehicleId = json['vehicle_id'] as int;
    status = json['status'].toString();
    type = json['type'].toString();
    notes = json['notes'].toString();
    amount = double.parse(json['amount'].toString());
    shortage = json['shortage'] as int;
    if (json['latitude'] != null)
      latitude = double.parse(json['latitude'].toString());
    if (json['longitude'] != null)
      longitude = double.parse(json['longitude'].toString());
    createdAt = json['created_at'].toString();
    if (json['details'] != null) {
      details = <MiniItems>[];
      json['details'].forEach((dynamic v) {
        details.add(MiniItems.fromJson(v));
      });
    }
    if (json['taxed'] != null) tax = double.parse(json['taxed'].toString());
  }

  dynamic toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['beneficiary'] = beneficiary;
    data['agent'] = agent;
    data['trans_date'] = transDate;
    data['address'] = address;
    data['vehicle_id'] = vehicleId;
    data['status'] = status;
    data['type'] = type;
    data['notes'] = notes;
    data['amount'] = amount;
    data['shortage'] = shortage;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    if (details != null) {
      data['details'] = details.map((MiniItems v) => v.toJson()).toList();
    }
    return data;
  }

  int id;
  String beneficiary;
  int beneficiaryId;
  String agent;
  String transDate;
  String address;
  int vehicleId;
  String status;
  String type;
  String notes;
  double amount;
  int shortage;
  double latitude;
  double longitude;
  String createdAt;
  double tax;
  List<MiniItems> details;
}

class MiniItems {
  MiniItems(
      {this.id,
      this.itemId,
      this.item,
      this.unit,
      this.itemPrice,
      this.quantity,
      this.total,
      this.notes});

  MiniItems.fromJson(dynamic json) {
    id = json['id'] as int;
    itemId = json['item_id'] as int;
    item = json['item'].toString();
    unit = json['unit'].toString();
    itemPrice = double.parse(json['item_price'].toString());
    quantity = json['quantity'] as int;
    total = double.parse(json['total'].toString());
    notes = json['notes'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item'] = item;
    data['unit'] = unit;
    data['item_price'] = itemPrice;
    data['quantity'] = quantity;
    data['total'] = total;
    data['notes'] = notes;
    return data;
  }

  int id;
  int itemId;
  String item;
  String unit;
  double itemPrice;
  int quantity;
  double total;
  String notes;
}
