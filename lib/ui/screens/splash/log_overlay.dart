import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/api_logger_dialog.dart';

class LogOverlay extends StatefulWidget {
  const LogOverlay();

  @override
  _LogOverlayState createState() => _LogOverlayState();
}

class _LogOverlayState extends State<LogOverlay> {
  bool _isDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: RotatedBox(
        quarterTurns: 1,
        child: GestureDetector(
          child: Material(
            color: Colors.orange,
            child: InkWell(
              onTap: _showApiLoggerDialog,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  "API  Logs",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _showApiLoggerDialog() async {
    if (_isDialogVisible) {
      RouteHelper.maybePop();
    } else {
      _isDialogVisible = true;
      await showDialog(
        context: context,
        builder: (_) => const ApiLoggerDialog(),
      );
    }
    _isDialogVisible = false;
  }
}
