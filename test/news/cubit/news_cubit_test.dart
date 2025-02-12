// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/news/news.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

void main() {
  group('NewsCubit', () {
    late StorkRepository repository;
    late NewsCubit cubit;
    final now = DateTime.now();

    final testNews = [
      News(
        id: 1,
        title: 'Test News 1',
        content: 'Test Content 1',
        createdAt: now,
      ),
      News(
        id: 2,
        title: 'Test News 2',
        content: 'Test Content 2',
        createdAt: now,
      ),
    ];

    setUp(() {
      repository = MockStorkRepository();
      cubit = NewsCubit(
        storkRepository: repository,
        appId: 1,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state, equals(NewsState()));
    });

    test('appId returns correct value', () {
      expect(cubit.appId, equals(1));
    });

    group('loadNews', () {
      blocTest<NewsCubit, NewsState>(
        'emits loaded state with news when successful',
        setUp: () {
          when(
            () => repository.listNews(
              appId: 1,
              perPage: 11,
              page: 1,
            ),
          ).thenAnswer((_) async => testNews);
        },
        build: () => cubit,
        act: (cubit) => cubit.loadNews(),
        expect: () => [
          NewsState(status: NewsStatus.loading),
          NewsState(
            status: NewsStatus.loaded,
            news: testNews,
            page: 1,
            hasMore: false,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.listNews(
              appId: 1,
              perPage: 11,
              page: 1,
            ),
          ).called(1);
        },
      );

      blocTest<NewsCubit, NewsState>(
        'emits error state when repository throws',
        setUp: () {
          when(
            () => repository.listNews(
              appId: 1,
              perPage: 11,
              page: 1,
            ),
          ).thenThrow(Exception('Failed to load news'));
        },
        build: () => cubit,
        act: (cubit) => cubit.loadNews(),
        expect: () => [
          NewsState(status: NewsStatus.loading),
          NewsState(
            status: NewsStatus.error,
            error: 'Exception: Failed to load news',
          ),
        ],
      );
    });

    group('loadMoreNews', () {
      blocTest<NewsCubit, NewsState>(
        'does nothing when hasMore is false',
        seed: () => NewsState(hasMore: false),
        build: () => cubit,
        act: (cubit) => cubit.loadMoreNews(),
        expect: () => <NewsState>[],
        verify: (_) {
          verifyNever(
            () => repository.listNews(
              appId: any(named: 'appId'),
              perPage: any(named: 'perPage'),
              page: any(named: 'page'),
            ),
          );
        },
      );

      blocTest<NewsCubit, NewsState>(
        'does nothing when status is loading',
        seed: () => NewsState(status: NewsStatus.loading),
        build: () => cubit,
        act: (cubit) => cubit.loadMoreNews(),
        expect: () => <NewsState>[],
        verify: (_) {
          verifyNever(
            () => repository.listNews(
              appId: any(named: 'appId'),
              perPage: any(named: 'perPage'),
              page: any(named: 'page'),
            ),
          );
        },
      );

      blocTest<NewsCubit, NewsState>(
        'emits loaded state with appended news when successful',
        seed: () => NewsState(
          status: NewsStatus.loaded,
          news: testNews.sublist(0, 1),
          page: 1,
          hasMore: true,
        ),
        setUp: () {
          when(
            () => repository.listNews(
              appId: 1,
              perPage: 10,
              page: 2,
            ),
          ).thenAnswer((_) async => testNews.sublist(1));
        },
        build: () => cubit,
        act: (cubit) => cubit.loadMoreNews(),
        expect: () => [
          NewsState(
            status: NewsStatus.loading,
            news: testNews.sublist(0, 1),
            page: 1,
            hasMore: true,
          ),
          NewsState(
            status: NewsStatus.loaded,
            news: testNews,
            page: 2,
            hasMore: false,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.listNews(
              appId: 1,
              perPage: 10,
              page: 2,
            ),
          ).called(1);
        },
      );

      blocTest<NewsCubit, NewsState>(
        'emits error state when repository throws',
        seed: () => NewsState(
          status: NewsStatus.loaded,
          news: testNews.sublist(0, 1),
          page: 1,
          hasMore: true,
        ),
        setUp: () {
          when(
            () => repository.listNews(
              appId: 1,
              perPage: 10,
              page: 2,
            ),
          ).thenThrow(Exception('Failed to load more news'));
        },
        build: () => cubit,
        act: (cubit) => cubit.loadMoreNews(),
        expect: () => [
          NewsState(
            status: NewsStatus.loading,
            news: testNews.sublist(0, 1),
            page: 1,
            hasMore: true,
          ),
          NewsState(
            status: NewsStatus.error,
            news: testNews.sublist(0, 1),
            page: 1,
            hasMore: true,
            error: 'Exception: Failed to load more news',
          ),
        ],
      );
    });
  });
}
