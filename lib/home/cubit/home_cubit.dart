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
    final currentApps = List<App>.from(state.apps);
    // Generate a new ID (in a real app, this would come from the backend)
    final newId = currentApps.isEmpty ? 1 : currentApps.last.id + 1;

    currentApps.add(App(id: newId, name: name));

    emit(state.copyWith(apps: currentApps));
  }

  Future<void> removeApp(App app) async {
    final currentApps = List<App>.from(state.apps)
      ..removeWhere(
        (element) => element.id == app.id,
      );

    emit(state.copyWith(apps: currentApps));
  }
}
