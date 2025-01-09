import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/home/home.dart';
import 'package:stork_hub/l10n/l10n.dart';
import 'package:stork_hub/login/login.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => ApiKeyRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => AppCubit(
          apiKeyRepository: context.read<ApiKeyRepository>(),
        ),
        child: MaterialApp(
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              if (state.apiKey != null) {
                return const HomePage();
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );
  }
}
