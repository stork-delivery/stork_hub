import 'package:equatable/equatable.dart';

/// Model representing Itch.io integration data for an app
class ItchIOData extends Equatable {
  /// Creates a new instance of [ItchIOData]
  const ItchIOData({
    required this.id,
    required this.appId,
    required this.buttlerKey,
    required this.itchIOUsername,
    required this.itchIOGameName,
  });

  /// Creates a new instance of [ItchIOData] from a JSON map
  factory ItchIOData.fromJson(Map<String, dynamic> json) {
    return ItchIOData(
      id: json['id'] as int,
      appId: json['appId'] as int,
      buttlerKey: json['buttlerKey'] as String,
      itchIOUsername: json['itchIOUsername'] as String,
      itchIOGameName: json['itchIOGameName'] as String,
    );
  }

  /// The unique identifier
  final int id;

  /// The associated app ID
  final int appId;

  /// The Buttler key used for authentication
  final String buttlerKey;

  /// The Itch.io username
  final String itchIOUsername;

  /// The Itch.io game name
  final String itchIOGameName;

  /// Converts this instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appId': appId,
      'buttlerKey': buttlerKey,
      'itchIOUsername': itchIOUsername,
      'itchIOGameName': itchIOGameName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        appId,
        buttlerKey,
        itchIOUsername,
        itchIOGameName,
      ];
}
