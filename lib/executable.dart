import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> args) async {
  final runner = CommandRunner('crank', 'Flutter engine tool');
  runner.addCommand(BuildCommand());
  runner.addCommand(CleanCommand());
  runner.addCommand(FetchCommand());
  runner.addCommand(RunCommand());
  runner.addCommand(TestCommand());

  await runner.run(args);
}

class BuildCommand extends Command {
  @override
  final String name = 'build';

  @override
  final String description = 'Build the Flutter engine';

  BuildCommand() {
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
    _addBuildModeFlags(argParser);
  }

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    final args = argResults!;
    final clean = args['clean'] as bool;
    final fetch = args['fetch'] as bool;

    final (buildMode, buildModeError) = _parseBuildMode(args);
    if (buildModeError != null) {
      usageException(buildModeError);
    }

    await _runBuild(buildMode, clean, fetch);
  }
}

class RunCommand extends Command {
  @override
  final String name = 'run';

  @override
  final String description = 'Run a Flutter app using a locally built engine';

  RunCommand() {
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
    final device = args['device-id'] as String?;
    final (buildMode, buildModeError) = _parseBuildMode(args);
    if (buildModeError != null) {
      usageException(buildModeError);
    }

    final buildTarget = 'host_${buildMode}_unopt';

    await _runProcess(
      'flutter', [
        'run',
        '--local-engine', buildTarget,
        '--local-engine-host', buildTarget,
        if (device != null) ... [
          '--device-id', device,
        ],
      ],
    );
  }
}

class TestCommand extends Command {
  @override
  final String name = 'test';

  @override
  final String description = "Run the Flutter engine's tests";

  TestCommand() {
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
    _addBuildModeFlags(argParser);
  }

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    final args = argResults!;
    var filter = args['filter'] as String;

    var build = args['build'] as bool;
    final clean = args['clean'] as bool;
    final fetch = args['fetch'] as bool;
    if (clean || fetch) {
      build = true;
    }

    final (buildMode, buildModeError) = _parseBuildMode(args);
    if (buildModeError != null) {
      usageException(buildModeError);
    }

    if (build) {
      await _runBuild(buildMode, clean, fetch);
    }

    final testPath = path.join('..', 'out', 'host_${buildMode}_unopt', 'flutter_windows_unittests.exe');
    final testExe = path.normalize(File(testPath).absolute.path);

    await _runProcess(testExe, ['--repeat=1', '--gtest_filter=$filter']);
  }
}

class FetchCommand extends Command {
  @override
  final String name = 'fetch';

  @override
  final String description = "Download the Flutter engine's dependencies";

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    if (await _runProcess('gclient', ['sync', '-D']) != 0) {
      throw 'Fetching dependencies failed...';
    }

    final gn = Directory(path.join('tools', 'gn')).absolute.path;
    if (await _runProcess(gn, ['--unoptimized', '--no-lto', '--no-goma']) != 0) {
      throw 'Regenerating build files failed...';
    }
  }
}

class CleanCommand extends Command {
  @override
  final String name = 'clean';

  @override
  final String description = "Clean the Flutter engine's build directory";

  CleanCommand() {
    _addBuildModeFlags(argParser);
  }

  @override
  Future<void> run() async {
    if (!Directory('fml').existsSync()) {
      throw 'crank build must be run in the engine repository';
    }

    final args = argResults!;
    final (buildMode, buildModeError) = _parseBuildMode(args);
    if (buildModeError != null) {
      usageException(buildModeError);
    }

    await _runProcess('autoninja', ['-C', '../out/host_${buildMode}_unopt', '-t', 'clean']);
  }
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

Future<void> _runBuild(
  BuildMode buildMode,
  bool clean,
  bool fetch
) async {
  final buildTarget = 'host_${buildMode}_unopt';

  if (clean) {
    print('Cleaning build...');
  
    await _runProcess('autoninja', ['-C', '../out/$buildTarget', '-t', 'clean']);
  }

  if (fetch) {
    print('Fetching dependencies...');
  
    if (await _runProcess('gclient', ['sync', '-D']) != 0) {
      throw 'Fetching dependencies failed...';
    }

    final gn = Directory(path.join('tools', 'gn')).absolute.path;
    if (await _runProcess(gn, ['--unoptimized', '--no-lto', '--no-goma']) != 0) {
      throw 'Regenerating build files failed...';
    }
  }

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
