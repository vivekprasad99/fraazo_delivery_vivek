import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/bank_details_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class BankDetailsProvider extends StateNotifier<AsyncValue<BankDetails>> {
  BankDetailsProvider([AsyncValue<BankDetails> state = const AsyncLoading()])
      : super(state);

  final _userService = UserService();

  Future getRiderBankDetails() async {
    state = const AsyncLoading();
    try {
      final bankDetails = await _userService.getRiderAccount();
      state = AsyncData(bankDetails);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "BankDetailsProvider: getRiderBankDetails()");
    }
  }

  Future<bool> setRiderBankDetails(BankDetails bankDetails) async {
    try {
      await _userService.putRiderAccount(bankDetails);
      return true;
    } catch (e, st) {
      ErrorReporter.error(e, st, "BankDetailsProvider: setRiderBankDetails()");
      return false;
    }
  }

  Future verifyBankDetails() {
    return _userService.postPennyCheck();
  }
}
