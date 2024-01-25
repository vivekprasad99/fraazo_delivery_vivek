import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/providers/user/details/document/document_upload_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class DocumentUploadingDialog extends StatefulWidget {
  final String filePath;
  final String documentType;
  const DocumentUploadingDialog(
      {required this.filePath, required this.documentType});

  @override
  _DocumentUploadingDialogState createState() =>
      _DocumentUploadingDialogState();
}

class _DocumentUploadingDialogState extends State<DocumentUploadingDialog> {
  final _documentUploadProvider = StateNotifierProvider.autoDispose<
      DocumentUploadProvider,
      AsyncValue<String>>((_) => DocumentUploadProvider());

  @override
  void initState() {
    super.initState();
    _uploadFile();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer(builder: (_, watch, __) {
            return watch(_documentUploadProvider).when(
              data: (String imageURL) => _uploadedWidget(imageURL),
              loading: () => const FDCircularLoader(
                progressColor: Colors.black54,
              ),
              error: (e, st) => FDErrorWidget(
                onPressed: _uploadFile,
                textColor: bgColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _uploadedWidget(String imageURL) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.green,
            radius: 40,
            child: Icon(
              Icons.done,
              size: 60,
              color: Colors.white,
            ),
          ),
          sizedBoxH20,
          if (widget.documentType == 'profile_pic')
            const Text("Profile Pic uploaded successfully.")
          else
            const Text("Document uploaded successfully.")
        ],
      ),
    );
  }

  Future _uploadFile() async {
    await context.read(_documentUploadProvider.notifier).uploadFile(
          widget.filePath,
          widget.documentType,
        );
    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => mounted ? RouteHelper.pop(args: true) : "");
  }
}
