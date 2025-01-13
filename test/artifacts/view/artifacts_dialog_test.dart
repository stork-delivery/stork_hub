import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/artifacts/artifacts.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class MockStorkRepository extends Mock implements StorkRepository {}

class MockArtifactsCubit extends MockCubit<ArtifactsState>
    implements ArtifactsCubit {}

void main() {
  group('ArtifactsDialog', () {
    late ArtifactsCubit cubit;

    setUp(() {
      cubit = MockArtifactsCubit();
    });

    testWidgets('renders loading state', (tester) async {
      when(() => cubit.state).thenReturn(
        const ArtifactsState(status: ArtifactsStatus.loading),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ArtifactsDialog(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      const errorMessage = 'Failed to load artifacts';
      when(() => cubit.state).thenReturn(
        const ArtifactsState(
          status: ArtifactsStatus.error,
          error: errorMessage,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ArtifactsDialog(),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('renders loaded state', (tester) async {
      const artifacts = [
        Artifact(
          id: 1,
          name: 'artifact.zip',
          versionId: 1,
          platform: 'linux',
        ),
      ];

      when(() => cubit.state).thenReturn(
        const ArtifactsState(
          status: ArtifactsStatus.loaded,
          artifacts: artifacts,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ArtifactsDialog(),
          ),
        ),
      );

      expect(find.text('artifact.zip'), findsOneWidget);
      expect(find.text('Platform: linux'), findsOneWidget);
    });

    testWidgets('loads artifacts when shown', (tester) async {
      final repository = MockStorkRepository();
      when(() => repository.listAppVersionArtifacts(any(), any()));

      await tester.pumpWidget(
        MaterialApp(
          home: RepositoryProvider<StorkRepository>.value(
            value: repository,
            child: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    ArtifactsDialog.showArtifactsDialog(
                      context,
                      appId: 1,
                      versionName: '1.0.0',
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      verify(
        () => repository.listAppVersionArtifacts(1, '1.0.0'),
      ).called(1);
    });
  });
}
