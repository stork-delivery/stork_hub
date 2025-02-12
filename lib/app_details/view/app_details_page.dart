import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/app_details/app_details.dart';
import 'package:stork_hub/artifacts/artifacts.dart';
import 'package:stork_hub/itchio_data/itchio_data.dart';
import 'package:stork_hub/l10n/l10n.dart';
import 'package:stork_hub/news/news.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

/// {@template app_details_page}
/// A page that displays the details of an app
/// {@endtemplate}
class AppDetailsPage extends StatelessWidget {
  /// {@macro app_details_page}
  const AppDetailsPage({
    required this.appId,
    required this.storkRepository,
    super.key,
  });

  /// The id of the app to display
  final int appId;

  /// The repository to use for loading and updating the app
  final StorkRepository storkRepository;

  /// Returns the route for this page
  static Route<void> route({
    required int appId,
    required StorkRepository storkRepository,
  }) {
    return MaterialPageRoute<void>(
      builder: (context) => AppDetailsPage(
        appId: appId,
        storkRepository: storkRepository,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppDetailsCubit(
        storkRepository: storkRepository,
        appId: appId,
      )..loadApp(),
      child: RepositoryProvider<StorkRepository>.value(
        value: storkRepository,
        child: const AppDetailsView(),
      ),
    );
  }
}

/// {@template app_details_view}
/// The view for the app details page
/// {@endtemplate}
class AppDetailsView extends StatelessWidget {
  /// {@macro app_details_view}
  const AppDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appDetailsTitle),
      ),
      body: BlocBuilder<AppDetailsCubit, AppDetailsState>(
        builder: (context, state) {
          if (state.status == AppDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AppDetailsStatus.error) {
            return Center(child: Text(state.error ?? ''));
          }

          if (state.app == null) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${state.app!.id}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.app!.name,
                  decoration: InputDecoration(
                    labelText: l10n.appDetailsNameLabel,
                  ),
                  onFieldSubmitted: (value) {
                    context.read<AppDetailsCubit>().updateApp(name: value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(l10n.appDetailsPublicMetadataLabel),
                    const SizedBox(width: 16),
                    Switch(
                      value: state.app!.publicMetadata,
                      onChanged: (value) {
                        context
                            .read<AppDetailsCubit>()
                            .updateApp(publicMetadata: value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    NewsDialog.showNewsDialog(
                      context,
                      appId: state.app!.id,
                    );
                  },
                  child: const Text('News'),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text(
                      'Versions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.gamepad),
                      onPressed: () {
                        ItchIODataDialog.showItchIODataDialog(
                          context,
                          appId: state.app!.id,
                        );
                      },
                      tooltip: 'ItchIO Data',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.versions.isEmpty
                      ? const Text('No versions available')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.versions.length,
                          itemBuilder: (context, index) {
                            final version = state.versions[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Version: ${version.version}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.archive),
                                          onPressed: () {
                                            ArtifactsDialog.showArtifactsDialog(
                                              context,
                                              appId: version.appId,
                                              versionName: version.version,
                                            );
                                          },
                                          tooltip: 'View artifacts',
                                        ),
                                      ],
                                    ),
                                    if (version.changelog.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Changelog:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(version.changelog),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
