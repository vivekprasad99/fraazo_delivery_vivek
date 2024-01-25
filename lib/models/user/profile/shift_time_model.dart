class ShiftTimeModel {
  bool? success;
  String? message;
  List<ShiftTime> shiftTimeList = [];

  ShiftTimeModel({this.success, this.message, required this.shiftTimeList});

  ShiftTimeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        shiftTimeList.add(ShiftTime.fromJson(v));
      });
    }
  }
}

class ShiftTime {
  int? id;
  String? shift;
  int? timeFrom;
  int? timeTo;
  String? storeCode;
  String? cityCode;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? shiftText;
  String? shiftTiming;

  ShiftTime(
      {this.id,
      this.shift,
      this.timeFrom,
      this.timeTo,
      this.storeCode,
      this.cityCode,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.shiftText,
      this.shiftTiming});

  ShiftTime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shift = json['shift'];
    timeFrom = json['time_from'];
    timeTo = json['time_to'];
    storeCode = json['store_code'];
    cityCode = json['city_code'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    shiftText = json['shift_text'];
    shiftTiming = json['shift_timing'];
  }
}
