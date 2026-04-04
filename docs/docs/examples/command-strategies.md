---
sidebar_position: 6
---

# Command Strategies

An interactive app that visualizes how the four command strategies behave differently. Pick a mode, tap the button rapidly, and watch the event log.

**What you'll learn:**
- `@concurrent` — all events process at the same time
- `@sequential` — events queue and process one by one
- `@droppable` — new events are ignored while one is processing
- `@restartable` — each new event cancels the previous one

[Source code](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/examples/command_strategies)

---

## Provider

Four identical 2-second tasks, each with a different strategy annotation:

```dart
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
```

The tasks are identical on purpose — the only difference is the strategy annotation. This makes it easy to compare behavior side by side.

---

## What happens when you tap 5 times quickly

### `@concurrent`

All five run at the same time. Each finishes independently after 2 seconds.

```
Event #1  Running
Event #2  Running
Event #3  Running
Event #4  Running
Event #5  Running
          ↓ 2s later
Event #1  Done
Event #2  Done
Event #3  Done
Event #4  Done
Event #5  Done
```

### `@sequential`

Events queue up and process one at a time, in order.

```
Event #1  Running
Event #2  Queued
Event #3  Queued
Event #4  Queued
Event #5  Queued
          ↓ 2s later
Event #1  Done
Event #2  Running  ← auto-starts
Event #3  Queued
...
```

### `@droppable`

Only the first event runs. The rest are ignored because a task is already in progress.

```
Event #1  Running
Event #2  Dropped
Event #3  Dropped
Event #4  Dropped
Event #5  Dropped
          ↓ 2s later
Event #1  Done
```

### `@restartable`

Each new event cancels the previous one. Only the last event completes.

```
Event #1  Cancelled
Event #2  Cancelled
Event #3  Cancelled
Event #4  Cancelled
Event #5  Running
          ↓ 2s later
Event #5  Done
```

---

## When to use each strategy

| Strategy | Use case |
|----------|----------|
| `@concurrent` | Independent operations that don't conflict (e.g., uploading multiple files) |
| `@sequential` | Operations that must complete in order (e.g., sequential API calls) |
| `@droppable` | Prevent duplicate submissions (e.g., form submit, delete button) |
| `@restartable` | Only the latest matters (e.g., search-as-you-type, live filters) |
