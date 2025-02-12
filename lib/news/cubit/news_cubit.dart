import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

part 'news_state.dart';

const _perPage = 10;

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
        perPage: _perPage + 1,
        page: 1,
      );
      emit(
        state.copyWith(
          status: NewsStatus.loaded,
          news: news,
          page: 1,
          hasMore: news.length >= _perPage,
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

  /// Loads more news, appending to the existing list
  Future<void> loadMoreNews() async {
    if (!state.hasMore || state.status == NewsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: NewsStatus.loading));

    try {
      final nextPage = state.page + 1;
      final news = await _storkRepository.listNews(
        appId: _appId,
        perPage: _perPage,
        page: nextPage,
      );

      emit(
        state.copyWith(
          status: NewsStatus.loaded,
          news: [...state.news, ...news],
          page: nextPage,
          hasMore: news.length >= _perPage,
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
