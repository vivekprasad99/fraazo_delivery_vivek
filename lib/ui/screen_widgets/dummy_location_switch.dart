import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';

import 'dialogs/dummy_location_dialog.dart';

final _locationUpdateProvider = StateProvider.autoDispose<bool>(
    (_) => PrefHelper.getBool(PrefKeys.IS_TEMP_RIDER_LOCATION));

class DummyLocationSwitch extends StatefulWidget {
  const DummyLocationSwitch({Key? key}) : super(key: key);

  @override
  _DummyLocationSwitchState createState() => _DummyLocationSwitchState();
}

class _DummyLocationSwitchState extends State<DummyLocationSwitch> {
  Timer? _periodicUpdateTimer;

  Location? _riderLocation;

  @override
  void initState() {
    super.initState();
    if (Constants.isTestMode) {
      _checkLocation();
      _periodicUpdateTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _checkLocation(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Constants.isTestMode ? _buildLocationWidget() : const SizedBox();
  }

  Widget _buildLocationWidget() {
    return InkWell(
      onTap: _onBarTap,
      child: ColoredBox(
        color: AppColors.secondary,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
            child: Consumer(
              builder: (_, watch, __) {
                final isLocationEnabled = watch(_locationUpdateProvider).state;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Dummy Location: ${isLocationEnabled ? "ON" : "OFF"}",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        sizedBoxH2,
                        Text(
                          "Lat: ${_riderLocation?.latitude ?? "-"}, Lng: ${_riderLocation?.longitude ?? "-"}",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        )
                      ],
                    ),
                    Switch(
                      activeColor: AppColors.primary,
                      inactiveTrackColor: Colors.white30,
                      inactiveThumbColor: Colors.white30,
                      value: isLocationEnabled,
                      onChanged: (_) => _onSwitchTap(_locationUpdateProvider),
                    )
                  ],
                );
              },
            )),
      ),
    );
  }

  Future _checkLocation() async {
    _riderLocation = await Globals.getAssignedLocation();
    context.read(_locationUpdateProvider).state =
        PrefHelper.getBool(PrefKeys.IS_TEMP_RIDER_LOCATION);
  }

  void _onSwitchTap(AutoDisposeStateProvider<bool> locationUpdateProvider) {
    context.read(locationUpdateProvider).state =
        !context.read(locationUpdateProvider).state;
    PrefHelper.setValue(PrefKeys.IS_TEMP_RIDER_LOCATION,
        context.read(locationUpdateProvider).state);
  }

  Future _onBarTap() async {
    await RouteHelper.openDialog(const DummyLocationDialog());
    _checkLocation();
  }

  @override
  void dispose() {
    _periodicUpdateTimer?.cancel();
    super.dispose();
  }
}
