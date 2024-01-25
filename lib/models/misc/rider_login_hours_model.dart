class RiderLoginHoursModel {
  RiderLoginHoursModel({
    required this.success,
    required this.message,
    required this.data,
  });
  late final bool success;
  late final String message;
  late final Data data;

  RiderLoginHoursModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.shift,
    required this.startedAt,
    required this.loginHours,
    required this.shiftHours,
    required this.startDate,
    required this.endDate,
    required this.totalOrders,
  });
  late final Shift shift;
  late final StartedAt startedAt;
  late final num loginHours;
  late final num shiftHours;
  late final String startDate;
  late final String endDate;
  late final int totalOrders;

  Data.fromJson(Map<String, dynamic> json) {
    shift = Shift.fromJson(json['shift']);
    startedAt = StartedAt.fromJson(json['started_at']);
    loginHours = json['login_hours'];
    shiftHours = json['shift_hours'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    totalOrders = json['total_orders'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['shift'] = shift.toJson();
    _data['started_at'] = startedAt.toJson();
    _data['login_hours'] = loginHours;
    _data['shift_hours'] = shiftHours;
    _data['start_date'] = startDate;
    _data['end_date'] = endDate;
    _data['total_orders'] = totalOrders;
    return _data;
  }
}

class Shift {
  Shift(
      {required this.riderId,
      required this.shift,
      required this.timeFrom,
      required this.timeTo,
      required this.date,
      required this.shiftTiming});
  late final int riderId;
  late final String shift;
  late final String shiftTiming;
  late final int timeFrom;
  late final int timeTo;
  late final String date;

  Shift.fromJson(Map<String, dynamic> json) {
    riderId = json['rider_id'];
    shift = json['shift'];
    timeFrom = json['time_from'];
    timeTo = json['time_to'];
    date = json['date'];
    shiftTiming = json['shift_timing'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['rider_id'] = riderId;
    _data['shift'] = shift;
    _data['time_from'] = timeFrom;
    _data['time_to'] = timeTo;
    _data['date'] = date;
    _data['shift_timing'] = shiftTiming;
    return _data;
  }
}

class StartedAt {
  StartedAt({
    required this.started,
    required this.delay,
  });
  late final String started;
  late final int delay;

  StartedAt.fromJson(Map<String, dynamic> json) {
    started = json['started'];
    delay = json['delay'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['started'] = started;
    _data['delay'] = delay;
    return _data;
  }
}
