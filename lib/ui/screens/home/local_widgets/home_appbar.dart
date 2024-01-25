import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/misc/rider_login_hours_model.dart';
import 'package:fraazo_delivery/providers/location/location_provider.dart';
import 'package:fraazo_delivery/providers/misc/rider_login_hours_provider.dart';
import 'package:fraazo_delivery/services/know_notification/know_notification_service.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/flutter_switch.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final KnowNotificationService? knowNotificationService;
  const HomeAppbar({Key? key, required this.knowNotificationService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _selectedDay = DateFormatter().parseDateTimeToDate(DateTime.now());

    final _riderLoginHoursProvider = StateNotifierProvider<
        RiderLoginHoursProvider, AsyncValue<RiderLoginHoursModel>>(
      (_) => RiderLoginHoursProvider(const AsyncLoading()),
    );

    final riderLoginHoursProviderFuture = FutureProvider((ref) async {
      await ref
          .read(_riderLoginHoursProvider.notifier)
          .getLoginHours(_selectedDay, _selectedDay);

      return ref.read(_riderLoginHoursProvider).data?.value;
    });

    return Consumer(
      builder: (_, watch, __) {
        final locationProviderValue = watch(locationProvider);
        return FDAppBar(
          backgroundColor: primaryBlackColor,
          actions: [
            Stack(
              children: [
                IconButton(
                    onPressed: () {
                      PrefHelper.setValue(PrefKeys.IS_NEW_NOTIFICATION, false);
                      context.read(locationProvider.notifier).notify();
                      knowNotificationService!.openNotificationList();
                    },
                    icon: const Icon(
                      Icons.notifications_sharp,
                      color: Colors.white,
                    )),
                Visibility(
                  visible: PrefHelper.getBool(PrefKeys.IS_NEW_NOTIFICATION),
                  child: Positioned(
                      right: 15,
                      top: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: Colors.yellow, shape: BoxShape.circle),
                      )),
                )
              ],
            ),
            Container(
              child: locationProviderValue.isLoading
                  ? _loader()
                  : Consumer(
                      builder: (_, watch, __) {
                        return watch(riderLoginHoursProviderFuture).when(
                          data: (RiderLoginHoursModel? riderLoginHoursModel) {
                            final _riderLoginTimeHours =
                                riderLoginHoursModel?.data.loginHours ?? 0;
                            final int timeHrs = _riderLoginTimeHours.toInt();
                            final int timeMin =
                                ((_riderLoginTimeHours - timeHrs) * 60).toInt();
                            String _timeHrs = '$timeHrs';
                            String _timeMin = '$timeMin';
                            if (timeHrs < 10) {
                              _timeHrs = '0$timeHrs';
                            }

                            if (timeMin < 10) {
                              _timeMin = '0$timeMin';
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 16, bottom: 8),
                              child: FlutterSwitch(
                                activeColor: buttonColor,
                                inactiveColor: Colors.red,
                                activeText:
                                    "$_timeHrs:$_timeMin", //PrefHelper.getString(PrefKeys.LOGIN_HOURS),
                                value: locationProviderValue.isServiceRunning,
                                valueFontSize: 12.0,
                                height: 30,
                                //width: 86
                                width: MediaQuery.of(context).size.width * 0.20,
                                inactiveText: 'Offline',
                                borderRadius: 25.0,
                                showOnOff: true,
                                textStyle: commonPoppinsStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                onToggle: (_) {
                                  if (locationProviderValue.isServiceRunning) {
                                    locationProviderValue.stopService();
                                  } else {
                                    locationProviderValue.startService();
                                  }
                                },
                              ),
                            );
                          },
                          loading: _loader,
                          error: (e, _) => FDErrorWidget(
                            onPressed: () => context.refresh(
                              riderLoginHoursProviderFuture.future,
                            ), //riderLoginHoursProviderFuture,
                          ),
                        );
                      },
                    ),

              // : Consumer(
              //     builder: (_, watch, __) {
              //       debugPrint('Test>>>>><<<');
              //
              //       return watch(_riderLoginHoursProvider).when(
              //           data: (RiderLoginHoursModel riderLoginHoursModel) {
              //             final _riderLoginTimeHours =
              //                 riderLoginHoursModel.data.loginHours;
              //             final int timeHrs = _riderLoginTimeHours.toInt();
              //             final int timeMin =
              //                 ((_riderLoginTimeHours - timeHrs) * 60)
              //                     .toInt();
              //             String _timeHrs = '$timeHrs';
              //             String _timeMin = '$timeMin';
              //             if (timeHrs < 10) {
              //               _timeHrs = '0$timeHrs';
              //             }
              //
              //             if (timeMin < 10) {
              //               _timeMin = '0$timeMin';
              //             }
              //
              //             return Padding(
              //               padding:
              //                   const EdgeInsets.only(right: 16, bottom: 8),
              //               child: FlutterSwitch(
              //                 activeColor: buttonColor,
              //                 inactiveColor: Colors.red,
              //                 activeText:
              //                     "$_timeHrs:$_timeMin", //PrefHelper.getString(PrefKeys.LOGIN_HOURS),
              //                 value: locationProviderValue.isServiceRunning,
              //                 valueFontSize: 12.0,
              //                 height: 30,
              //                 //width: 86,
              //                 inactiveText: 'Offline',
              //                 borderRadius: 25.0,
              //                 showOnOff: true,
              //                 onToggle: (_) {
              //                   if (locationProviderValue
              //                       .isServiceRunning) {
              //                     locationProviderValue.stopService();
              //                   } else {
              //                     locationProviderValue.startService();
              //                   }
              //                 },
              //               ),
              //             );
              //           },
              //           loading: () => const FDCircularLoader(
              //                 progressColor: Colors.white,
              //               ),
              //           error: (e, _) => FDErrorWidget(
              //                 onPressed: () => _getRiderLoginHours(
              //                   context,
              //                   _selectedDay,
              //                   _selectedDay,
              //                 ),
              //               ));
              //     },
              //
              //     /*Padding(
              //     padding: const EdgeInsets.only(right: 16, bottom: 8),
              //     child: FlutterSwitch(
              //       activeColor: buttonColor,
              //       inactiveColor: Colors.red,
              //       activeText:
              //           '', //PrefHelper.getString(PrefKeys.LOGIN_HOURS),
              //       value: locationProviderValue.isServiceRunning,
              //       valueFontSize: 12.0,
              //       height: 30,
              //       width: 86,
              //       inactiveText: 'Offline',
              //       borderRadius: 25.0,
              //       showOnOff: true,
              //       onToggle: (_) {
              //         if (locationProviderValue.isServiceRunning) {
              //           locationProviderValue.stopService();
              //         } else {
              //           locationProviderValue.startService();
              //         }
              //       },
              //     ),
              //   )*/
              //   ),
            )
          ],
        );
      },
    );
  }

  Widget _loader() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
