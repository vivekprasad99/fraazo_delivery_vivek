import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/misc/api_logger_model.dart';
import 'package:fraazo_delivery/providers/misc/api_logger_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/colored_sizedbox.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class ApiLoggerDialog extends StatefulWidget {
  const ApiLoggerDialog({Key? key}) : super(key: key);

  @override
  _ApiLoggerDialogState createState() => _ApiLoggerDialogState();
}

class _ApiLoggerDialogState extends State<ApiLoggerDialog> {
  final _apiLoggerProvider = ApiLoggerProvider();
  final _scrollController = ScrollController();

  late final Timer _refreshTimer;
  bool _canScrollToBottom = true;

  @override
  void initState() {
    super.initState();

    _apiLoggerProvider.getApiLoggerList();

    Future.delayed(const Duration(milliseconds: 800), () {
      _scrollToBottom(_canScrollToBottom);
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      // As two threads maintained it needs to be fetched every 2 sec manually
      _apiLoggerProvider.getApiLoggerList();
      _scrollToBottom(_canScrollToBottom);
    });

    _setScrollControllerListener();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.secondary,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                "API Logs",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white),
              ),
            ),
            _buildLoggerList(),
            ColoredSizedBox(
              width: double.infinity,
              color: Colors.blueGrey,
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _apiLoggerProvider.clearLogs,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("CLEAR"),
                      ),
                    ),
                    InkWell(
                      onTap: () => _scrollToBottom(true),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("SCROLL DOWN"),
                      ),
                    ),
                    const InkWell(
                      onTap: RouteHelper.pop,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("CLOSE"),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoggerList() {
    return Expanded(
      child: StreamBuilder<List<ApiLoggerModel>>(
        stream: _apiLoggerProvider.stream,
        builder: (_, snapshot) {
          final List<ApiLoggerModel> apiLoggerList = snapshot.data ?? [];
          if (apiLoggerList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Waiting for logs..."),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is UserScrollNotification) {
                _canScrollToBottom = false;
              }
              return true;
            },
            child: Scrollbar(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: apiLoggerList.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (_, int index) =>
                    _buildLoggerItem(apiLoggerList[index]),
                separatorBuilder: (_, __) => const Divider(
                  thickness: 2,
                  color: Colors.black38,
                  height: 10,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoggerItem(ApiLoggerModel apiLogger) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 3),
                color: Colors.blueAccent.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text(
                  apiLogger.requestMethod,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              sizedBoxW5,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      [200, 201, 202, 203, 204].contains(apiLogger.statusCode)
                          ? Colors.green
                          : Colors.red,
                ),
                child: Text(
                  apiLogger.statusCode.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(apiLogger.logTime)
            ],
          ),
          sizedBoxH8,
          _buildTextData("Path:", apiLogger.pathURL),
          sizedBoxH8,
          _buildTextData("Request:", apiLogger.requestData),
          sizedBoxH8,
          _buildTextData("Response:", apiLogger.responseData),
        ],
      ),
    );
  }

  Widget _buildTextData(String label, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(data)
      ],
    );
  }

  void _setScrollControllerListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          Future.delayed(const Duration(milliseconds: 50), () {
            _canScrollToBottom = true;
          });
        }
      }
    });
  }

  void _scrollToBottom(bool canScroll) {
    if (_scrollController.hasClients && canScroll) {
      final bottomOffset = _scrollController.position.maxScrollExtent + 300;
      _scrollController.animateTo(
        bottomOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshTimer.cancel();
    super.dispose();
  }
}
