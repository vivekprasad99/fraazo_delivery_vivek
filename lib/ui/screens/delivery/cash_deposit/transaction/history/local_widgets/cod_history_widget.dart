import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/cash_deposit/cod_history_model.dart';
import 'package:fraazo_delivery/models/cash_deposit/transaction_model.dart';
import 'package:fraazo_delivery/providers/cash_deposit/cod_history_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import '../../../local_widgets/transaction_item_widget.dart';

class CODHistoryWidget extends StatefulWidget {
  const CODHistoryWidget({Key? key}) : super(key: key);

  @override
  _CODHistoryWidgetState createState() => _CODHistoryWidgetState();
}

class _CODHistoryWidgetState extends State<CODHistoryWidget>
    with AutomaticKeepAliveClientMixin {
  final _codHistoryProvider = StateNotifierProvider.autoDispose<
          CodHistoryProvider, AsyncValue<List<Transaction>>>(
      (_) => CodHistoryProvider(const AsyncLoading()));

  @override
  void initState() {
    super.initState();
    _getCodHistory();
  }

  final dateTimeFormatter = DateFormatter();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (_, watch, __) {
        return watch(_codHistoryProvider).when(
          data: (List<Transaction> codHistory) => _buildCodList(codHistory),
          loading: () => const FDCircularLoader(
            progressColor: Colors.white,
          ),
          error: (e, _) => FDErrorWidget(
            onPressed: _getCodHistory,
            errorType: e,
            textColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildCodList(List<Transaction> paymentHistoryList) {
    if (paymentHistoryList.isEmpty) {
      return const Expanded(child: NoDataWidget());
    }
    return Expanded(
      child: Column(
        children: [
          Divider(
            color: dividerSetInCash.withOpacity(0.4),
          ),
          Expanded(
            child: ListView.builder(
              //padding: padding5,

              itemCount: paymentHistoryList.length,
              shrinkWrap: true,
              itemBuilder: (_, int index) {
                return Padding(
                  padding: EdgeInsets.zero,
                  child: TransactionItemWidget(
                    paymentHistoryList[index],
                    isOnline: false,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodWidget(CodHistory codHistoryData) {
    return InkWell(
      onTap: () {
        RouteHelper.push(Routes.COD_TRANSACTION_DETAIL, args: codHistoryData);
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          "Paid Via COD",
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          dateTimeFormatter.parseDateToDMY(codHistoryData.createdAt),
          style: const TextStyle(
            color: AppColors.black02,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                "₹ ${codHistoryData.amountCollected!}",
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.secondary,
              )
            ]),
            Text(
              codHistoryData.status == "SETTLED" ? 'Successful' : 'Failure',
              style: TextStyle(
                color: codHistoryData.status == "SETTLED"
                    ? AppColors.primary
                    : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _getCodHistory() {
    return context.read(_codHistoryProvider.notifier).getCodPaymentHistory();
  }

  @override
  bool get wantKeepAlive => true;
}
