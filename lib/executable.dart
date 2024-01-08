import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'builder.dart';
import 'builders.dart';
import 'config.dart';

Future<void> main(List<String> args) async {
  final description = '''
A tool to develop the Flutter engine

Common commands:

  crank build --clean --fetch
    Download dependencies and run a clean Flutter engine build.

  crank test
    Run the engine's tests.

  crank run
    Run a Flutter app using a locally built engine.
''';

  final runner = CommandRunner('crank', description);

  runner.addCommand(BuildCommand());
  runner.addCommand(BuildAppCommand());
  runner.addCommand(CleanCommand());
  runner.addCommand(FetchCommand());
  runner.addCommand(RunCommand());
  runner.addCommand(TestCommand());
  runner.addCommand(GTestCommand());

  await runner.run(args);
}

class BuildCommand extends Command {
  @override
  final String name = 'build';

  @override
  final String description = 'Build the Flutter engine';

  @override
  final String category = CrankCommandCategory.engine;

  BuildCommand() {
    argParser.addOption(
      'builder',
      abbr: 'b',
      help: 'The engine builder configuration',
      allowed: _builders.keys,
      defaultsTo: _builders.keys.first,
    );
    argParser.addFlag(
      'clean',
      help: 'Clean the build directory',
      negatable: false,
    );
    argParser.addFlag(
      'fetch',
      help: 'Download dependencies',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    final args = argResults!;
    final clean = args['clean'] as bool;
    final fetch = args['fetch'] as bool;
    final builder = _builders[args['builder'] as String]!;

    await _runBuild(builder, clean, fetch);
  }
}

class BuildAppCommand extends Command {
  @override
  final String name = 'build-app';

  @override
  final String description = 'Build a Flutter app using a locally built engine';

  @override
  final String category = CrankCommandCategory.apps;

  BuildAppCommand() {
    addSubcommand(BuildWindowsAppCommand());
  }
}

class BuildWindowsAppCommand extends Command {
  @override
  final String name = 'windows';

  @override
  final String description = 'Build a Flutter Windows app using a locally built engine';

  BuildWindowsAppCommand() {
    argParser.addOption(
      'builder',
      abbr: 'b',
      help: 'The engine build configuration to use',
      allowed: _builders.keys,
      defaultsTo: _builders.keys.first,
    );

    _addBuildModeFlags(argParser);
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final builder = _builders[args['builder'] as String]!;

    final (buildMode, buildModeError) = _parseBuildMode(args);
    if (buildModeError != null) {
      usageException(buildModeError);
    }

    await _runProcess(
      'flutter', [
        'build',
        'windows',
        switch (buildMode) {
          BuildMode.debug => '--debug',
          BuildMode.profile => '--profile',
          BuildMode.release => '--release',
        },
        // TODO: Support non-host builds
        '--local-engine', builder.ninja.config,
        '--local-engine-host', builder.ninja.config,
        ...args.rest,
      ],
    );
  }
}

class RunCommand extends Command {
  @override
  final String name = 'run';

  @override
  final String description = 'Run a Flutter app using a locally built engine';

  @override
  final String category = CrankCommandCategory.apps;

  RunCommand() {
    argParser.addOption(
      'builder',
      abbr: 'b',
      help: 'The engine builder configuration',
      allowed: _builders.keys,
      defaultsTo: _builders.keys.first,
    );

    argParser.addOption(
      'device-id',
      abbr: 'd',
      help: 'Target device id or name (prefixes allowed).',
    );

    _addBuildModeFlags(argParser);
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final builder = _builders[args['builder'] as String]!;
    final device = args['device-id'] as String?;

    final (buildMode, buildModeError) = _parseBuildMode(args);
    if (buildModeError != null) {
      usageException(buildModeError);
    }

    await _runProcess(
      'flutter', [
        'run',
        if (buildMode == BuildMode.profile) '--profile',
        if (buildMode == BuildMode.release) '--release',
        // TODO: Support non-host builds
        '--local-engine', builder.ninja.config,
        '--local-engine-host', builder.ninja.config,
        if (device != null) ... [
          '--device-id', device,
        ],
        ...args.rest,
      ],
    );
  }
}

class TestCommand extends Command {
  @override
  final String name = 'test';

  @override
  final String description = "Run the Flutter engine's tests";

  @override
  final String category = CrankCommandCategory.engine;

  TestCommand() {
    argParser.addOption(
      'builder',
      abbr: 'b',
      help: 'The engine builder configuration',
      allowed: _builders.keys,
      defaultsTo: _builders.keys.first,
    );

    argParser.addSeparator('Build flags:');
    argParser.addFlag(
      'build',
      help: 'Build the engine',
      defaultsTo: true,
    );
    argParser.addFlag(
      'clean',
      help: 'Clean the build directory',
      negatable: false,
    );
    argParser.addFlag(
      'fetch',
      help: 'Download dependencies',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    final args = argResults!;
    final builder = _builders[args['builder'] as String]!;

    var build = args['build'] as bool;
    final clean = args['clean'] as bool;
    final fetch = args['fetch'] as bool;
    if (clean || fetch) {
      build = true;
    }

    if (build) {
      await _runBuild(builder, clean, fetch);
    }

    for (final test in builder.tests ?? const <Test>[]) {
      assert(test.language == 'python', 'Unsupported test language "${test.language}"');

      final executable = path.absolute(test.script);

      _runProcess('python3', [executable, ...?test.parameters]);
    }
  }
}

class GTestCommand extends Command {
  @override
  final String name = 'gtest';

  @override
  final String description = "Run a Flutter engine gtest executable";

  @override
  final String category = CrankCommandCategory.engine;

  GTestCommand() {
    argParser.addOption(
      'builder',
      abbr: 'b',
      help: 'The engine builder configuration',
      allowed: _builders.keys,
      defaultsTo: _builders.keys.first,
    );
    argParser.addOption(
      'executable',
      abbr: 'e',
      help: 'The gtest executable to run',
      defaultsTo:
       Platform.isWindows ? 'flutter_windows_unittests.exe' :
       Platform.isLinux ? 'flutter_linux_unittests' :
       null,
    );
    argParser.addOption(
      'filter',
      abbr: 'f',
      help: 'Run tests whose name matches the filter. Case sensitive. Accepts * as wildcard.',
      defaultsTo: '*',
    );
    
    argParser.addSeparator('Build flags:');
    argParser.addFlag(
      'build',
      help: 'Build the engine',
      defaultsTo: true,
    );
    argParser.addFlag(
      'clean',
      help: 'Clean the build directory',
      negatable: false,
    );
    argParser.addFlag(
      'fetch',
      help: 'Download dependencies',
      negatable: false,
    );
  }

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    final args = argResults!;
    final builder = _builders[args['builder'] as String]!;
    final executable = args['executable'];
    var filter = args['filter'] as String;

    var build = args['build'] as bool;
    final clean = args['clean'] as bool;
    final fetch = args['fetch'] as bool;
    if (clean || fetch) {
      build = true;
    }

    if (build) {
      await _runBuild(builder, clean, fetch);
    }

    final relativeExecutable = path.join('..', 'out', builder.ninja.config, executable);
    final absoluteExecutable = path.normalize(File(relativeExecutable).absolute.path);

    await _runProcess(absoluteExecutable, ['--repeat=1', '--gtest_filter=$filter']);
  }
}

class FetchCommand extends Command {
  @override
  final String name = 'fetch';

  @override
  final String description = "Download the Flutter engine's dependencies";

  @override
  final String category = CrankCommandCategory.engine;

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    if (await _runProcess('gclient', ['sync', '-D']) != 0) {
      throw 'Fetching dependencies failed...';
    }
  }
}

class CleanCommand extends Command {
  @override
  final String name = 'clean';

  @override
  final String description = "Clean the Flutter engine's build directory";

  @override
  final String category = CrankCommandCategory.engine;

  CleanCommand() {
    argParser.addOption(
      'builder',
      abbr: 'b',
      help: 'The engine builder configuration',
      allowed: _builders.keys,
      defaultsTo: _builders.keys.first,
    );
  }

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    final args = argResults!;
    final builder = _builders[args['builder'] as String]!;

    await _runProcess('autoninja', ['-C', '../out/${builder.ninja.config}', '-t', 'clean']);
  }
}

abstract final class CrankCommandCategory {
  static const String engine = 'Engine';
  static const String apps = 'Apps';
}

enum BuildMode {
  debug,
  profile,
  release;

  @override
  String toString() {
    return switch (this) {
      BuildMode.debug => 'debug',
      BuildMode.release => 'release',
      BuildMode.profile => 'profile',
    };
  }
}

void _addBuildModeFlags(ArgParser args) {
  args.addSeparator('Build mode:');
  args.addFlag(
    'debug',
    negatable: false,
    help: 'Build a debug version (default mode).',
  );
  args.addFlag(
    'profile',
    negatable: false,
    help: 'Build a version specialized for performance profiling.',
  );
  args.addFlag(
    'release',
    negatable: false,
    help: 'Build a release version.',
  );
}

(BuildMode mode, String? error) _parseBuildMode(ArgResults args) {
  final debug = args['debug'] as bool;
  final release = args['release'] as bool;
  final profile = args['profile'] as bool;

  var provided = [];
  if (debug) provided.add('--debug');
  if (release) provided.add('--release');
  if (profile) provided.add('--profile');

  if (provided.length > 1) {
    return (BuildMode.debug, '${provided.join(', ')} cannot be set at the same time.');
  }

  if (debug) return (BuildMode.debug, null);
  if (release) return (BuildMode.release, null);
  if (profile) return (BuildMode.profile, null);
  return (BuildMode.debug, null);
}

final _builders = _loadBuilders();

Map<String, Builder> _loadBuilders() {
  final config = loadConfig();

  return <String, Builder>{
    ...builders,
    ...config.builders,
  };
}

Future<void> _runBuild(
  Builder builder,
  bool clean,
  bool fetch
) async {
  final buildTarget = builder.ninja.config;

  if (clean) {
    print('Cleaning build...');
  
    await _runProcess('autoninja', ['-C', '../out/$buildTarget', '-t', 'clean']);
  }

  if (fetch) {
    print('Fetching dependencies...');
  
    // TODO: gclient variables?
    if (await _runProcess('gclient', ['sync', '-D']) != 0) {
      throw 'Fetching dependencies failed...';
    }
  }

  final buildTargetDir = Directory('../out/$buildTarget');
  if (fetch || !buildTargetDir.existsSync()) {
    final gn = Directory(path.join('tools', 'gn'));
    if (await _runProcess(gn.absolute.path, builder.gn) != 0) {
      throw 'Regenerating build files failed...';
    }
  }

  // TODO: targets
  await _runProcess('autoninja', ['-C', '../out/$buildTarget']);
}

Future<int> _runProcess(String executable, List<String> arguments) async {
  var process = await Process.start(
    executable,
    arguments,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );

  return await process.exitCode;
}
