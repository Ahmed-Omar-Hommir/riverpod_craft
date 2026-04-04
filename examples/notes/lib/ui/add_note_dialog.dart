import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';

class AddNoteDialog extends ConsumerStatefulWidget {
  const AddNoteDialog({super.key});

  @override
  ConsumerState<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  NoteCategory _category = NoteCategory.personal;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addNoteState = ref.notesProvider.addNoteCommand.watch();
    final isLoading = addNoteState.isLoading;

    // Listen for add command result
    ref.notesProvider.addNoteCommand.listen((prev, next) {
      next.whenOrNull(
        data: (arg, note) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Created "${note.title}"')),
          );
          ref.notesProvider.addNoteCommand.reset();
        },
        error: (arg, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $error')),
          );
        },
      );
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_add,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'New Note',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
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
                    child: Row(
                      children: [
                        Icon(_categoryIcon(c), size: 20),
                        const SizedBox(width: 8),
                        Text(_categoryLabel(c)),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(isLoading ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }
    ref.notesProvider.addNoteCommand.run(
      title: title,
      body: body,
      category: _category,
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
}
