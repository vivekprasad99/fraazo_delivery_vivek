import 'package:background_locator/location_dto.dart';

import 'location_service_repository.dart';

class LocationCallbackHandler {
/*
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    */
/*  final LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.init(params);*/ /*

  }
*/

  static Future<void> disposeCallback() async {
    final LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto locationDto) async {
    final LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

/*  static Future<void> notificationCallback() async {
    // print('***notificationCallback');
  }*/
}
