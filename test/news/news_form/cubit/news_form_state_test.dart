import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/news/news_form/cubit/news_form_state.dart';

void main() {
  group('NewsFormState', () {
    test('supports value equality', () {
      expect(
        const NewsFormState(appId: 1),
        equals(const NewsFormState(appId: 1)),
      );
    });

    test('props are correct', () {
      expect(
        const NewsFormState(
          appId: 1,
          id: 2,
          title: 'Test Title',
          content: 'Test Content',
        ).props,
        equals([1, 2, 'Test Title', 'Test Content']),
      );
    });

    group('copyWith', () {
      test('returns same object when no parameters are provided', () {
        const state = NewsFormState(appId: 1);
        expect(state.copyWith(), equals(state));
      });

      test('returns object with updated appId when provided', () {
        const state = NewsFormState(appId: 1);
        expect(
          state.copyWith(appId: 2),
          equals(const NewsFormState(appId: 2)),
        );
      });

      test('returns object with updated id when provided', () {
        const state = NewsFormState(appId: 1);
        expect(
          state.copyWith(id: 2),
          equals(const NewsFormState(appId: 1, id: 2)),
        );
      });

      test('returns object with updated title when provided', () {
        const state = NewsFormState(appId: 1);
        expect(
          state.copyWith(title: 'New Title'),
          equals(const NewsFormState(appId: 1, title: 'New Title')),
        );
      });

      test('returns object with updated content when provided', () {
        const state = NewsFormState(appId: 1);
        expect(
          state.copyWith(content: 'New Content'),
          equals(const NewsFormState(appId: 1, content: 'New Content')),
        );
      });
    });
  });
}
