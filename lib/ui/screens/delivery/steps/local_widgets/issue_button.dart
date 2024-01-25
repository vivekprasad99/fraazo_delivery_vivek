import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class IssueButton extends StatelessWidget {
  final Task? task;
  const IssueButton({Key? key, this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.only(left: 5, top: 3, bottom: 3, right: 5),
          // width: 60,
          // height: 24,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xffB3B3B3),
            ),
          ),
          child: TextView(
            title: "Issues",
            textStyle: commonTextStyle(
              fontSize: 14,
              color: const Color(0xffC8C8C8),
            ),
          ),
        ),
      ),
      onTap: () {
        RouteHelper.push(Routes.ORDER_ISSUE_SCREEN, args: task);
      },
    );
  }
}
