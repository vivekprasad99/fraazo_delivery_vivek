class IdNameModel {
  final List<IdName> idNameList = [];

  IdNameModel.fromJson(Map<String, dynamic> json, {String? keyName}) {
    if (json['data'] != null) {
      json['data'].forEach((v) {
        idNameList.add(IdName.fromJson(v, keyName));
      });
    }
  }
}

class IdName {
  int? id;
  String? name;
  String? code;
  String? logo;
  String? img;
  IdName({this.id, this.name, this.code, this.logo, this.img});

  IdName.fromJson(Map<String, dynamic> json, String? keyName) {
    id = json['id'];
    name = json[keyName ?? 'name'];
    code = json['code'] ?? '';
    logo = json['bank_logo'] ?? '';
    img = json['image_url'] ?? '';
  }
}
