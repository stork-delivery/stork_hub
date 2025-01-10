import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/app_details/cubit/app_details_state.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

/// {@template app_details_cubit}
/// A cubit that manages the state of the app details page
/// {@endtemplate}
class AppDetailsCubit extends Cubit<AppDetailsState> {
  /// {@macro app_details_cubit}
  AppDetailsCubit({
    required StorkRepository storkRepository,
    required int appId,
  })  : _storkRepository = storkRepository,
        _appId = appId,
        super(const AppDetailsState());

  final StorkRepository _storkRepository;
  final int _appId;

  /// Loads the app details
  Future<void> loadApp() async {
    emit(state.copyWith(status: AppDetailsStatus.loading));

    try {
      final app = await _storkRepository.getApp(_appId);
      emit(
        state.copyWith(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AppDetailsStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  /// Updates the app
  Future<void> updateApp({
    String? name,
    bool? publicMetadata,
  }) async {
    if (state.app == null) return;

    emit(state.copyWith(status: AppDetailsStatus.loading));

    try {
      final app = await _storkRepository.updateApp(
        id: _appId,
        name: name,
        publicMetadata: publicMetadata,
      );
      emit(
        state.copyWith(
          status: AppDetailsStatus.loaded,
          app: app,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AppDetailsStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}
