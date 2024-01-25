import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/upload_task_images_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/colored_sizedbox.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/document_picker_dialog.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class UploadTaskImagesDialog extends StatefulWidget {
  final List<OrderSeq>? orderList;
  const UploadTaskImagesDialog({Key? key, required this.orderList})
      : super(key: key);

  @override
  _UploadTaskImagesDialogState createState() => _UploadTaskImagesDialogState();
}

class _UploadTaskImagesDialogState extends State<UploadTaskImagesDialog> {
  late final _uploadTaskImagesProvider =
      StateNotifierProvider((_) => UploadTaskImagesProvider());

  final Map<int, String> _imagePathsMap = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload all order images",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            sizedBoxH15,
            Flexible(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                children: List.generate(
                    widget.orderList!.length, _buildTaskImageCard),
              ),
            ),
            sizedBoxH20,
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryButton(
                text: "Upload",
                width: 90,
                height: 38,
                fontSize: 14,
                onPressed: _onUploadAllTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskImageCard(int index) {
    return InkWell(
      onTap: () => _onSelectImageTap(index),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            color: Colors.black12,
          ),
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ColoredSizedBox(
              color: Colors.grey.shade200,
              width: double.infinity,
              height: 22,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Order ${index + 1} - #${widget.orderList![index].orderNumber}",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (_imagePathsMap[index] != null)
              Expanded(
                child: Image.file(
                  File(
                    _imagePathsMap[index]!,
                  ),
                ),
              )
            else ...[
              const Icon(
                Icons.image,
                size: 35,
                color: Colors.grey,
              ),
              Container(
                width: double.infinity,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                ),
                child: const Text(
                  "Select Image",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  void _onSelectImageTap(int index) {
    showDialog(
      context: context,
      builder: (_) => DocumentPickerDialog(
        onImagePicked: (String path) {
          setState(() {
            _imagePathsMap[index] = path;
          });
        },
      ),
    );
  }

  Future _onUploadAllTap() async {
    if (_imagePathsMap.length != widget.orderList!.length) {
      Toast.normal("Please upload all images", align: Alignment.center);
    } else {
      final cancelFunc = Toast.popupLoading();
      try {
        for (int i = 0; i < _imagePathsMap.length; i++) {
          await context
              .read(_uploadTaskImagesProvider.notifier)
              .uploadImage(_imagePathsMap[i]!, widget.orderList![0].id);
        }

        Toast.normal("Images are uploaded successfully.");
        RouteHelper.pop(args: true);
      } finally {
        cancelFunc();
      }
    }
  }
}
