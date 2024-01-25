import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/api/apis.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewTermsAndConditionsScreen extends StatefulWidget {
  final bool isAcceptMode;
  const NewTermsAndConditionsScreen({
    Key? key,
    this.isAcceptMode = true,
  }) : super(key: key);

  @override
  State<NewTermsAndConditionsScreen> createState() =>
      _NewTermsAndConditionsScreenState();
}

class _NewTermsAndConditionsScreenState
    extends State<NewTermsAndConditionsScreen> {
  bool _isPageLoaded = false;

  final String _tncPath = "https://fraazo.com/public/rider_app_tnc.html";

  late final String _pageURL = _tncPath.contains("http")
      ? _tncPath
      : "${APIs.BASE_URL}${_tncPath.replaceAll("/v1", "")}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(
        backgroundColor: bgColor,
        titleText: "Terms & Conditions",
      ),
      body: Column(
        children: [
          Divider(
            color: dividerSetInCash.withOpacity(0.4),
          ),
          Expanded(
            child: IndexedStack(
              index: _isPageLoaded ? 0 : 1,
              children: [
                WebView(
                  backgroundColor: bgColor,
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
                  child: CircularProgressIndicator(color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
