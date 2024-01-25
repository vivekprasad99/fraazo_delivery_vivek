import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/models/common/meta.dart';
import 'package:fraazo_delivery/models/delivery/earning_model.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';

class EarningsProvider extends StateNotifier<AsyncValue<List<Earning>>> {
  EarningsProvider([AsyncValue<List<Earning>> state = const AsyncLoading()])
      : super(state);

  final _deliveryService = DeliveryService();
  final List<Earning> _earningList = [];
  Meta? _meta;
  bool isFinished = false;

  Future getEarnings({String? fromDate, String? toDate}) async {
    state = const AsyncLoading();
    try {
      _earningList.clear();
      await _onData(0, fromDate: fromDate, toDate: toDate);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "EarningsProvider: getEarnings()");
    }
  }

  Future _onData(int? currentPage, {String? fromDate, String? toDate}) async {
    final EarningModel earningModel = await _deliveryService.getEarningList(
      pageNo: (currentPage ?? 0) + 1,
      fromDate: fromDate?.reverse("-"),
      toDate: toDate?.reverse("-"),
    );
    _meta = earningModel.meta;
    isFinished = (_meta?.currentPage ?? 1) >= (_meta?.totalPages ?? 1);
    if (earningModel.data != null) {
      _earningList.addAll(earningModel.data!);
    }
    state = AsyncData(_earningList);
  }

  Future<bool> onLoadMore({String? fromDate, String? toDate}) async {
    await _onData(_meta?.currentPage, fromDate: fromDate, toDate: toDate);
    return true;
  }

  @override
  void dispose() {
    _deliveryService.cancelToken("EarningsProvider");
    super.dispose();
  }
}
