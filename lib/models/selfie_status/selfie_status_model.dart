class SelfieStatusModel {
  SelfieStatusModel({
    required this.success,
    required this.message,
    required this.data,
  });
  late final bool success;
  late final String message;
  SelfieEnabledData? data;

  SelfieStatusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = SelfieEnabledData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data?.toJson();
    return _data;
  }
}

class SelfieEnabledData {
  SelfieEnabledData({
    required this.selfieEnabled,
  });
  late final bool selfieEnabled;

  SelfieEnabledData.fromJson(Map<String, dynamic> json) {
    selfieEnabled = json['SELFIE_ENABLED'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['SELFIE_ENABLED'] = selfieEnabled;
    return _data;
  }
}
