import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_gen/riverpod_gen.dart';

import '../models/note.dart';
import '../providers/note_detail_provider.dart';
import '../providers/notes_provider.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late NoteCategory _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _category = NoteCategory.personal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _startEditing(Note note) {
    setState(() {
      _isEditing = true;
      _titleController.text = note.title;
      _bodyController.text = note.body;
      _category = note.category;
    });
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.noteDetailProvider(id: widget.noteId).watch();
    final updateState = ref.notesProvider.updateNoteCommand.watch();
    final deleteState = ref.notesProvider.deleteNoteCommand.watch();
    final isSaving = updateState.isLoading;

    // Listen for update completion
    ref.notesProvider.updateNoteCommand.listen((prev, next) {
      next.whenOrNull(
        data: (arg, updatedNote) {
          setState(() => _isEditing = false);
          ref.noteDetailProvider(id: widget.noteId).invalidate();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note updated')));
          ref.notesProvider.updateNoteCommand.reset();
        },
        error: (arg, error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Update failed: $error')));
        },
      );
    });

    // Listen for delete completion
    ref.notesProvider.deleteNoteCommand.listen((prev, next) {
      next.whenOrNull(
        data: (arg, _) {
          Navigator.of(context).pop();
          ref.notesProvider.deleteNoteCommand.reset();
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Note'),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: isSaving ? null : _cancelEditing,
              child: const Text('Cancel'),
            ),
          ] else ...[
            if (detailState.isData)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: deleteState.isLoading
                    ? null
                    : () => _confirmDelete(context),
              ),
          ],
        ],
      ),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (note) =>
            _isEditing ? _buildEditView(note, isSaving) : _buildReadView(note),
        error: (error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load note'),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () =>
                    ref.noteDetailProvider(id: widget.noteId).reload(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_isEditing && detailState.isData
          ? FloatingActionButton(
              onPressed: () =>
                  _startEditing((detailState as DataSuccess<Note>).data),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildReadView(Note note) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCategoryChip(note.category),
              const SizedBox(width: 12),
              Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(note.updatedAt),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            note.body,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(Note note, bool isSaving) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<NoteCategory>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: NoteCategory.values
                .where((c) => c != NoteCategory.all)
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(_categoryLabel(c)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 12,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: isSaving ? null : () => _saveChanges(note),
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(isSaving ? 'Saving...' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  void _saveChanges(Note note) {
    final updated = note.copyWith(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      category: _category,
    );
    ref.notesProvider.updateNoteCommand.run(note: updated);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.notesProvider.deleteNoteCommand.run(id: widget.noteId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(NoteCategory category) {
    final (color, label) = switch (category) {
      NoteCategory.all => (Colors.grey, 'All'),
      NoteCategory.work => (Colors.blue, 'Work'),
      NoteCategory.personal => (Colors.green, 'Personal'),
      NoteCategory.ideas => (Colors.orange, 'Ideas'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_categoryIcon(category), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(NoteCategory c) => switch (c) {
    NoteCategory.all => 'All',
    NoteCategory.work => 'Work',
    NoteCategory.personal => 'Personal',
    NoteCategory.ideas => 'Ideas',
  };

  IconData _categoryIcon(NoteCategory c) => switch (c) {
    NoteCategory.all => Icons.dashboard_outlined,
    NoteCategory.work => Icons.work_outline,
    NoteCategory.personal => Icons.person_outline,
    NoteCategory.ideas => Icons.lightbulb_outline,
  };

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = date.hour > 12 ? date.hour - 12 : date.hour;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $h:$min $ampm';
  }
}
