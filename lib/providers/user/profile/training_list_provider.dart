import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/training_list_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class TrainingListProvider
    extends StateNotifier<AsyncValue<TrainingListModel>> {
  TrainingListProvider(AsyncValue<TrainingListModel> state) : super(state);

  Future getTrainingList() async {
    state = const AsyncLoading();
    try {
      final TrainingListModel trainingList = await UserService().getTraining();
      state = AsyncData(trainingList);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st);
    }
  }
}
