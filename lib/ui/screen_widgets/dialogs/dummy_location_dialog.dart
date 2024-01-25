import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_textfield.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialog_button_bar.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class DummyLocationDialog extends StatefulWidget {
  const DummyLocationDialog({Key? key}) : super(key: key);

  @override
  State<DummyLocationDialog> createState() => _DummyLocationDialogState();
}

class _DummyLocationDialogState extends State<DummyLocationDialog> {
  final _latitudeTEC = TextEditingController();
  final _longitudeTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setLatLng();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter dummy location"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FDTextField(
            controller: _latitudeTEC,
            isNumber: true,
            isAutoFocus: true,
            labelText: "Latitude",
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}')),
            ],
          ),
          sizedBoxH15,
          FDTextField(
            controller: _longitudeTEC,
            isNumber: true,
            labelText: "Longitude",
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}')),
            ],
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                _latitudeTEC.text = "19.113826";
                _longitudeTEC.text = "72.891792";
              },
              child: const Text(
                "Reset",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            DialogButtonBar(
              onConfirmTap: _onConfirmTap,
              confirmText: "Save",
            ),
          ],
        ),
      ],
    );
  }

  Future _setLatLng() async {
    final Location riderLocation = await Globals.getAssignedLocation();
    _latitudeTEC.text = riderLocation.latitude.toString();
    _longitudeTEC.text = riderLocation.longitude.toString();
  }

  void _onConfirmTap() {
    if (_latitudeTEC.hasGtLength(4) && _longitudeTEC.hasGtLength(4)) {
      PrefHelper.setValue(
          PrefKeys.DUMMY_CURRENT_LATITUDE, double.parse(_latitudeTEC.text));
      PrefHelper.setValue(
          PrefKeys.DUMMY_CURRENT_LONGITUDE, double.parse(_longitudeTEC.text));
      RouteHelper.pop();
    } else {
      Toast.info("Please enter valid location details.");
    }
  }

  @override
  void dispose() {
    _latitudeTEC.dispose();
    _longitudeTEC.dispose();
    super.dispose();
  }
}
