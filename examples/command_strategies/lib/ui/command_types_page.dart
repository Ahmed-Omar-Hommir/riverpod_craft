import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

import '../providers/commands_provider.dart';

// ── Domain ────────────────────────────────────────────────────────────────────

enum _Mode { concurrent, sequential, droppable, restartable }

enum _Status { running, queued, dropped, cancelled, done }

class _Entry {
  _Entry({required this.id, required this.status, required this.detail});
  final int id;
  _Status status;
  String detail;
}

// ── Palette ───────────────────────────────────────────────────────────────────

const _modeColors = {
  _Mode.concurrent: Color(0xFF2979FF),
  _Mode.sequential: Color(0xFF7C4DFF),
  _Mode.droppable: Color(0xFFE53935),
  _Mode.restartable: Color(0xFFF57C00),
};

const _statusColors = {
  _Status.running: Color(0xFF2979FF),
  _Status.queued: Color(0xFF90A4AE),
  _Status.dropped: Color(0xFFE53935),
  _Status.cancelled: Color(0xFFF57C00),
  _Status.done: Color(0xFF43A047),
};

const _statusIcons = {
  _Status.queued: Icons.more_horiz_rounded,
  _Status.dropped: Icons.close_rounded,
  _Status.cancelled: Icons.close_rounded,
  _Status.done: Icons.check_rounded,
};

const _modeDescriptions = {
  _Mode.concurrent: 'All events process at the same time',
  _Mode.sequential: 'Events queue and process one by one',
  _Mode.droppable: 'New events are ignored while one is processing',
  _Mode.restartable: 'New events cancel the current one',
};

// ── Page ──────────────────────────────────────────────────────────────────────

class CommandTypesPage extends ConsumerStatefulWidget {
  const CommandTypesPage({super.key});

  @override
  ConsumerState<CommandTypesPage> createState() => _CommandTypesPageState();
}

class _CommandTypesPageState extends ConsumerState<CommandTypesPage> {
  _Mode _mode = _Mode.concurrent;

  final _logs = {
    _Mode.concurrent: <_Entry>[],
    _Mode.sequential: <_Entry>[],
    _Mode.droppable: <_Entry>[],
    _Mode.restartable: <_Entry>[],
  };

  int _seq = 1;
  int? _seqRunningId, _dropRunningId, _restartRunningId;

  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<_Entry> get _log => _logs[_mode]!;

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _mark(List<_Entry> log, int id, _Status s, String d) {
    final i = log.indexWhere((e) => e.id == id);
    if (i != -1) { log[i].status = s; log[i].detail = d; }
  }

  // ── Tap ─────────────────────────────────────────────────────────────────────

  void _onTap() {
    switch (_mode) {
      case _Mode.concurrent:   _addConcurrent();
      case _Mode.sequential:   _addSequential();
      case _Mode.droppable:    _addDroppable();
      case _Mode.restartable:  _addRestartable();
    }
    _scrollToBottom();
  }

  void _addConcurrent() {
    final id = _seq++;
    final log = _logs[_Mode.concurrent]!;
    ref.concurrentTaskCommand.run();
    setState(() => log.add(_Entry(id: id, status: _Status.running, detail: 'Processing…')));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _mark(log, id, _Status.done, 'Completed'));
    });
  }

  void _addSequential() {
    final id = _seq++;
    final log = _logs[_Mode.sequential]!;
    final isIdle = !ref.sequentialTaskCommand.read().isLoading && !log.any((e) => e.status == _Status.queued);
    ref.sequentialTaskCommand.run();
    setState(() {
      if (isIdle) {
        _seqRunningId = id;
        log.add(_Entry(id: id, status: _Status.running, detail: 'Processing…'));
      } else {
        log.add(_Entry(id: id, status: _Status.queued, detail: 'Waiting in queue…'));
      }
    });
  }

  void _addDroppable() {
    final id = _seq++;
    final log = _logs[_Mode.droppable]!;
    if (ref.droppableTaskCommand.read().isLoading) {
      setState(() => log.add(_Entry(id: id, status: _Status.dropped, detail: 'Ignored — #$_dropRunningId is processing')));
    } else {
      ref.droppableTaskCommand.run();
      setState(() { _dropRunningId = id; log.add(_Entry(id: id, status: _Status.running, detail: 'Processing…')); });
    }
  }

  void _addRestartable() {
    final id = _seq++;
    final log = _logs[_Mode.restartable]!;
    if (ref.restartableTaskCommand.read().isLoading && _restartRunningId != null) {
      _mark(log, _restartRunningId!, _Status.cancelled, 'Cancelled by #$id');
    }
    ref.restartableTaskCommand.run();
    setState(() { _restartRunningId = id; log.add(_Entry(id: id, status: _Status.running, detail: 'Processing…')); });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _modeColors[_mode]!;
    final log = _log;

    ref.concurrentTaskCommand.watch();
    ref.sequentialTaskCommand.watch();
    ref.droppableTaskCommand.watch();
    ref.restartableTaskCommand.watch();

    // Listeners
    ref.sequentialTaskCommand.listen((p, n) {
      if (p?.isLoading == true && n.isData && _seqRunningId != null) {
        final log = _logs[_Mode.sequential]!;
        setState(() {
          _mark(log, _seqRunningId!, _Status.done, 'Completed');
          _seqRunningId = null;
          final next = log.cast<_Entry?>().firstWhere((e) => e!.status == _Status.queued, orElse: () => null);
          if (next != null) { _seqRunningId = next.id; next.status = _Status.running; next.detail = 'Processing…'; }
        });
      }
    });

    ref.droppableTaskCommand.listen((p, n) {
      if (p?.isLoading == true && n.isData && _dropRunningId != null) {
        setState(() { _mark(_logs[_Mode.droppable]!, _dropRunningId!, _Status.done, 'Completed'); _dropRunningId = null; });
      }
    });

    ref.restartableTaskCommand.listen((p, n) {
      if (p?.isLoading == true && n.isData && _restartRunningId != null) {
        setState(() { _mark(_logs[_Mode.restartable]!, _restartRunningId!, _Status.done, 'Completed'); _restartRunningId = null; });
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text('Command Types',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
            const SizedBox(height: 20),

            // ── Mode selector ──────────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: _Mode.values.map((m) {
                  final sel = _mode == m;
                  final c = _modeColors[m]!;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? c : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: sel ? null : Border.all(color: cs.outlineVariant),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color: sel ? Colors.white : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          child: Text(m.name),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Description ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _modeDescriptions[_mode]!,
                  key: ValueKey(_mode),
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Log header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
              child: Row(children: [
                Text('Events', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                if (log.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${log.length}',
                        style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
                const Spacer(),
                if (log.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() { log.clear(); _seq = 1; }),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Clear'),
                  ),
              ]),
            ),

            // ── Timeline list ──────────────────────────────────────────────
            Expanded(
              child: log.isEmpty
                  ? _EmptyState(key: ValueKey(_mode))
                  : ListView.builder(
                      key: ValueKey(_mode.name),
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      itemCount: log.length,
                      itemBuilder: (_, i) {
                        final entry = log[i];
                        final isLast = i == log.length - 1;
                        return _SlideIn(
                          key: ValueKey(entry.id),
                          child: _TimelineRow(entry: entry, isLast: isLast),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── Button ─────────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: FilledButton(
            onPressed: _onTap,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            child: const Text('+ Add Event'),
          ),
        ),
      ),
    );
  }
}

// ── Timeline row ──────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});
  final _Entry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _statusColors[entry.status]!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline gutter ──
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 4),
                _StatusDot(status: entry.status, color: color),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // ── Content ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Event #${entry.id}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      _StatusBadge(status: entry.status, color: color),
                    ],
                  ),
                  const SizedBox(height: 3),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      entry.detail,
                      key: ValueKey('${entry.id}_${entry.detail}'),
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  if (entry.status == _Status.running) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status dot (pulsing for running) ──────────────────────────────────────────

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.status, required this.color});
  final _Status status;
  final Color color;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  AnimationController? _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _startPulseIfNeeded();
  }

  @override
  void didUpdateWidget(_StatusDot old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) _startPulseIfNeeded();
  }

  void _startPulseIfNeeded() {
    if (widget.status == _Status.running) {
      _pulseCtrl ??= AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    } else {
      _pulseCtrl?.dispose();
      _pulseCtrl = null;
    }
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 14.0;

    if (widget.status == _Status.running && _pulseCtrl != null) {
      return AnimatedBuilder(
        animation: _pulseCtrl!,
        builder: (_, __) {
          final t = _pulseCtrl!.value;
          return SizedBox(
            width: size + 10,
            height: size + 10,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple ring
                Container(
                  width: size + 10 * t,
                  height: size + 10 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.5 * (1 - t)),
                      width: 1.5,
                    ),
                  ),
                ),
                // Solid dot
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
                ),
              ],
            ),
          );
        },
      );
    }

    // Static dot with icon
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: Container(
        key: ValueKey(widget.status),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.status == _Status.queued ? Colors.transparent : widget.color,
          border: widget.status == _Status.queued ? Border.all(color: widget.color, width: 2) : null,
        ),
        child: _statusIcons.containsKey(widget.status)
            ? Icon(_statusIcons[widget.status], size: 10,
                color: widget.status == _Status.queued ? widget.color : Colors.white)
            : null,
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final _Status status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = status.name[0].toUpperCase() + status.name.substring(1);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(
          label,
          key: ValueKey(status),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Slide-in animation ────────────────────────────────────────────────────────

class _SlideIn extends StatefulWidget {
  const _SlideIn({super.key, required this.child});
  final Widget child;

  @override
  State<_SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<_SlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _slide = Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(curve);
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SlideTransition(position: _slide, child: FadeTransition(opacity: _fade, child: widget.child));
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 32, color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('Tap below to add events',
                style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.4), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
