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

    final artifacts = [
      const Artifact(
        id: 1,
        versionId: 1,
        name: 'app-release.apk',
        platform: 'android',
      ),
      const Artifact(
        id: 2,
        versionId: 1,
        name: 'app.ipa',
        platform: 'ios',
      ),
    ];

    setUp(() {
      cubit = MockArtifactsCubit();
    });

    testWidgets('renders loading indicator when loading', (tester) async {
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

    testWidgets('renders error message when error occurs', (tester) async {
      when(() => cubit.state).thenReturn(
        const ArtifactsState(
          status: ArtifactsStatus.error,
          error: 'Error message',
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

      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('renders no artifacts message when no artifacts',
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
        ArtifactsState(
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

      expect(find.text('Artifacts'), findsOneWidget);
      for (final artifact in artifacts) {
        expect(find.text(artifact.name), findsOneWidget);
        expect(find.text('Platform: ${artifact.platform}'), findsOneWidget);
      }
    });
  });
}
