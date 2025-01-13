import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

part 'artifacts_state.dart';

/// {@template artifacts_cubit}
/// A cubit that manages the state of the artifacts dialog
/// {@endtemplate}
class ArtifactsCubit extends Cubit<ArtifactsState> {
  /// {@macro artifacts_cubit}
  ArtifactsCubit({
    required StorkRepository storkRepository,
    required int appId,
    required int versionId,
  })  : _storkRepository = storkRepository,
        _appId = appId,
        _versionId = versionId,
        super(const ArtifactsState());

  final StorkRepository _storkRepository;
  final int _appId;
  final int _versionId;

  /// Loads the artifacts for the version
  Future<void> loadArtifacts() async {
    emit(state.copyWith(status: ArtifactsStatus.loading));

    try {
      final artifacts = await _storkRepository.listAppVersionArtifacts(
        _appId,
        _versionId,
      );
      emit(
        state.copyWith(
          status: ArtifactsStatus.loaded,
          artifacts: artifacts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ArtifactsStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}
