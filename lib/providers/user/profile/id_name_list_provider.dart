import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/services/api/authentication/authentication_service.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class IdNameListProvider extends StateNotifier<AsyncValue<List<IdName>>> {
  IdNameListProvider([AsyncValue<List<IdName>> state = const AsyncLoading()])
      : super(state);
  List<IdName>? idNameList = [];

  Future getList(String type) async {
    state = const AsyncLoading();
    try {
      idNameList = [];
      if (type == "Delivery Partner") {
        idNameList = await AuthenticationService().getDeliveryPartners();
      } else if (type == "Vehicle Type") {
        idNameList = await UserService().getVehicleType();
      } else if (type == "City") {
        idNameList = await UserService().getCities();
      } else if (type == "Bank Name") {
        idNameList = await UserService().getBankList();
      } else if (type == "Relation") {
        idNameList = await UserService().getRelationList();
      }
      state = AsyncData(idNameList!);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "IdNameListProvider: getList()");
    }
  }

  Future searchBankList(String query) async {
    if (query.isEmpty) {
      state = AsyncData(idNameList!);
    } else {
      final List<IdName>? filterData = idNameList
          ?.where((element) =>
              element.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = AsyncData(filterData!);
    }
  }
}
