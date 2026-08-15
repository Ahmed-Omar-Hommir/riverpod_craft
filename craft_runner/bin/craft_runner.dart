import 'dart:io';

import 'package:craft_runner/src/bootstrap.dart';
import 'package:craft_runner/src/config.dart';
import 'package:craft_runner/src/version.dart';

const _usage = '''
craft_runner $craftRunnerVersion — incremental code generation.

Usage:
  craft_runner craft        build once and exit
  craft_runner watch        build, then rebuild on every save
  craft_runner --version
  craft_runner --help

Reads craft_runner.yaml from the project root:

  roots: [lib, test]
  exclude: ['.craft.dart', '.g.dart', '.freezed.dart']
  builders:
    riverpod_craft_plugin:RiverpodCraftBuilder:
      error_mapper: lib/error_mapper.dart

Each builder extends CraftBuilderSingleFile or CraftBuilderMultiFile and
provides a `fromConfig(Map<String, Object?>)` factory.
''';

const _commands = {'craft', 'watch'};

Future<void> main(List<String> args) async {
  if (args.contains('--version') || args.contains('-v')) {
    stdout.writeln(craftRunnerVersion);
    return;
  }
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    stdout.write(_usage);
    return;
  }

  final command = args.first;
  if (!_commands.contains(command)) {
    stderr
      ..writeln('craft_runner: unknown command "$command"\n')
      ..write(_usage);
    exitCode = 1;
    return;
  }

  final rootDir = Directory.current.path;
  try {
    final config = CraftConfig.load(rootDir);
    final binary = await Bootstrap(
      rootDir,
      config,
    ).resolveBinary(log: stdout.writeln);
    final process = await Process.start(
      binary,
      args,
      mode: ProcessStartMode.inheritStdio,
      workingDirectory: rootDir,
    );
    exitCode = await process.exitCode;
  } on CraftConfigError catch (error) {
    stderr
      ..writeln(error)
      ..writeln()
      ..write(_usage);
    exitCode = 1;
  }
}
