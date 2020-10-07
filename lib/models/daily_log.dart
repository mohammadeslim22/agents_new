class DailyLog {
  DailyLog(
      {this.transactionsCount,
      this.tBeneficiariryCount,
      this.orderCount,
      this.returnCount,
      this.totalOrderCount,
      this.totalReturnCount,
      this.totalCollectionCount,
      this.collectionCount,
      this.benIds,
      this.totalOrdered,
      this.totalReturned});

  DailyLog.fromJson(dynamic json) {
    // transactionsCount = json['transactions_count'] as int;

    tBeneficiariryCount = json['t_beneficiary_count'] as int;
    transactionsCount = json['transactions_count'] as int;
    // tBeneficiariryCount = int.parse(json['t_beneficiariry_count'].toString());
    orderCount = json['order_count'] as int;
    returnCount = json['return_count'] as int;
    totalOrderCount = json['total_order_count'].toString();
    totalReturnCount = json['total_return_count'].toString();
    totalCollectionCount =double.parse(json['total_collection_count'].toString());
    collectionCount =double.parse(json['collection_count'].toString());
    if (json['ben_ids'] != null)
      benIds = json['ben_ids'].cast<int>() as List<int>;
    if (json['total_ordered'] != null) {
      totalOrdered = json['total_confirmed'].toString();
      totalReturned = json['total_returned_confirmed'].toString();
    }
    if (json['balance'] != null) {
      balance = json['balance'].toString();
    }
  }
  int transactionsCount;
  int tBeneficiariryCount;
  int orderCount;
  int returnCount;
  String totalOrderCount;
  String totalReturnCount;
  double totalCollectionCount;
  double collectionCount;
  List<int> benIds;
  String totalOrdered;
  String totalReturned;
  String balance;
}
