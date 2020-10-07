class FinanicalRecords {
  FinanicalRecords({this.data});

  FinanicalRecords.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = <FinanicalRecord>[];
      json['data'].forEach((dynamic v) {
        data.add(FinanicalRecord.fromJson(v));
      });
    }
  }
  List<FinanicalRecord> data;
}

class FinanicalRecord {
  FinanicalRecord(
      {this.id,
      this.from,
      this.agent,
      this.beneficiaryId,
      this.type,
      this.debit,
      this.credit,
      this.status,
      this.date});

  FinanicalRecord.fromJson(dynamic json) {
    id = json['id'] as int;
    from = json['from'] as int;
    agent = Agent.fromJson(json['agent']);
    beneficiaryId = json['beneficiary_id'] as int;
    type = json['type'].toString();
    debit = double.parse(json['debit'].toString());
    credit =double.parse(json['credit'].toString());
    status = json['status'].toString();
    date = json['date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from'] = from;
    data['agent'] = agent;
    data['beneficiary_id'] = beneficiaryId;
    data['type'] = type;
    data['debit'] = debit;
    data['credit'] = credit;
    data['status'] = status;
    data['date'] = date;
    return data;
  }

  int id;
  int from;
  Agent agent;
  int beneficiaryId;
  String type;
  double debit;
  double credit;
  String status;
  String date;
}

class Agent {
  Agent({this.id, this.name});

  Agent.fromJson(dynamic json) {
    id = json['id'] as int;
    name = json['name'].toString();
  }
  int id;
  String name;
}
