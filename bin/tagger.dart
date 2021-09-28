import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:shell/shell.dart';
import 'package:version/version.dart';

void main(List<String> arguments) async {
  var parser = CommandRunner<int>('tagger',
      'Automatically move semantic tags. When providing the tag \'1.2.3\', \'1\' and \'1.2\' will be moved to the position of \'1.2.3\'.')
    ..addCommand(MoveCommand());

  try {
    exit(await parser.run(arguments) ?? 0);
  } on UsageException catch (e) {
    print(e);
    exit(1);
  }
}

class MoveCommand extends Command<int> {
  @override
  String get description => 'Move the tags.';

  @override
  String get name => 'move';

  MoveCommand() {
    argParser
      ..addOption(
        'prefix',
        abbr: 'p',
        defaultsTo: '',
        valueHelp: 'v',
        help: 'The prefix of your tags.',
      )
      ..addFlag(
        'skip',
        abbr: 's',
        defaultsTo: false,
        help: 'Skip non semantic tags.',
      );
  }

  @override
  String get invocation =>
      super.invocation.replaceFirst('[arguments]', '<tag> [arguments]');

  @override
  Future<int> run() async {
    if (argResults.rest.isEmpty) {
      usageException('Must specify a tag.');
    }
    var prefix = argResults['prefix'] as String;
    var skip = argResults['skip'] as bool;
    var tags = <Version>[];
    for (var tag in argResults.rest) {
      if (!tag.startsWith(prefix)) {
        if (skip) {
          print('\'$tag\' does not start with \'$prefix\'! Skipping.');
        } else {
          usageException('\'$tag\' does not start with \'$prefix\'!');
        }
      }
      try {
        var version = Version.parse(tag.substring(prefix.length));
        if (version.isPreRelease) {
          print('Skip prerelease $tag');
        } else {
          tags.add(version);
        }
      } on FormatException catch (_) {
        if (skip) {
          print('\'$tag\' is not a valid semantic tag name! Skipping.');
        } else {
          usageException('\'$tag\' is not a valid semantic tag name!');
        }
      }
    }

    var shell = Shell();
    for (var tag in tags) {
      for (var moveTag in [
        '$prefix${tag.major}',
        '$prefix${tag.major}.${tag.minor}',
      ]) {
        var result = await shell.run('git', arguments: [
          'tag',
          '-f',
          moveTag,
          '$prefix${tag.toString()}',
        ]);
        if (result.exitCode == 0) {
          var out = result.stdout.toString();
          print(out.isEmpty ? 'Created tag \'$moveTag\'' : out);
        } else {
          print('Failed to move $moveTag to $tag');
          print(result.stderr);
          return 1;
        }
      }
    }

    return 0;
  }
}
