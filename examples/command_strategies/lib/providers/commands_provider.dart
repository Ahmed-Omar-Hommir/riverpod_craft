import 'package:riverpod_craft/riverpod_craft.dart';

part 'commands_provider.craft.dart';

@command
@concurrent
Future<String> concurrentTask(Ref ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Done';
}

@command
@sequential
Future<String> sequentialTask(Ref ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Done';
}

@command
@droppable
Future<String> droppableTask(Ref ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Done';
}

@command
@restartable
Future<String> restartableTask(Ref ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Done';
}
