part of 'news_cubit.dart';

/// The status of the news loading
enum NewsStatus {
  /// Initial status
  initial,

  /// Loading news
  loading,

  /// News loaded successfully
  loaded,

  /// Error loading news
  error,
}

/// {@template news_state}
/// The state of the news dialog
/// {@endtemplate}
class NewsState extends Equatable {
  /// {@macro news_state}
  const NewsState({
    this.status = NewsStatus.initial,
    this.news = const [],
    this.page = 1,
    this.error,
    this.hasMore = true,
  });

  /// The status of the news loading
  final NewsStatus status;

  /// The list of news
  final List<News> news;

  /// The current page of news
  final int page;

  /// The error message if any
  final String? error;

  /// Whether there are more news to load
  final bool hasMore;

  @override
  List<Object?> get props => [status, news, page, error, hasMore];

  /// Creates a copy of this state with the given fields replaced with new
  /// values
  NewsState copyWith({
    NewsStatus? status,
    List<News>? news,
    int? page,
    String? error,
    bool? hasMore,
  }) {
    return NewsState(
      status: status ?? this.status,
      news: news ?? this.news,
      page: page ?? this.page,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
