// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/news/news.dart';

void main() {
  group('NewsState', () {
    test('supports value equality', () {
      expect(
        NewsState(),
        equals(NewsState()),
      );
    });

    test('has correct default values', () {
      final state = NewsState();
      expect(state.status, equals(NewsStatus.initial));
      expect(state.news, isEmpty);
      expect(state.page, equals(1));
      expect(state.error, isNull);
      expect(state.hasMore, isTrue);
    });

    test('props contains all properties', () {
      final news = [
        News(
          id: 1,
          title: 'Test News',
          content: 'Test Content',
          createdAt: DateTime.now(),
        ),
      ];

      final state = NewsState(
        status: NewsStatus.loaded,
        news: news,
        page: 2,
        error: 'error',
        hasMore: false,
      );

      expect(
        state.props,
        equals([
          NewsStatus.loaded,
          news,
          2,
          'error',
          false,
        ]),
      );
    });

    group('copyWith', () {
      test('returns same object when no properties are passed', () {
        final state = NewsState();
        expect(state.copyWith(), equals(state));
      });

      test('returns object with updated status when status is passed', () {
        final state = NewsState();
        expect(
          state.copyWith(status: NewsStatus.loading),
          equals(
            NewsState(status: NewsStatus.loading),
          ),
        );
      });

      test('returns object with updated news when news is passed', () {
        final state = NewsState();
        final news = [
          News(
            id: 1,
            title: 'Test News',
            content: 'Test Content',
            createdAt: DateTime.now(),
          ),
        ];
        expect(
          state.copyWith(news: news),
          equals(
            NewsState(news: news),
          ),
        );
      });

      test('returns object with updated page when page is passed', () {
        final state = NewsState();
        expect(
          state.copyWith(page: 2),
          equals(
            NewsState(page: 2),
          ),
        );
      });

      test('returns object with updated error when error is passed', () {
        final state = NewsState();
        expect(
          state.copyWith(error: 'error'),
          equals(
            NewsState(error: 'error'),
          ),
        );
      });

      test('returns object with updated hasMore when hasMore is passed', () {
        final state = NewsState();
        expect(
          state.copyWith(hasMore: false),
          equals(
            NewsState(hasMore: false),
          ),
        );
      });
    });
  });
}
