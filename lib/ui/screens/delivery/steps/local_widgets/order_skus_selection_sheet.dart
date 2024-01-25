import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/delivery_items_model.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_items_provider.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/horizontal_product_card.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';

class OrderSkusSelectionSheet extends StatefulWidget {
  final OrderSeq order;
  const OrderSkusSelectionSheet(this.order, {Key? key}) : super(key: key);

  @override
  _OrderSkusSelectionSheetState createState() =>
      _OrderSkusSelectionSheetState();
}

class _OrderSkusSelectionSheetState extends State<OrderSkusSelectionSheet> {
  final _orderItemsProvider = StateNotifierProvider.autoDispose<
      OrderItemsProvider, AsyncValue<OrderItems>>((_) => OrderItemsProvider());

  final Set<int> _selectedSkus = {};

  @override
  void initState() {
    super.initState();
    _getOrderItems();
    _checkAndRemoveIdIfItsThere();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  _buildSKUList(),
                ],
              ),
              _buildSubmitButton(),
              if (Constants.isTestMode) ...[
                Positioned(
                  bottom: 80,
                  right: 20,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => RouteHelper.pop(args: true),
                    child: const Text("Skip"),
                  ),
                ),
              ]
            ],
          ),
        ));
  }

  Widget _buildHeader() {
    return Material(
      elevation: 5,
      color: AppColors.primary,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(6),
        topRight: Radius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please select packed order items",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Order #${widget.order.orderNumber}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _getOrderItems,
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSKUList() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(_orderItemsProvider).when(
          data: (OrderItems orderItems) => Expanded(
            child: ListView.separated(
              itemCount: orderItems.lineItems.length,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemBuilder: (_, int index) =>
                  _buildSkuItem(orderItems.lineItems[index]),
              separatorBuilder: (_, __) => sizedBoxH8,
            ),
          ),
          loading: () => const FDCircularLoader(),
          error: (e, __) => FDErrorWidget(
            onPressed: _getOrderItems,
            errorType: e,
            shouldHideErrorToast: false,
          ),
        );
      },
    );
  }

  Widget _buildSkuItem(LineItem lineItem) {
    final bool isSelected = _selectedSkus.contains(lineItem.id);
    return InkWell(
      onTap: () => _onSKUTap(lineItem.id!),
      child: Stack(
        children: [
          Material(
            elevation: 1,
            // color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: HorizontalProductCard(lineItem),
            ),
          ),
          if (isSelected)
            const Positioned(
              bottom: 5,
              right: 5,
              child: Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Consumer(
        builder: (_, watch, __) {
          final asyncState = watch(_orderItemsProvider);
          bool isLoading = true;
          int totalSkuCount = 0;
          num orderAmount = 0;
          if (asyncState is AsyncData) {
            final OrderItems? orderItems = asyncState.data?.value;
            totalSkuCount = orderItems?.lineItems.length ?? 0;
            orderAmount = orderItems?.nettAmount ?? 0;
            isLoading = false;
          }
          return PrimaryButton(
            onPressed: isLoading
                ? null
                : () => _onSubmitTap(totalSkuCount, orderAmount),
            elevation: 5,
            color: !isLoading && totalSkuCount == _selectedSkus.length
                ? AppColors.primary
                : AppColors.secondary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Selected items: ${_selectedSkus.length}/$totalSkuCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    "SUBMIT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _getOrderItems() {
    context
        .read(_orderItemsProvider.notifier)
        .getOrderLineItems(widget.order.id!);
  }

  void _onSKUTap(int index) {
    // Anyways we refreshing whole list.
    setState(() {
      if (_selectedSkus.contains(index)) {
        _selectedSkus.remove(index);
      } else {
        _selectedSkus.add(index);
      }
    });
  }

  void _onSubmitTap(int totalSkuCount, num orderAmount) {
    if (_selectedSkus.length == totalSkuCount) {
      widget.order.amount = orderAmount;
      context
          .read(orderUpdateProvider.notifier)
          .updateOrderDetails(widget.order);
      RouteHelper.pop(args: true);
    } else {
      Toast.normal("Please select all of the items to proceed.");
    }
  }

  void _checkAndRemoveIdIfItsThere() {
    context.read(_orderItemsProvider.notifier).addListener((state) {
      if (state is AsyncData) {
        final Set<int> tempSelectedSet = {};
        tempSelectedSet.addAll(_selectedSkus);
        _selectedSkus.clear();
        for (final lineItem in state.data?.value.lineItems ?? []) {
          if (tempSelectedSet.contains(lineItem.id)) {
            _selectedSkus.add(lineItem.id);
          }
        }
      }
    });
  }
}
