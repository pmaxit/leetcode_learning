import 'package:args/args.dart';
import 'package:leetcode/LCManager.dart';
import 'package:leetcode/problems.dart';

import 'api.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )
    ..addOption(
      'count',
      abbr: 'c',
      help: 'Number of problems to fetch',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart leetcode.dart <flags> [arguments]');
  print(argParser.usage);
}


void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();

  // create LCManager 
  final manager = LCManager.fromEnv();
  await manager.db.connect();


  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('leetcode version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    if(results.wasParsed('count') | true){
      int count = int.tryParse(results['count'] ?? '10') ?? 10;
      await callAPI(manager, count);
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }

  await manager.close();
}
