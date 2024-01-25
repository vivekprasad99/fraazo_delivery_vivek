import 'package:flutter/material.dart';
import 'package:fraazo_delivery/models/delivery/delivery_step.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:timelines/timelines.dart';

class TimelineWidget extends StatelessWidget {
  final List<DeliveryStep> deliveryStepsList;
  final int currentPosition;
  const TimelineWidget(this.deliveryStepsList, this.currentPosition);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: FixedTimeline.tileBuilder(
        builder: TimelineTileBuilder.connected(
          itemCount: deliveryStepsList.length,
          nodePositionBuilder: (_, int index) => 0,
          indicatorBuilder: (_, index) => index < currentPosition
              ? _buildCheckedWidget()
              : _buildOutlinedWidget(),
          connectorBuilder: (_, index, __) => index < currentPosition
              ? const SolidLineConnector(
                  color: Colors.green,
                )
              : const DashedLineConnector(
                  color: Colors.black38,
                  gap: 4,
                ),
          firstConnectorBuilder: (_) => const DashedLineConnector(
            color: Colors.transparent,
          ),
          lastConnectorBuilder: (_) => const DashedLineConnector(
            color: Colors.transparent,
          ),
          contentsBuilder: (_, index) => _buildTimelineCard(index),
        ),
      ),
    ));
  }

  Widget _buildTimelineCard(int index) {
    final deliveryStep = deliveryStepsList[index];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: index == currentPosition
              ? Border.all(
                  color: deliveryStep.order?.orderStatus == Constants.OS_CREATED
                      ? Colors.black
                      : Colors.green,
                  width: 2.5,
                )
              : null,
          boxShadow: const [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    deliveryStep.label!,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (index == currentPosition && deliveryStep.isStarted)
                    const Text(
                      "STARTED",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                ],
              ),
              sizedBoxH5,
              Text(
                deliveryStep.description!,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckedWidget() {
    return const CircleAvatar(
      radius: 11,
      backgroundColor: Colors.green,
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildOutlinedWidget() {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white30,
        border: Border.all(color: Colors.green.shade800),
      ),
    );
  }
}
