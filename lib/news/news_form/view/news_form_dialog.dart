import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/models/models.dart';
import 'package:stork_hub/news/news_form/cubit/news_form_cubit.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class NewsFormDialog extends StatelessWidget {
  const NewsFormDialog({
    required this.appId,
    super.key,
    this.news,
  });

  final int appId;
  final News? news;

  static Future<void> show(
    BuildContext context, {
    required StorkRepository repository,
    required int appId,
    News? news,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => BlocProvider(
        create: (_) => NewsFormCubit(
          repository: repository,
          appId: appId,
          news: news,
        ),
        child: NewsFormDialog(
          appId: appId,
          news: news,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(news == null ? 'New News' : 'Edit News'),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              controller: TextEditingController(
                text: news?.title,
              ),
              onChanged: (value) =>
                  context.read<NewsFormCubit>().titleChanged(value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
              controller: TextEditingController(
                text: news?.content,
              ),
              maxLines: 3,
              onChanged: (value) =>
                  context.read<NewsFormCubit>().contentChanged(value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<NewsFormCubit>().submit();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
