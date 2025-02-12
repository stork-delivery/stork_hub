// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/models/models.dart';

void main() {
  group('News', () {
    test('supports value equality', () {
      final now = DateTime.now();
      expect(
        News(
          id: 1,
          title: 'Test News',
          content: 'Test Content',
          createdAt: now,
        ),
        equals(
          News(
            id: 1,
            title: 'Test News',
            content: 'Test Content',
            createdAt: now,
          ),
        ),
      );
    });

    test('props contains all properties', () {
      final now = DateTime.now();
      final news = News(
        id: 1,
        title: 'Test News',
        content: 'Test Content',
        createdAt: now,
      );

      expect(
        news.props,
        equals([
          news.id,
          news.title,
          news.content,
          news.createdAt,
        ]),
      );
    });

    test('different instances with different values are not equal', () {
      final now = DateTime.now();
      final news1 = News(
        id: 1,
        title: 'Test News 1',
        content: 'Test Content 1',
        createdAt: now,
      );

      final news2 = News(
        id: 2,
        title: 'Test News 2',
        content: 'Test Content 2',
        createdAt: now.add(Duration(days: 1)),
      );

      expect(news1, isNot(equals(news2)));
    });
  });
}
