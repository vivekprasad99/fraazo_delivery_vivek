import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/user/profile/store_list_model.dart';
import 'package:fraazo_delivery/providers/user/profile/store_selector_list_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import '../../../../utils/utils.dart';

class StoreSelectorListDialog extends StatefulWidget {
  final String cityCode;

  const StoreSelectorListDialog({Key? key, this.cityCode = ""})
      : super(key: key);

  @override
  _StoreSelectorListDialogState createState() =>
      _StoreSelectorListDialogState();
}

class _StoreSelectorListDialogState extends State<StoreSelectorListDialog> {
  final _storeSelectorListProvider = StateNotifierProvider.autoDispose<
      StoreSelectorListProvider,
      AsyncValue<List<Store>>>((_) => StoreSelectorListProvider());

  @override
  void initState() {
    super.initState();
    _getStoreList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select DarkStore",
                  style: commonTextStyle(color: Colors.white, fontSize: 18),
                ),
                const CloseButton(
                  color: Colors.white,
                ),
              ],
            ),
            _buildConsumer(),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumer() {
    return Consumer(builder: (_, watch, __) {
      return watch(_storeSelectorListProvider).when(
        data: (List<Store> storeList) => _buildStoreList(storeList),
        loading: () => const FDCircularLoader(),
        error: (e, __) => FDErrorWidget(
          onPressed: _getStoreList,
        ),
      );
    });
  }

  Widget _buildStoreList(List<Store> storeList) {
    return Expanded(
      child: ListView.separated(
        itemCount: storeList.length,
        itemBuilder: (_, int index) => _buildStoreItem(storeList[index]),
        separatorBuilder: (_, __) => const ContainerDivider(),
      ),
    );
  }

  Widget _buildStoreItem(Store store) {
    final List<String> darkStoreNameArray = store.storeName?.split("- ") ?? [];
    final String darkStoreLabel, darkStoreCityName;
    if (darkStoreNameArray.length == 3) {
      darkStoreLabel = "${darkStoreNameArray[0]}-${darkStoreNameArray[1]}- ";
      darkStoreCityName = darkStoreNameArray.last;
    } else {
      darkStoreLabel = store.storeName ?? "";
      darkStoreCityName = "";
    }
    return InkWell(
      onTap: () => RouteHelper.pop(args: store),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Text.rich(
          TextSpan(
            text: darkStoreLabel,
            style: commonTextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: darkStoreCityName,
                style: commonTextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _getStoreList() {
    context
        .read(_storeSelectorListProvider.notifier)
        .getStoreList(widget.cityCode);
  }
}
