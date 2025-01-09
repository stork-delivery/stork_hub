import 'package:dart_stork_admin_client/dart_stork_admin_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/app/app.dart';
import 'package:stork_hub/environment/app_environment.dart';
import 'package:stork_hub/home/home.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiKey = context.select((AppCubit cubit) => cubit.state.apiKey);
    final environment = context.read<AppEnvironment>();

    return RepositoryProvider(
      create: (context) => StorkRepository(
        client: DartStorkAdminClient(
          baseUrl: environment.storkUrl,
          apiKey: apiKey!,
        ),
      ),
      child: BlocProvider(
        create: (context) => HomeCubit(
          storkRepository: context.read(),
        )..loadApps(),
        child: const HomeView(),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stork Hub'),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == HomeStatus.error) {
            return Center(
              child: Text('Error: ${state.error}'),
            );
          }

          if (state.apps.isEmpty) {
            return const Center(
              child: Text('No apps added yet'),
            );
          }

          return ListView.builder(
            itemCount: state.apps.length,
            itemBuilder: (context, index) {
              final app = state.apps[index];
              return ListTile(
                title: Text(app.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<HomeCubit>().removeApp(app);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AddAppDialog(
                cubit: context.read<HomeCubit>(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddAppDialog extends StatefulWidget {
  const AddAppDialog({
    required this.cubit,
    super.key,
  });

  final HomeCubit cubit;

  @override
  State<AddAppDialog> createState() => _AddAppDialogState();
}

class _AddAppDialogState extends State<AddAppDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add App'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'App Name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.cubit.addApp(_nameController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
