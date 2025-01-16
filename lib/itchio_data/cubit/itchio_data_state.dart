part of 'itchio_data_cubit.dart';

/// The status of the ItchIO data loading
enum ItchIODataStatus {
  /// Initial status
  initial,

  /// Loading ItchIO data
  loading,

  /// ItchIO data loaded successfully
  loaded,

  /// Saving ItchIO data
  saving,

  /// Error loading or saving ItchIO data
  error,
}

/// {@template itchio_data_state}
/// The state of the ItchIO data dialog
/// {@endtemplate}
class ItchIODataState extends Equatable {
  /// {@macro itchio_data_state}
  const ItchIODataState({
    this.status = ItchIODataStatus.initial,
    this.data,
    this.error,
  });

  /// The status of the ItchIO data loading
  final ItchIODataStatus status;

  /// The ItchIO data if any
  final ItchIOData? data;

  /// The error message if any
  final String? error;

  @override
  List<Object?> get props => [status, data, error];

  /// Creates a copy of this state with the given fields replaced with new values
  ItchIODataState copyWith({
    ItchIODataStatus? status,
    ItchIOData? data,
    String? error,
  }) {
    return ItchIODataState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}
