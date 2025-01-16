import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

part 'itchio_data_state.dart';

/// {@template itchio_data_cubit}
/// A cubit that manages the state of the ItchIO data dialog
/// {@endtemplate}
class ItchIODataCubit extends Cubit<ItchIODataState> {
  /// {@macro itchio_data_cubit}
  ItchIODataCubit({
    required StorkRepository storkRepository,
    required int appId,
  })  : _storkRepository = storkRepository,
        _appId = appId,
        super(const ItchIODataState());

  final StorkRepository _storkRepository;
  final int _appId;

  /// Loads the ItchIO data for the app
  Future<void> loadItchIOData() async {
    emit(state.copyWith(status: ItchIODataStatus.loading));

    try {
      final data = await _storkRepository.getAppItchIOData(_appId);
      emit(
        state.copyWith(
          status: ItchIODataStatus.loaded,
          data: data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ItchIODataStatus.error,
          error: 'Failed to load ItchIO data',
        ),
      );
    }
  }

  /// Updates the ItchIO data for the app
  Future<void> updateItchIOData({
    required String buttlerKey,
    required String itchIOUsername,
    required String itchIOGameName,
  }) async {
    emit(state.copyWith(status: ItchIODataStatus.saving));

    try {
      final data = await _storkRepository.updateAppItchIOData(
        appId: _appId,
        buttlerKey: buttlerKey,
        itchIOUsername: itchIOUsername,
        itchIOGameName: itchIOGameName,
      );
      emit(
        state.copyWith(
          status: ItchIODataStatus.loaded,
          data: data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ItchIODataStatus.error,
          error: 'Failed to save ItchIO data',
        ),
      );
    }
  }
}
