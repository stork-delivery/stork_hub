// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/news/news.dart';
import 'package:stork_hub/news/news_form/view/news_form_dialog.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

class MockNewsCubit extends MockCubit<NewsState> implements NewsCubit {}

void main() {
  late StorkRepository storkRepository;
  late NewsCubit cubit;
  late MockNavigator navigator;

  setUp(() {
    storkRepository = MockStorkRepository();
    cubit = MockNewsCubit();
    navigator = MockNavigator();

    when(cubit.loadNews).thenAnswer((_) async {});
    when(cubit.loadMoreNews).thenAnswer((_) async {});
    when(() => cubit.appId).thenReturn(1);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});
    when(() => navigator.pop<void>()).thenAnswer((_) async {});
    when(() => navigator.canPop()).thenReturn(true);
  });

  Widget buildSubject({
    required Widget child,
  }) {
    return MaterialApp(
      home: MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: cubit,
          child: child,
        ),
      ),
    );
  }

  group('NewsDialog', () {
    testWidgets('renders loading indicator when status is loading',
        (tester) async {
      when(() => cubit.state).thenReturn(
        NewsState(status: NewsStatus.loading),
      );

      await tester.pumpWidget(
        buildSubject(
          child: NewsDialog(storkRepository: storkRepository),
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
        buildSubject(
          child: NewsDialog(storkRepository: storkRepository),
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
        buildSubject(
          child: NewsDialog(storkRepository: storkRepository),
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
        buildSubject(
          child: NewsDialog(storkRepository: storkRepository),
        ),
      );

      expect(find.text('Test News 1'), findsOneWidget);
      expect(find.text('Test News 2'), findsOneWidget);
    });

    group('showNewsDialog', () {
      testWidgets('shows dialog with NewsCubit provider', (tester) async {
        final context = MaterialApp(
          home: MockNavigatorProvider(
            navigator: navigator,
            child: RepositoryProvider<StorkRepository>(
              create: (_) => storkRepository,
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => NewsDialog.showNewsDialog(
                    context,
                    appId: 1,
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(context);
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(NewsDialog), findsOneWidget);
      });
    });

    group('add news button', () {
      testWidgets(
        'opens NewsFormDialog and reloads news on tap',
        (tester) async {
          when(() => cubit.state).thenReturn(
            NewsState(status: NewsStatus.loaded),
          );

          await tester.pumpWidget(
            buildSubject(
              child: NewsDialog(storkRepository: storkRepository),
            ),
          );

          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();

          expect(find.byType(NewsFormDialog), findsOneWidget);
        },
      );
    });
  });
}
