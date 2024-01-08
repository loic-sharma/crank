import 'dart:io';

import 'builder.dart';

final builders = {
  if (Platform.isLinux) ...{
    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/linux_unopt.json
    'host_debug_unopt': const Builder(
      name: 'host_debug_unopt',
      description: 'Build an unoptimized debug version that targets the host machine',
      gn: [
        '--runtime-mode',
        'debug',
        '--unoptimized',
        '--prebuilt-dart-sdk',
        '--asan',
        '--lsan',
        '--dart-debug',
      ],
      ninja: Ninja(
        config: 'host_debug_unopt',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'test: Host_Tests_for_host_debug_unopt',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_debug_unopt',
            '--type',
            'dart,dart-host,engine',
            '--use-sanitizer-suppressions',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/linux_host_engine.json#L67-L123
    'host_debug': Builder(
      name: 'host_debug',
      description: 'Build a debug version that targets the host machine',
      gn: [
        '--runtime-mode',
        'debug',
        '--prebuilt-dart-sdk',
        '--build-embedder-examples',
      ],
      ninja: Ninja(
        config: 'host_debug',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_debug',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_debug',
            '--type',
            // TODO: CI builder does not run engine test?
            'dart,dart-host,engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/linux_host_engine.json#L124-L171
    'host_profile': const Builder(
      name: 'host_profile',
      description: 'Build a version specialized for performance profiling that targets the host machine',
      gn: [
        '--runtime-mode',
        'profile',
        '--no-lto',
        '--prebuilt-dart-sdk',
        '--build-embedder-examples',
      ],
      ninja: Ninja(
        config: 'host_profile',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_profile',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_profile',
            '--type',
            'dart,dart-host,engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/linux_host_engine.json#L172-L249
    'host_release': const Builder(
      name: 'host_release',
      description: 'Build a release version that targets the host machine',
      gn: [
        '--runtime-mode',
        'release',
        '--prebuilt-dart-sdk',
        '--build-embedder-examples',
      ],
      ninja: Ninja(
        config: 'host_profile',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_profile',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_release',
            '--type',
            'dart,dart-host,engine',
          ],
        ),
      ],
    ),
  },

  if (Platform.isMacOS) ...{
    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/mac_unopt.json
    'host_debug_unopt': const Builder(
      name: 'host_debug_unopt',
      description: 'Build an unoptimized debug version that targets the host machine',
      gn: [
        '--runtime-mode',
        'debug',
        '--unoptimized',
        '--no-lto',
        '--prebuilt-dart-sdk',
      ],
      ninja: Ninja(
        config: 'host_debug_unopt',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_debug_unopt',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_debug_unopt',
            '--type',
            'dart,dart-host,engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/mac_host_engine.json#L3-L67
    'host_debug': Builder(
      name: 'host_debug',
      description: 'Build a debug version that targets the host machine',
      gn: [
        '--runtime-mode',
        'debug',
        '--no-lto',
        '--prebuilt-dart-sdk',
        '--build-embedder-examples',
        '--enable-impeller-vulkan',
        '--use-glfw-swiftshader',
      ],
      ninja: Ninja(
        config: 'host_debug',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_debug',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_debug',
            '--type',
            'dart,dart-host,engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/mac_host_engine.json#L68-L126
    'host_profile': const Builder(
      name: 'host_profile',
      description: 'Build a version specialized for performance profiling that targets the host machine',
      gn: [
        '--runtime-mode',
        'profile',
        '--no-lto',
        '--prebuilt-dart-sdk',
        '--build-embedder-examples',
      ],
      ninja: Ninja(
        config: 'host_profile',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_profile',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_profile',
            '--type',
            'dart,dart-host,engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/mac_host_engine.json#L127-L195
    'host_release': const Builder(
      name: 'host_release',
      description: 'Build a release version that targets the host machine',
      gn: [
        '--runtime-mode',
        'release',
        '--no-lto',
        '--prebuilt-dart-sdk',
        '--build-embedder-examples',
        '--enable-impeller-vulkan',
        '--use-glfw-swiftshader',
      ],
      ninja: Ninja(
        config: 'host_profile',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_profile',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_profile',
            '--type',
            'dart,dart-host,engine',
          ],
        ),
      ],
    ),
  },

  if (Platform.isWindows) ... {
    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/standalone/windows_unopt.json
    'host_debug_unopt': const Builder(
      name: 'host_debug_unopt',
      description: 'Build an unoptimized debug version that targets the host machine',
      gn: [
        '--runtime-mode',
        'debug',
        '--unoptimized',
        '--no-lto',
        '--prebuilt-dart-sdk',
      ],
      ninja: Ninja(
        config: 'host_debug_unopt',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_debug_unopt',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_debug_unopt',
            '--type',
            'engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/windows_host_engine.json#L3-L58
    'host_debug': const Builder(
      name: 'host_debug',
      description: 'Build a debug version that targets the host machine',
      gn: [
        '--runtime-mode',
        'debug',
        '--no-lto',
      ],
      ninja: Ninja(
        config: 'host_debug',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_debug',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_debug',
            '--type',
            'engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/windows_host_engine.json#L59-L92
    'host_profile': const Builder(
      name: 'host_profile',
      description: 'Build a version specialized for performance profiling that targets the host machine',
      gn: [
        '--runtime-mode',
        'profile',
        '--no-lto',
      ],
      ninja: Ninja(
        config: 'host_profile',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_profile',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_profile',
            '--type',
            'engine',
          ],
        ),
      ],
    ),

    // https://github.com/flutter/engine/blob/f346fc9dda5578f701f534942eded4c52a678919/ci/builders/windows_host_engine.json#L93-L127
    'host_release': const Builder(
      name: 'host_release',
      description: 'Build a release version that targets the host machine',
      gn: [
        '--runtime-mode',
        'release',
        '--no-lto',
      ],
      ninja: Ninja(
        config: 'host_release',
      ),
      tests: [
        Test(
          language: 'python3',
          name: 'Host Tests for host_debug',
          script: 'testing/run_tests.py',
          parameters: [
            '--variant',
            'host_debug',
            '--type',
            'engine',
          ],
        ),
      ],
    ),
  },
};
