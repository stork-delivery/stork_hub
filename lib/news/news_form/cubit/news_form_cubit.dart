import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/news/news_form/cubit/news_form_state.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class NewsFormCubit extends Cubit<NewsFormState> {
  NewsFormCubit({
    required this.repository,
    required int appId,
    News? news,
  }) : super(
          NewsFormState(
            appId: appId,
            id: news?.id,
            title: news?.title ?? '',
            content: news?.content ?? '',
          ),
        );

  final StorkRepository repository;

  void titleChanged(String value) {
    emit(state.copyWith(title: value));
  }

  void contentChanged(String value) {
    emit(state.copyWith(content: value));
  }

  Future<void> submit() async {
    if (state.id != null) {
      await repository.updateNews(
        appId: state.appId,
        id: state.id!,
        title: state.title,
        content: state.content,
      );
    } else {
      await repository.createNews(
        appId: state.appId,
        title: state.title,
        content: state.content,
      );
    }
  }
}
