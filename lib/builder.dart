class Builder {
  const Builder({
    required this.name,
    required this.description,
    required this.gn,
    required this.ninja,
    this.tests,
  });

  factory Builder.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final description = json['description'] as String? ?? '';
    final gn = json['gn'] as List<dynamic>;
    final ninja = Ninja.fromJson(json['ninja'] as Map<String, dynamic>);

    final tests = <Test>[];
    for (final json in json['tests'] as List<dynamic>? ?? []) {
      tests.add(Test.fromJson(json as Map<String, dynamic>));
    }

    return Builder(
      name: name,
      description: description,
      gn: gn.map((p) => p as String).toList(),
      ninja: ninja,
      tests: tests,
    );
  }

  final String name;
  final String description;
  final List<String> gn;
  final Ninja ninja;
  final List<Test>? tests;
}

class Ninja {
  const Ninja({required this.config, this.targets});

  factory Ninja.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as String;
    final targets = json['targets'] as List<dynamic>?;

    return Ninja(
      config: config,
      targets: targets?.map((t) => t as String).toList());
  }

  final String config;
  final List<String>? targets;
}

class Test {
  const Test({
    this.language,
    required this.name,
    required this.script,
    this.parameters,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    final language = json['language'] as String?;
    final name = json['name'] as String;
    final script = json['script'] as String;
    final parameters = json['parameters'] as List<String>?;

    return Test(
      language: language,
      name: name,
      script: script,
      parameters: parameters,
    );
  }

  final String? language;
  final String name;
  final String script;
  final List<String>? parameters;
}
