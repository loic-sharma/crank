import 'package:args/args.dart';

// See:
// https://github.com/flutter/engine/blob/da62280332cb6e73d082b7f5e0288972991c712e/tools/gn#L846-L1307
final args = ArgParser()
  ..addFlag('asan', negatable: false)
  ..addFlag('android', negatable: false)
  ..addFlag('build-embedder-examples', negatable: false)
  ..addFlag('dart-debug', negatable: false)
  ..addFlag('enable-fontconfig', negatable: false)
  ..addFlag('enable-impeller-vulkan', negatable: false)
  ..addFlag('enable-vulkan-validation-layers', negatable: false)
  ..addFlag('embedder-for-target', negatable: false)
  ..addFlag('darwin-extension-safe', negatable: false)
  ..addFlag('force-mac-arm64', negatable: false)
  ..addFlag('fuchsia', negatable: false)
  ..addFlag('goma', negatable: true)
  ..addFlag('impeller-cmake-example', negatable: true)
  ..addFlag('ios', negatable: true)
  ..addFlag('lto', negatable: true, defaultsTo: true)
  ..addFlag('lsan', negatable: false)
  ..addFlag('prebuilt-dart-sdk', negatable: false)
  ..addFlag('rbe', negatable: true)
  ..addFlag('simulator', negatable: true)
  ..addFlag('unoptimized', negatable: false)
  ..addFlag('use-glfw-swiftshader', negatable: false)
  ..addFlag('web', negatable: false)
  ..addFlag('xcode-symlinks', negatable: false)
  ..addOption(
    'android-cpu',
    allowed: ['arm', 'arm64', 'x64', 'x86'],
    defaultsTo: 'arm',
  )
  ..addOption(
    'fuchsia-cpu',
    allowed: ['arm64', 'x64'],
    defaultsTo: 'x64',
  )
  ..addOption(
    'ios-cpu',
    allowed: ['arm', 'arm64'],
    defaultsTo: 'arm',
  )
  ..addOption(
    'linux-cpu',
    allowed: ['arm', 'arm64', 'x64', 'x86'],
  )
  ..addOption(
    'mac-cpu',
    allowed: ['arm64', 'x64'],
    defaultsTo: 'x64',
  )
  ..addOption(
    'runtime-mode',
    allowed: ['debug', 'profile', 'release', 'jit_release'],
    defaultsTo: 'debug',
  )
  ..addOption(
    'simulator-cpu',
    allowed: ['arm64'],
  )
  ..addOption('target-dir')
  ..addOption(
    'target-os',
    allowed: ['linux'],
  )
  ..addOption(
    'windows-cpu',
    allowed: ['arm64', 'x64', 'x86'],
    defaultsTo: 'x64',
  );
