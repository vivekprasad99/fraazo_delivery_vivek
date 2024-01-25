import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/user/profile/shift_time_model.dart';
import 'package:fraazo_delivery/providers/user/profile/shift_time_list_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_textfield.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';


class ShiftTimeListDialog extends StatefulWidget {
  final String type;
  final String searchHit;

  const ShiftTimeListDialog({Key? key, required this.type, this.searchHit = ''})
      : super(key: key);

  @override
  _ShiftTimeListDialogState createState() => _ShiftTimeListDialogState();
}

class _ShiftTimeListDialogState extends State<ShiftTimeListDialog> {
  final _shiftTimeProvider = StateNotifierProvider(
    (_) => ShiftTimeListProvider(const AsyncLoading()),
  );
  final _searchTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getList();
    // _searchTEC.addListener(() {
    //   context
    //       .read(_idNameListProvider.notifier)
    //       .searchBankList(_searchTEC.text);
    // });
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
                  "Select ${widget.type}",
                  style: commonTextStyle(color: Colors.white, fontSize: 18),
                ),
                const CloseButton(),
              ],
            ),
            Visibility(
              visible: widget.type == 'Bank Name',
              child: FDTextField(
                labelText: widget.searchHit,
                textCapitalization: TextCapitalization.words,
                controller: _searchTEC,
              ),
            ),
            if (widget.type != 'Bank Name')
              _buildConsumer()
            else
              Expanded(child: _buildConsumer()),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumer() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(_shiftTimeProvider).when(
          data: (List<ShiftTime>? idNameList) =>
              _buildSelectorList(idNameList!),
          loading: () => const FDCircularLoader(),
          error: (e, __) => FDErrorWidget(
            onPressed: _getList,
          ),
        );
      },
    );
  }

  Widget _buildSelectorList(List<ShiftTime> idNameList) {
    return ListView.separated(
      itemCount: idNameList.length,
      shrinkWrap: true,
      itemBuilder: (_, int index) => _buildItem(idNameList[index]),
      separatorBuilder: (_, __) => const ContainerDivider(),
    );
  }

  Widget _buildItem(ShiftTime idName) {
    return InkWell(
      onTap: () => RouteHelper.pop(args: idName),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              idName.shift ?? "",
              style: commonTextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              idName.shiftTiming ?? "",
              style: commonTextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getList() {
    context.read(_shiftTimeProvider.notifier).getShiftTimeList();
  }
}
