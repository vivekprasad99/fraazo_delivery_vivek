import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialog_button_bar.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  final bool isAcceptMode;
  const TermsAndConditionsDialog({
    Key? key,
    this.isAcceptMode = true,
  }) : super(key: key);

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  bool _isPageLoaded = false;

  final String _tncPath = "https://fraazo.com/public/rider_app_tnc.html";

  late final String _pageURL = _tncPath.contains("http")
      ? _tncPath
      : "${APIs.BASE_URL}${_tncPath.replaceAll("/v1", "")}";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(!widget.isAcceptMode),
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(15),
        title: Container(
          color: bgColor,
          padding: padding8,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.isAcceptMode
                      ? "Please accept Terms and Conditions to proceed"
                      : "Terms and Conditions",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              if (!widget.isAcceptMode)
                const CloseButton(
                  color: Colors.white,
                ),
            ],
          ),
        ),
        titlePadding: EdgeInsets.zero,
        content: IndexedStack(
          index: _isPageLoaded ? 0 : 1,
          children: [
            WebView(
              initialUrl: _pageURL,
              onPageStarted: (_) {
                setState(() {
                  _isPageLoaded = false;
                });
              },
              onPageFinished: (_) {
                setState(() {
                  _isPageLoaded = true;
                });
              },
            ),
            const Center(
              child: CircularProgressIndicator(),
            )
          ],
        ),
        contentPadding: EdgeInsets.zero,
        actions: [
          if (widget.isAcceptMode) ...[
            DialogButtonBar(
              confirmText: "ACCEPT",
              onConfirmTap: _onAcceptTap,
              cancelText: "Exit App",
              onCancelTap: () => RouteHelper.exitApp(),
            ),
          ]
        ],
      ),
    );
  }

  void _onAcceptTap() {
    // RouteHelper.pop();
    Toast.popupLoadingFuture(
      future: () => context.read(userProfileProvider.notifier).acceptTNC(),
      onSuccess: (_) => RouteHelper.pop(),
    );
  }
}
