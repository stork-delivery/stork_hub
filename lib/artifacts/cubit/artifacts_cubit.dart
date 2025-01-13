import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

part 'artifacts_state.dart';

/// Signature for the function that gets a save location from the user
typedef GetSaveLocation = Future<file_selector.FileSaveLocation?> Function({
  String? suggestedName,
});

/// {@template artifacts_cubit}
/// A cubit that manages the state of the artifacts dialog
/// {@endtemplate}
class ArtifactsCubit extends Cubit<ArtifactsState> {
  /// {@macro artifacts_cubit}
  ArtifactsCubit({
    required StorkRepository storkRepository,
    required int appId,
    required String versionName,
    GetSaveLocation? getSaveLocation,
  })  : _storkRepository = storkRepository,
        _appId = appId,
        _versionName = versionName,
        _getSaveLocation = getSaveLocation ?? file_selector.getSaveLocation,
        super(const ArtifactsState());

  final StorkRepository _storkRepository;
  final int _appId;
  final String _versionName;
  final GetSaveLocation _getSaveLocation;

  /// Loads the artifacts for the version
  Future<void> loadArtifacts() async {
    emit(state.copyWith(status: ArtifactsStatus.loading));

    try {
      final artifacts = await _storkRepository.listAppVersionArtifacts(
        _appId,
        _versionName,
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

  /// Downloads an artifact
  Future<void> downloadArtifact(String platform, String fileName) async {
    final location = await _getSaveLocation(
      suggestedName: fileName,
    );

    if (location == null) {
      return;
    }

    emit(state.copyWith(status: ArtifactsStatus.downloading));

    try {
      final path = location.path;
      final file = File(path);
      await _storkRepository.downloadArtifact(
        _appId,
        _versionName,
        platform,
        file,
      );

      emit(
        state.copyWith(
          status: ArtifactsStatus.loaded,
          downloadedFile: path,
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
