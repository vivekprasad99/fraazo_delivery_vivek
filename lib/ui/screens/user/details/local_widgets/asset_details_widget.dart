import 'package:flutter/material.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/asset_assigned_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/asset_return_widget.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import '../../../../screen_widgets/dialogs/asset_assign_dialog.dart';

class AssetDetailsWidget extends StatefulWidget {
  const AssetDetailsWidget({Key? key}) : super(key: key);

  @override
  _AssetDetailsWidgetState createState() => _AssetDetailsWidgetState();
}

class _AssetDetailsWidgetState extends State<AssetDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: FDAppBar(
        titleText: "Asset Management",
        actions: [
          TextButton(
              onPressed: () {
                _openAssetAssignDialog();
              },
              child: TextView(
                  title: 'Check New Request',
                  textStyle: commonTextStyle(color: Colors.white)))
        ],
      ),
      body: Column(
        children: [
          Divider(
            color: dividerSetInCash.withOpacity(0.4),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: EdgeInsets.zero,
                      indicator: const BoxDecoration(
                        color: btnLightGreen,
                      ),
                      //labelColor: Colors.black,
                      //unselectedLabelColor: Colors.black,
                      tabs: [
                        Container(
                          alignment: Alignment.center,
                          color: bgColor,
                          child: Text(
                            "Assigned",
                            style: commonTextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          color: bgColor,
                          child: Text(
                            "Return",
                            style: commonTextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  sizedBoxH20,
                  const Expanded(
                    child: TabBarView(
                      children: [AssetAssignedWidget(), AssetReturnWidget()],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.grey)],
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6)),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(child: Text("Assigned")),
                Tab(child: Text("Return")),
              ],
            ),
          ),
          sizedBoxH5,
          const SizedBox(
            height: 225,
            child: TabBarView(
              children: [AssetAssignedWidget(), AssetReturnWidget()],
            ),
          )
        ],
      ),
    );
  }

  Future _openAssetAssignDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const AssetAssignDialog(),
    );
  }
}
