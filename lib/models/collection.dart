class Collections {
  Collections({this.collectionList});

  Collections.fromJson(dynamic json) {
    if (json['data'] != null) {
      collectionList = <SingleCollection>[];
      json['data'].forEach((dynamic v) {
        collectionList.add(SingleCollection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (collectionList != null) {
      data['data'] =
          collectionList.map((SingleCollection v) => v.toJson()).toList();
    }
    return data;
  }

  List<SingleCollection> collectionList;
}

class SingleCollection {
  SingleCollection({
    this.id,
    this.beneficiaryId,
    this.agentId,
    this.vehicleId,
    this.amount,
    this.createdAt,
    this.agent,
    this.beneficiary,
  });

  SingleCollection.fromJson(dynamic json) {
    id = json['id'] as int;
    beneficiaryId = json['beneficiary_id'].toString();
    agentId = json['agent_id'] as int;
    vehicleId = json['vehicle_id'] as int;
    amount = json['amount'] as int;
    createdAt = json['created_at'].toString();
    agent = json['agent'].toString();
    beneficiary = json['beneficiary'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['beneficiary_id'] = beneficiaryId;
    data['agent_id'] = agentId;
    data['vehicle_id'] = vehicleId;
    data['amount'] = amount;
    data['agent'] = createdAt;
    data['beneficiary'] = beneficiary;
    return data;
  }

  int id;
  String beneficiaryId;
  int agentId;
  int vehicleId;
  int amount;
  String createdAt;
  String agent;
  String beneficiary;
}
