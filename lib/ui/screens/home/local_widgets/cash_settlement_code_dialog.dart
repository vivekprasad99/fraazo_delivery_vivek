import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';

final settlementCodeProvider = FutureProvider.autoDispose(
      (ref) => ref.read(userProfileProvider.notifier).getCashSettlementCode());

class CashSettlementCodeDialog extends StatelessWidget {
  
  const CashSettlementCodeDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cash Settlement Code"),
      content: Consumer(
        builder: (_, watch, __) {
          return watch(settlementCodeProvider).when(
            data: (String? code) => code.isNullOrEmpty
                ? const Text("Settlement code is not generated.")
                : Text(
                    code!,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                  ),
            loading: () => const FDCircularLoader(),
            error: (_, __) => FDErrorWidget(
              onPressed: () => context.refresh(settlementCodeProvider),
            ),
          );
        },
      ),
      actions: [
        PrimaryButton(
          onPressed: () => RouteHelper.pop(),
          text: "DONE",
          width: 100,
          height: 35,
          fontSize: 14,
        )
      ],
    );
  }
}
