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

    const artifact = Artifact(
      id: 1,
      name: 'test.zip',
      platform: 'linux',
      versionId: 1,
    );

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

    testWidgets('renders no artifacts message when list is empty',
        (tester) async {
      when(() => cubit.state).thenReturn(
        const ArtifactsState(status: ArtifactsStatus.loaded),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ArtifactsDialog(),
          ),
        ),
      );

      expect(find.text('No artifacts available'), findsOneWidget);
    });

    testWidgets('renders artifacts list when loaded', (tester) async {
      when(() => cubit.state).thenReturn(
        const ArtifactsState(
          status: ArtifactsStatus.loaded,
          artifacts: [artifact],
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

      expect(find.text(artifact.name), findsOneWidget);
      expect(find.text('Platform: ${artifact.platform}'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('shows download path when file is downloaded', (tester) async {
      const downloadPath = '/path/to/downloaded/file.zip';
      when(() => cubit.state).thenReturn(
        const ArtifactsState(
          status: ArtifactsStatus.loaded,
          artifacts: [artifact],
          downloadedFile: downloadPath,
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

      expect(
        find.text('Artifact downloaded to: $downloadPath'),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping download button calls downloadArtifact',
      (tester) async {
        when(() => cubit.state).thenReturn(
          const ArtifactsState(
            status: ArtifactsStatus.loaded,
            artifacts: [artifact],
          ),
        );
        when(() => cubit.downloadArtifact(any(), any()))
            .thenAnswer((_) async {});

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const ArtifactsDialog(),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.download));
        await tester.pump();

        verify(
          () => cubit.downloadArtifact(artifact.platform, artifact.name),
        ).called(1);
      },
    );

    testWidgets('shows loading indicator while downloading', (tester) async {
      when(() => cubit.state).thenReturn(
        const ArtifactsState(status: ArtifactsStatus.downloading),
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
      expect(find.text('Downloading...'), findsOneWidget);
    });

    testWidgets('loads artifacts when shown', (tester) async {
      final repository = MockStorkRepository();
      when(() => repository.listAppVersionArtifacts(any(), any()))
          .thenAnswer((invocation) async {
        return [];
      });

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

    testWidgets('renders multiple artifacts when loaded', (tester) async {
      const artifacts = [
        Artifact(
          id: 1,
          name: 'linux-app.zip',
          platform: 'linux',
          versionId: 1,
        ),
        Artifact(
          id: 2,
          name: 'mac-app.zip',
          platform: 'macos',
          versionId: 1,
        ),
        Artifact(
          id: 3,
          name: 'windows-app.zip',
          platform: 'windows',
          versionId: 1,
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

      for (final artifact in artifacts) {
        expect(find.text(artifact.name), findsOneWidget);
        expect(find.text('Platform: ${artifact.platform}'), findsOneWidget);
      }

      // Should have dividers between items (artifacts.length - 1 dividers)
      expect(find.byType(Divider), findsNWidgets(artifacts.length - 1));

      // Should have a download button for each artifact
      expect(find.byIcon(Icons.download), findsNWidgets(artifacts.length));
    });
  });
}
