import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';

class DateFilterDialog extends StatefulWidget {
  final Map<String, String> selectedDatesFormatted;
  final Map<String, DateTime> selectedDateTimes;
  final VoidCallback? onUpdate;
  const DateFilterDialog({
    required this.selectedDatesFormatted,
    required this.selectedDateTimes,
    this.onUpdate,
  });
  @override
  _DateFilterDialogState createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<DateFilterDialog> {
  final Map<String, String> _tempSelectedDatesFormatted = {};
  final Map<String, DateTime> _tempSelectedDateTimes = {};

  @override
  void initState() {
    super.initState();
    _tempSelectedDatesFormatted.addAll(widget.selectedDatesFormatted);
    _tempSelectedDateTimes.addAll(widget.selectedDateTimes);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select date range",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            sizedBoxH10,
            _buildDateTile("Start Date"),
            sizedBoxH10,
            _buildDateTile("End Date"),
            sizedBoxH5,
            _buildFilterButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        sizedBoxH5,
        InkWell(
          onTap: () => _onDateTap(label),
          child: Container(
            padding: const EdgeInsets.all(12),
            width: 180,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black54)),
            child: Text(_tempSelectedDatesFormatted[label] ?? "Select date"),
          ),
        )
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        TextButton(
          onPressed: _onClear,
          child: const Text("CLEAR", style: TextStyle(color: Colors.black)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => RouteHelper.pop(),
          child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _onFilter,
          child: const Text(
            "FILTER",
          ),
        ),
      ],
    );
  }

  Future _onDateTap(String label) async {
    if (label == Constants.DH_END_DATE &&
        _tempSelectedDateTimes[Constants.DH_START_DATE] == null) {
      return Toast.normal("Please select start date first.");
    }
    final DateTime? selectedDateTime = await showDatePicker(
        context: context,
        firstDate: label == Constants.DH_END_DATE
            ? _tempSelectedDateTimes[Constants.DH_START_DATE]!
            : DateTime(2021, 6),
        initialDate: _tempSelectedDateTimes[label] ?? DateTime.now(),
        lastDate: DateTime.now());

    if (selectedDateTime != null) {
      setState(() {
        _tempSelectedDateTimes[label] = selectedDateTime;
        _tempSelectedDatesFormatted[label] =
            DateFormatter().parseDateTimeToDate(selectedDateTime);
      });
    }
  }

  void _onClear() {
    widget.selectedDatesFormatted.clear();
    widget.selectedDateTimes.clear();
    widget.onUpdate?.call();
    RouteHelper.pop();
  }

  void _onFilter() {
    widget.selectedDatesFormatted.addAll(_tempSelectedDatesFormatted);
    widget.selectedDateTimes.addAll(_tempSelectedDateTimes);
    widget.onUpdate?.call();
    RouteHelper.pop();
  }
}
