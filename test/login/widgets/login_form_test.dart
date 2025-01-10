// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/login/login.dart';

class MockAppCubit extends Mock implements AppCubit {}

class MockLoginCubit extends Mock implements LoginCubit {}

void main() {
  group('LoginForm', () {
    late AppCubit appCubit;
    late LoginCubit loginCubit;

    void mockAppCubitState(AppState state) {
      whenListen(appCubit, Stream.value(state), initialState: state);
    }

    void mockLoginCubitState(LoginState state) {
      whenListen(loginCubit, Stream.value(state), initialState: state);
    }

    setUp(() {
      appCubit = MockAppCubit();
      loginCubit = MockLoginCubit();

      mockAppCubitState(const AppState());
      mockLoginCubitState(const LoginState());

      when(
        () => appCubit.saveAndSetApiKey(
          apiKey: any(named: 'apiKey'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      when(() => appCubit.unlockWithPassword(any()))
          .thenAnswer((_) async => true);

      when(() => loginCubit.resetKey()).thenAnswer((_) async {});
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: appCubit,
        child: BlocProvider.value(
          value: loginCubit,
          child: MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginCubit,
                child: const LoginForm(),
              ),
            ),
          ),
        ),
      );
    }

    group('initial state', () {
      testWidgets('shows API key field when no saved key', (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(find.widgetWithText(TextField, 'API Key'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
        expect(find.text('Reset API Key'), findsNothing);
      });

      testWidgets('hides API key field when has saved key', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpWidget(buildSubject());

        expect(find.widgetWithText(TextField, 'API Key'), findsNothing);
        expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Unlock'), findsOneWidget);
        expect(find.text('Reset API Key'), findsOneWidget);
      });
    });

    group('when loading', () {
      testWidgets('shows loading indicator', (tester) async {
        mockLoginCubitState(const LoginState(loading: true));
        await tester.pumpWidget(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('login button', () {
      testWidgets(
        'shows error when fields are empty with no saved key',
        (tester) async {
          await tester.pumpWidget(buildSubject());

          await tester.tap(find.text('Login'));
          await tester.pumpAndSettle();

          expect(
            find.text('Please fill in all fields'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows error when password is empty with saved key',
        (tester) async {
          mockLoginCubitState(const LoginState(hasSavedKey: true));
          await tester.pumpWidget(buildSubject());

          await tester.tap(find.text('Unlock'));
          await tester.pumpAndSettle();

          expect(
            find.text('Please enter your password'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'saves and sets API key when no saved key',
        (tester) async {
          await tester.pumpWidget(buildSubject());

          await tester.enterText(
            find.widgetWithText(TextField, 'API Key'),
            'test-key',
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'Password'),
            'test-password',
          );

          await tester.tap(find.text('Login'));

          verify(
            () => appCubit.saveAndSetApiKey(
              apiKey: 'test-key',
              password: 'test-password',
            ),
          ).called(1);
        },
      );

      testWidgets(
        'unlocks with password when has saved key',
        (tester) async {
          mockLoginCubitState(const LoginState(hasSavedKey: true));
          await tester.pumpWidget(buildSubject());

          await tester.enterText(
            find.widgetWithText(TextField, 'Password'),
            'test-password',
          );

          await tester.tap(find.text('Unlock'));

          verify(
            () => appCubit.unlockWithPassword('test-password'),
          ).called(1);
        },
      );

      testWidgets(
        'shows error on invalid password',
        (tester) async {
          when(() => appCubit.unlockWithPassword(any()))
              .thenAnswer((_) async => false);

          mockLoginCubitState(const LoginState(hasSavedKey: true));

          await tester.pumpWidget(buildSubject());

          await tester.enterText(
            find.widgetWithText(TextField, 'Password'),
            'wrong-password',
          );

          await tester.tap(find.text('Unlock'));
          await tester.pumpAndSettle();

          expect(find.text('Invalid password'), findsOneWidget);
        },
      );
    });

    group('reset button', () {
      testWidgets('shows confirmation dialog', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('Reset API Key'));
        await tester.pumpAndSettle();

        expect(find.text('Reset API Key'), findsNWidgets(2));
        expect(
          find.text(
            'Are you sure you want to reset your API key? '
            'You will need to enter it again.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('resets key on confirm', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('Reset API Key'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset').last);
        await tester.pumpAndSettle();

        verify(() => loginCubit.resetKey()).called(1);
      });

      testWidgets('does nothing on cancel', (tester) async {
        mockLoginCubitState(const LoginState(hasSavedKey: true));
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('Reset API Key'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        verifyNever(() => loginCubit.resetKey());
      });
    });
  });
}
