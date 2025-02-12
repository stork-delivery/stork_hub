import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/news/news_form/cubit/news_form_cubit.dart';
import 'package:stork_hub/news/news_form/cubit/news_form_state.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

void main() {
  group('NewsFormCubit', () {
    late StorkRepository repository;
    late News mockNews;

    setUp(() {
      repository = MockStorkRepository();
      mockNews = News(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        createdAt: DateTime.now(),
      );
    });

    test('initial state is correct', () {
      final cubit = NewsFormCubit(repository: repository, appId: 1);
      expect(cubit.state, equals(const NewsFormState(appId: 1)));
    });

    test('initial state with news is correct', () {
      final news = News(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        createdAt: DateTime.now(),
      );

      final cubit = NewsFormCubit(
        repository: repository,
        appId: 1,
        news: news,
      );

      expect(
        cubit.state,
        equals(
          const NewsFormState(
            appId: 1,
            id: 1,
            title: 'Test Title',
            content: 'Test Content',
          ),
        ),
      );
    });

    blocTest<NewsFormCubit, NewsFormState>(
      'titleChanged emits new state with updated title',
      build: () => NewsFormCubit(repository: repository, appId: 1),
      act: (cubit) => cubit.titleChanged('New Title'),
      expect: () => [
        const NewsFormState(appId: 1, title: 'New Title'),
      ],
    );

    blocTest<NewsFormCubit, NewsFormState>(
      'contentChanged emits new state with updated content',
      build: () => NewsFormCubit(repository: repository, appId: 1),
      act: (cubit) => cubit.contentChanged('New Content'),
      expect: () => [
        const NewsFormState(appId: 1, content: 'New Content'),
      ],
    );

    group('submit', () {
      test('calls createNews when id is null', () async {
        when(
          () => repository.createNews(
            appId: any(named: 'appId'),
            title: any(named: 'title'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => mockNews);

        final cubit = NewsFormCubit(repository: repository, appId: 1)
          ..titleChanged('New Title')
          ..contentChanged('New Content');

        await cubit.submit();

        verify(
          () => repository.createNews(
            appId: 1,
            title: 'New Title',
            content: 'New Content',
          ),
        ).called(1);
      });

      test('calls updateNews when id is not null', () async {
        when(
          () => repository.updateNews(
            appId: any(named: 'appId'),
            id: any(named: 'id'),
            title: any(named: 'title'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => mockNews);

        final news = News(
          id: 1,
          title: 'Original Title',
          content: 'Original Content',
          createdAt: DateTime.now(),
        );

        final cubit = NewsFormCubit(
          repository: repository,
          appId: 1,
          news: news,
        )
          ..titleChanged('Updated Title')
          ..contentChanged('Updated Content');

        await cubit.submit();

        verify(
          () => repository.updateNews(
            appId: 1,
            id: 1,
            title: 'Updated Title',
            content: 'Updated Content',
          ),
        ).called(1);
      });
    });
  });
}
