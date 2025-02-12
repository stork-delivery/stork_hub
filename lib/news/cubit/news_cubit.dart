import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

part 'news_state.dart';

/// {@template news_cubit}
/// A cubit that manages the state of the news dialog
/// {@endtemplate}
class NewsCubit extends Cubit<NewsState> {
  /// {@macro news_cubit}
  NewsCubit({
    required StorkRepository storkRepository,
    required int appId,
  })  : _storkRepository = storkRepository,
        _appId = appId,
        super(const NewsState());

  final StorkRepository _storkRepository;
  final int _appId;

  int get appId => _appId;

  /// Loads the news for the version
  Future<void> loadNews() async {
    emit(state.copyWith(status: NewsStatus.loading));

    try {
      final news = await _storkRepository.listNews(
        appId: _appId,
        perPage: 10,
        page: 1, // TODO(erick): paginate this
      );
      emit(
        state.copyWith(
          status: NewsStatus.loaded,
          news: news,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NewsStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}
