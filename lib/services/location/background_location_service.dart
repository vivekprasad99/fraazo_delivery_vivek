import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';

import 'location_callback_handler.dart';

class BackgroundLocationService {
  // static const String _isolateName = "LocatorIsolate";
  // ReceivePort port = ReceivePort();

  Future init() {
    // IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
/*    port.listen((dynamic data) {
      // do something with data
      print(data);
    });*/
    return BackgroundLocator.initialize();
  }

  Future startLocationService(
      {required void Function(LocationDto) onLocationUpdate}) async {
    await BackgroundLocator.registerLocationUpdate(
      onLocationUpdate,
      disposeCallback: LocationCallbackHandler.disposeCallback,
      androidSettings: const AndroidSettings(
        interval: 30,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationTitle: 'Fraazo Delivery Partner',
          notificationMsg: 'Fraazo Location Updates',
          notificationBigMsg:
              'Fraazo Delivery Partner is on to keep the app up-to-date with your location.',
          notificationChannelName: 'Background Location Updates',
        ),
      ),
    );
  }

/*  static void callback(LocationDto locationDto) async {
    final SendPort send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(locationDto);
  }*/

  Future<bool> isServiceRunning() {
    return BackgroundLocator.isServiceRunning();
  }

  Future stopLocationService() {
    // port.close();
    return BackgroundLocator.unRegisterLocationUpdate();
  }
}
