import 'package:equatable/equatable.dart';

/// Represents a news article.
class News extends Equatable {
  const News({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  /// The unique identifier of the news article.
  final int id;

  /// The title of the news article.
  final String title;

  /// The content of the news article.
  final String content;

  /// The date and time the news article was created.
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, content, createdAt];
}
