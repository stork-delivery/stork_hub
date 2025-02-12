// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/news/news.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

class MockNewsCubit extends MockCubit<NewsState> implements NewsCubit {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('NewsDialog', () {
    late StorkRepository storkRepository;
    late NewsCubit cubit;

    setUp(() {
      storkRepository = MockStorkRepository();
      cubit = MockNewsCubit();

      when(cubit.loadNews).thenAnswer((_) async {});
      when(cubit.loadMoreNews).thenAnswer((_) async {});
      when(() => cubit.appId).thenReturn(1);
    });

    testWidgets('renders loading indicator when status is loading',
        (tester) async {
      when(() => cubit.state).thenReturn(
        NewsState(status: NewsStatus.loading),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: NewsDialog(storkRepository: storkRepository),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when status is error', (tester) async {
      when(() => cubit.state).thenReturn(
        NewsState(
          status: NewsStatus.error,
          error: 'Test error message',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: NewsDialog(storkRepository: storkRepository),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('renders no news message when news list is empty',
        (tester) async {
      when(() => cubit.state).thenReturn(
        NewsState(status: NewsStatus.loaded),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: NewsDialog(storkRepository: storkRepository),
          ),
        ),
      );

      expect(find.text('No news available'), findsOneWidget);
    });

    testWidgets('renders news list when available', (tester) async {
      final now = DateTime.now();
      final news = [
        News(
          id: 1,
          title: 'Test News 1',
          content: 'Content 1',
          createdAt: now,
        ),
        News(
          id: 2,
          title: 'Test News 2',
          content: 'Content 2',
          createdAt: now,
        ),
      ];

      when(() => cubit.state).thenReturn(
        NewsState(
          status: NewsStatus.loaded,
          news: news,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: NewsDialog(storkRepository: storkRepository),
          ),
        ),
      );

      expect(find.text('Test News 1'), findsOneWidget);
      expect(find.text('Test News 2'), findsOneWidget);
      expect(find.text('Created at: $now'), findsNWidgets(2));
      expect(find.byIcon(Icons.edit), findsNWidgets(2));
    });

    testWidgets('shows load more button when hasMore is true', (tester) async {
      when(() => cubit.state).thenReturn(
        NewsState(
          status: NewsStatus.loaded,
          hasMore: true,
          news: [
            News(
              id: 1,
              title: 'Test News',
              content: 'Content',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: NewsDialog(storkRepository: storkRepository),
          ),
        ),
      );

      expect(find.text('Load More'), findsOneWidget);

      await tester.tap(find.text('Load More'));
      await tester.pump();

      verify(() => cubit.loadMoreNews()).called(1);
    });

    testWidgets('load more button shows loading indicator when loading',
        (tester) async {
      when(() => cubit.state).thenReturn(
        NewsState(
          status: NewsStatus.loading,
          hasMore: true,
          news: [
            News(
              id: 1,
              title: 'Test News',
              content: 'Content',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: NewsDialog(storkRepository: storkRepository),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
