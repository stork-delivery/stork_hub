import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/artifacts/artifacts.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

/// {@template artifacts_dialog}
/// A dialog that displays the artifacts of a version
/// {@endtemplate}
class ArtifactsDialog extends StatelessWidget {
  /// {@macro artifacts_dialog}
  const ArtifactsDialog({super.key});

  /// Shows the artifacts dialog
  static Future<void> showArtifactsDialog(
    BuildContext context, {
    required int appId,
    required String versionName,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => ArtifactsCubit(
          storkRepository: context.read<StorkRepository>(),
          appId: appId,
          versionName: versionName,
        )..loadArtifacts(),
        child: const ArtifactsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          child: BlocBuilder<ArtifactsCubit, ArtifactsState>(
            builder: (context, state) {
              if (state.status == ArtifactsStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.status == ArtifactsStatus.downloading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Downloading...'),
                    ],
                  ),
                );
              }

              if (state.status == ArtifactsStatus.error) {
                return Center(
                  child: Text(state.error ?? ''),
                );
              }

              if (state.artifacts.isEmpty) {
                return const Center(
                  child: Text('No artifacts available'),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Artifacts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (state.downloadedFile != null) ...[
                    Text(
                      'Artifact downloaded to: ${state.downloadedFile}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.artifacts.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final artifact = state.artifacts[index];
                        return ListTile(
                          title: Text(artifact.name),
                          subtitle: Text('Platform: ${artifact.platform}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              context.read<ArtifactsCubit>().downloadArtifact(
                                    artifact.platform,
                                    artifact.name,
                                  );
                            },
                            tooltip: 'Download artifact',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
