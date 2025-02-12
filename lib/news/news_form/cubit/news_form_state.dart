import 'package:equatable/equatable.dart';

class NewsFormState extends Equatable {
  const NewsFormState({
    required this.appId,
    this.id,
    this.title = '',
    this.content = '',
  });

  final int appId;
  final int? id;
  final String title;
  final String content;

  NewsFormState copyWith({
    int? appId,
    int? id,
    String? title,
    String? content,
  }) {
    return NewsFormState(
      appId: appId ?? this.appId,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [appId, id, title, content];
}
