import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;

import 'builder.dart';

Config loadConfig() {
  final home = Platform.environment['HOME'] ?? Platform.environment['UserProfile'];
  if (home == null) {
    return Config.empty();
  }

  final configPath = path.join(home, '.config', 'crank', 'config.json');
  final configFile = File(configPath);
  if (!configFile.existsSync()) {
    return Config.empty();
  }

  final jsonString = configFile.readAsStringSync();
  final json = jsonDecode(jsonString);

  return Config.fromJson(json as Map<String, dynamic>);
}

class Config {
  Config({required this.builders});

  final Map<String, Builder> builders;

  factory Config.empty() {
    return Config(builders: const <String, Builder>{});
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    final builders = <String, Builder>{};
    final buildersJson = json['builds'] as List<dynamic>;

    for (final entryJson in buildersJson) {
      final builder = Builder.fromJson(entryJson as Map<String, dynamic>);

      builders[builder.name] = builder;
    }

    return Config(builders: builders);
  }
}
