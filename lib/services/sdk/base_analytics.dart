import 'package:fraazo_delivery/models/user/profile/user_model.dart';

/// Base analytics class
/// So any new analytics we add it has to extend this abstract class so can have basics things there
abstract class BaseAnalytics {
  void initialise();
  void setUserProperties(User user);
  void log(String name);
  void logoutReset();
}
