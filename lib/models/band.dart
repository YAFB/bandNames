class Band {
  String? id;
  String? name;
  int? votes;

  Band({this.id, this.name, this.votes});

  Band.fromMap(Map<String, dynamic> obj) {
    id = obj["id"];
    name = obj["name"];
    votes = obj["votes"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['votes'] = votes;
    return data;
  }
}
