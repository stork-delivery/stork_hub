import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stork_hub/itchio_data/cubit/itchio_data_cubit.dart';
import 'package:stork_hub/itchio_data/itchio_data.dart';
import 'package:stork_hub/repositories/stork_repository.dart';

/// {@template itchio_data_dialog}
/// A dialog that displays and manages ItchIO integration data
/// {@endtemplate}
class ItchIODataDialog extends StatefulWidget {
  /// {@macro itchio_data_dialog}
  const ItchIODataDialog({super.key});

  /// Shows the ItchIO data dialog
  static Future<void> showItchIODataDialog(
    BuildContext context, {
    required int appId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => ItchIODataCubit(
          storkRepository: context.read<StorkRepository>(),
          appId: appId,
        )..loadItchIOData(),
        child: const ItchIODataDialog(),
      ),
    );
  }

  @override
  State<ItchIODataDialog> createState() => _ItchIODataDialogState();
}

class _ItchIODataDialogState extends State<ItchIODataDialog> {
  final _formKey = GlobalKey<FormState>();
  final _buttlerKeyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _gameNameController = TextEditingController();

  @override
  void dispose() {
    _buttlerKeyController.dispose();
    _usernameController.dispose();
    _gameNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: BlocConsumer<ItchIODataCubit, ItchIODataState>(
              listener: (context, state) {
                if (state.data != null) {
                  _buttlerKeyController.text = state.data!.buttlerKey;
                  _usernameController.text = state.data!.itchIOUsername;
                  _gameNameController.text = state.data!.itchIOGameName;
                }
              },
              builder: (context, state) {
                if (state.status == ItchIODataStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.status == ItchIODataStatus.saving) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Saving ItchIO data...'),
                      ],
                    ),
                  );
                }

                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ItchIO Integration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (state.error != null) ...[
                        Text(
                          state.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _buttlerKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Buttler Key',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Buttler key';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'ItchIO Username',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your ItchIO username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gameNameController,
                        decoration: const InputDecoration(
                          labelText: 'Game Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your game name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<ItchIODataCubit>()
                                    .updateItchIOData(
                                      buttlerKey: _buttlerKeyController.text,
                                      itchIOUsername: _usernameController.text,
                                      itchIOGameName: _gameNameController.text,
                                    );
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
