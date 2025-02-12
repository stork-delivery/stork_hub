import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/news/news.dart';
import 'package:stork_hub/news/news_form/view/news_form_dialog.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

/// {@template news_dialog}
/// A dialog that displays the news of a version
/// {@endtemplate}
class NewsDialog extends StatelessWidget {
  /// {@macro news_dialog}
  const NewsDialog({
    required this.storkRepository,
    super.key,
  });

  final StorkRepository storkRepository;

  /// Shows the news dialog
  static Future<void> showNewsDialog(
    BuildContext context, {
    required int appId,
  }) {
    final repo = context.read<StorkRepository>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => NewsCubit(
          storkRepository: repo,
          appId: appId,
        )..loadNews(),
        child: NewsDialog(
          storkRepository: repo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 800,
          height: 600,
          child: BlocBuilder<NewsCubit, NewsState>(
            builder: (context, state) {
              if (state.status == NewsStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.status == NewsStatus.error) {
                return Center(
                  child: Text(state.error ?? ''),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'News',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final cubit = context.read<NewsCubit>();
                          await NewsFormDialog.show(
                            context,
                            repository: storkRepository,
                            appId: context.read<NewsCubit>().appId,
                          );

                          await cubit.loadNews();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.news.isEmpty)
                    const Text('No news available')
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.news.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final news = state.news[index];
                          return ListTile(
                            title: Text(news.title),
                            subtitle: Text('Created at: ${news.createdAt}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final cubit = context.read<NewsCubit>();
                                await NewsFormDialog.show(
                                  context,
                                  repository: storkRepository,
                                  appId: context.read<NewsCubit>().appId,
                                  news: news,
                                );
                                await cubit.loadNews();
                              },
                              tooltip: 'Edit news',
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
