import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/location_dto.dart';

class LocationServiceRepository {
  factory LocationServiceRepository() {
    return _instance;
  }

  static final LocationServiceRepository _instance =
      LocationServiceRepository._();

  LocationServiceRepository._();

  static const String isolateName = 'LocatorIsolate';

  Future<void> dispose() async {
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    log("Location Update", error: locationDto.toString());
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
  }
}
