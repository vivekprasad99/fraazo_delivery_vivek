import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/models/user/basic_details.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/models/user/testimonial_model.dart';
import 'package:fraazo_delivery/permission_handler/phone_permission_handler.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';
import 'package:fraazo_delivery/utils/globals.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileProvider, AsyncValue<User?>?>(
        (_) => UserProfileProvider());

class UserProfileProvider extends StateNotifier<AsyncValue<User?>?> {
  UserProfileProvider([AsyncValue<User>? state]) : super(state);

  final _userService = UserService();
  final _phonePermissionHandler = PhonePermissionHandler();

  late final UserModel userModel;

  Future<User?> getUserDetails({String? deviceToken}) async {
    try {
      state = const AsyncLoading();
      final List<String> _list = await _phonePermissionHandler.getIMEIs();
      final Map<String, String> address =
          await _phonePermissionHandler.getRiderLocation();
      final Map<String, String> deviceModelNo =
          await _phonePermissionHandler.getModel();
      final user = await _userService.getRider(
          _list.last, address, deviceModelNo,
          deviceToken: deviceToken);
      Globals.user = user!.data;
      Globals.shouldShowBilling = user.data?.billingEnabled ?? true;
      state = AsyncData(user.data);
      userModel = user;
      return user.data;
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "UserProfileProvider: getUserDetails()");
      rethrow;
    }
  }

  void changeUserStatus(String status) {
    Globals.user?.status = status;
    updateUser();
  }

  void updateUser() {
    state = AsyncData(Globals.user);
  }

  Future setPassword(String password) {
    return _userService.postCreatePassword(password);
  }

  Future<String> getCashSettlementCode() {
    return _userService.getSettlementCode();
  }

  Future acceptTNC() {
    return _userService.putAcceptTNC();
  }

  Future<List<IdName>?> getProfileAvatar(String avatarType) {
    return _userService.getAvatarList(avatarType);
  }

  Future<BasicDetails> getBasicDetails() async {
    final _basicDetails = await _userService.getBasicDetails();
    return _basicDetails;
  }

  Future<bool> saveBasicInfo(Data basicDetails) async {
    try {
      await _userService.saveBasicInfo(basicDetails);
      return true;
    } catch (e, st) {
      ErrorReporter.error(e, st, "UserProfileProvider: saveBasicInfo()");
      return false;
    }
  }

  Future<TestimonialModel> getTestimonialDetails() {
    return _userService.getTestimonial();
  }
}
