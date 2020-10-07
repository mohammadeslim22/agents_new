class BeneficiariesModel {
  BeneficiariesModel({this.data});

  BeneficiariesModel.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = <Ben>[];
      json['data'].forEach((dynamic v) {
        data.add(Ben.fromJson(v));
      });
    }
  }
  List<Ben> data;
}

class Ben {
  Ben(
      {this.id,
      this.name,
      this.commercialRecord,
      this.city,
      this.address,
      this.latitude,
      this.longitude,
      this.region,
      this.managerName,
      this.phone,
      this.phone2,
      this.email,
      this.classification,
      this.status,
      this.price,
      this.isreturn,
      this.limitDebt,
      this.notes,
      this.lastTransDate,
      this.transTotal,
      this.transCount,
      this.itemsCap,
      this.visited,
      this.orderTransTotal,
      this.collectionTransCount,
      this.collectionTransTotal,
      this.orderTransCount,
      this.returnTransCount,
      this.returnTransTotal,
      this.balance,
      this.totalOrders,
      this.totalReturns,
      this.trn});

  Ben.fromJson(dynamic json) {
    id = json['id'] as int;
    name = json['name'].toString();
    commercialRecord = json['commercial_record'].toString();
    if (json['city'] != null) {
      city = <City>[];
      json['city'].forEach((dynamic v) {
        city.add(City.fromJson(v));
      });
    }
    address = json['address'].toString();
    if (json['latitude'] != null)
      latitude = double.parse(json['latitude'].toString());
    if (json['longitude'] != null)
      longitude = double.parse(json['longitude'].toString());
    region = json['region'].toString();
    managerName = json['manager_name'].toString();
    phone = json['phone'].toString();
    phone2 = json['phone2'].toString();
    email = json['email'].toString();
    classification = json['classification'].toString();
    status = json['status'].toString();
    price = json['price'] as int;
    isreturn = json['isreturn'] as int;
    limitDebt = json['limit_debt'] as int;
    notes = json['notes'].toString();
    if (json['items_cap'] != null) {
      itemsCap = <ItemsCap>[];
      itemsBalances = <String, String>{};
      itemsPrices = <String, String>{};
      json['items_cap'].forEach((dynamic v) {
        itemsCap.add(ItemsCap.fromJson(v));
      });
    }
    lastTransDate = json['last_trans_date'].toString();
    transTotal = json['trans_total'].toString();
    transCount = json['trans_count'] as int;

    itemsCap.forEach((ItemsCap element) {
      itemsBalances[element.itemId.toString()] = element.balanceCap.toString();
     itemsPrices[element.itemId.toString()] = element.price.toString();

    });
    visited = false;
    orderTransTotal = json['order_trans_total'].toString();
    collectionTransCount = json['collection_trans_count'].toString();
    collectionTransTotal = json['collection_trans_total'].toString();
    orderTransCount = json['order_trans_count'].toString();
    returnTransCount = json['return_trans_count'].toString();
    returnTransTotal = json['return_trans_total'].toString();
    balance = json['balance'].toString();
    trn = json['trn'].toString();
    
    // totalOrders =double.parse(json['total_confirmed'].toString());
    // totalReturns = double.parse(json['total_returned_confirmed'].toString());
  }
  int id;
  String name;
  String commercialRecord;
  List<City> city;
  String address;
  double latitude;
  double longitude;
  String region;
  String managerName;
  String phone;
  String phone2;
  String email;
  String classification;
  String status;
  int price;
  int isreturn;
  int limitDebt;
  String notes;
  String lastTransDate;
  String transTotal;
  int transCount;
  Map<String, String> itemsBalances;
  Map<String, String> itemsPrices;
  List<ItemsCap> itemsCap;
  bool visited;
  String orderTransTotal;
  String orderTransCount;
  String returnTransTotal;
  String returnTransCount;
  String collectionTransTotal;
  String collectionTransCount;
  String balance;
  double totalOrders = 0.0;
  double totalReturns = 0.0;
  String trn;
}

class City {
  City({this.id, this.name, this.createdAt, this.updatedAt});
  City.fromJson(dynamic json) {
    id = json['id'] as int;
    name = json['name'].toString();
    createdAt = json['created_at'].toString();
    updatedAt = json['updated_at'].toString();
  }

  int id;
  String name;
  String createdAt;
  String updatedAt;
}

class ItemsCap {
  ItemsCap({this.itemId, this.balanceCap, this.price});

  ItemsCap.fromJson(dynamic json) {
    itemId = json['item_id'] as int;
    balanceCap = json['balance_cap'] as int;
    price = json['price'].toString();
  }
  int itemId;
  int balanceCap;
  String price;
}
