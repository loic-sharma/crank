class Builder {
  const Builder({
    required this.name,
    required this.description,
    required this.gclientVariables,
    required this.gn,
    required this.ninja,
    this.tests,
  });

  final String name;
  final String description;
  final Map<String, dynamic> gclientVariables;
  final List<String> gn;
  final Ninja ninja;
  final List<Test>? tests;
}

class Ninja {
  const Ninja({required this.config, this.targets});

  final String config;
  final List<String>? targets;
}

class Test {
  const Test({
    this.language,
    required this.name,
    required this.script,
    required this.parameters,
  });

  final String? language;
  final String name;
  final String script;
  final List<String> parameters;
}
