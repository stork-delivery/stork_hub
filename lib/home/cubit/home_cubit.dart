import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/home/cubit/home_state.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required StorkRepository storkRepository,
  })  : _storkRepository = storkRepository,
        super(const HomeState());

  final StorkRepository _storkRepository;

  Future<void> loadApps() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final apps = await _storkRepository.listApps();
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          apps: apps,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> addApp(String name) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final app = await _storkRepository.createApp(name: name);
      final currentApps = List<App>.from(state.apps)..add(app);

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          apps: currentApps,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> removeApp(App app) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      await _storkRepository.removeApp(app.id);
      final currentApps = List<App>.from(state.apps)
        ..removeWhere(
          (element) => element.id == app.id,
        );

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          apps: currentApps,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}
