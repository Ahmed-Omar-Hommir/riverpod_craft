import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'craft_builder.dart';
import 'source_cache.dart';

class CraftRunner {
  CraftRunner({
    required this.builders,
    String? rootDir,
    List<String> roots = const ['lib', 'test'],
    List<String> exclude = const ['.craft.dart', '.g.dart', '.freezed.dart'],
    this.log = print,
  })  : rootDir = rootDir ?? Directory.current.path,
        _cache = SourceCache(
          rootDir: rootDir ?? Directory.current.path,
          roots: roots,
          exclude: exclude,
        );

  final List<CraftBuilder> builders;
  final String rootDir;
  final void Function(String) log;

  final SourceCache _cache;

  Future<void> run() async {
    final lock = _acquireLock();
    if (lock == null) {
      log('craft · already running in $rootDir');
      exitCode = 1;
      return;
    }
    try {
      start();
      await _watch();
    } finally {
      lock.closeSync();
    }
  }

  /// One watcher per project. Two would each rebuild every change, and each
  /// one's output would wake the other. The OS releases this if we die.
  RandomAccessFile? _acquireLock() {
    final file = File(p.join(rootDir, '.dart_tool', 'craft_runner.lock'));
    file.parent.createSync(recursive: true);
    final handle = file.openSync(mode: FileMode.write);
    try {
      handle.lockSync(FileLock.exclusive);
      return handle;
    } on FileSystemException {
      handle.closeSync();
      return null;
    }
  }

  void start() {
    final started = Stopwatch()..start();
    _cache.loadAll();
    final parsed = started.elapsedMilliseconds;

    for (final builder in builders) {
      if (builder is CraftBuilderSingleFile) {
        _cache.inScope(builder.scope).forEach((path, result) {
          _guard(builder, path, () => builder.build(path, result));
        });
      } else if (builder is CraftBuilderMultiFile) {
        _runMulti(builder);
      }
    }

    _syncWrites();
    log(
      'craft · ready in ${started.elapsedMilliseconds}ms (parse ${parsed}ms) · '
      '${_cache.length} files · ${builders.length} builders',
    );
  }

  void rebuild(List<String> paths) {
    final started = Stopwatch()..start();
    final changed = paths.where(_cache.refresh).toList();
    if (changed.isEmpty) return;

    final multiDone = <CraftBuilderMultiFile>{};
    for (final path in changed) {
      for (final builder in builders) {
        if (!_cache.covers(path, builder.scope)) continue;

        if (builder is CraftBuilderSingleFile) {
          final result = _cache[path];
          if (result == null) continue;
          _guard(builder, path, () => builder.build(path, result));
        } else if (builder is CraftBuilderMultiFile && multiDone.add(builder)) {
          _runMulti(builder);
        }
      }
    }

    _syncWrites();
    final label =
        changed.length == 1 ? changed.single : '${changed.length} files';
    log('craft · ${started.elapsedMilliseconds}ms · $label');
  }

  /// Pull our own output into the cache so the watcher event it produces is
  /// seen as unchanged. macOS fires several events per write, so suppressing
  /// one by path is not enough.
  void _syncWrites() {
    for (final path in craftWrites.toList()) {
      craftWrites.remove(path);
      if (_cache.covers(path)) _cache.refresh(path);
    }
  }

  void _runMulti(CraftBuilderMultiFile builder) {
    _guard(builder, '<scope>', () => builder.build(_cache.inScope(builder.scope)));
  }

  void _guard(CraftBuilder builder, String path, void Function() body) {
    try {
      body();
    } catch (error, stack) {
      log('craft · ${builder.runtimeType} failed on $path: $error');
      log('$stack');
    }
  }

  Future<void> _watch() async {
    final pending = <String>{};
    Timer? debounce;

    void schedule() {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 30), () {
        final paths = pending.toList()..sort();
        pending.clear();
        rebuild(paths);
      });
    }

    for (final root in _cache.roots) {
      final directory = Directory(p.join(rootDir, root));
      if (!directory.existsSync()) continue;
      directory.watch(recursive: true).listen((event) {
        final path = p.relative(event.path, from: rootDir).replaceAll(r'\', '/');
        if (!_cache.covers(path)) return;
        pending.add(path);
        schedule();
      });
    }

    await ProcessSignal.sigint.watch().first;
    log('\ncraft · stopped');
  }
}
