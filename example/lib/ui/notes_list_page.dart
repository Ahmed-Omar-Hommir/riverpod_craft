import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_gen/riverpod_gen.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/category_filter_provider.dart';
import '../providers/search_query_provider.dart';
import 'add_note_dialog.dart';
import 'note_detail_page.dart';

class NotesListPage extends ConsumerStatefulWidget {
  const NotesListPage({super.key});

  @override
  ConsumerState<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends ConsumerState<NotesListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.notesProvider.watch();
    final selectedCategory = ref.categoryFilterProvider.watch();
    final searchQuery = ref.searchQueryProvider.watch();

    // Listen for delete command completion
    ref.notesProvider.deleteNoteCommand.listen((prev, next) {
      next.whenOrNull(
        data: (arg, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted')),
          );
        },
        error: (arg, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $error')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.searchQueryProvider.setState('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                ref.searchQueryProvider.setState(value);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _CategoryChips(selectedCategory: selectedCategory),
          Expanded(
            child: notesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (notes) {
                final filtered = _filterNotes(
                  notes,
                  selectedCategory,
                  searchQuery,
                );
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'No notes match your search'
                              : 'No notes yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        if (searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to create one',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.notesProvider.reload(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return _NoteCard(note: note);
                    },
                  ),
                );
              },
              error: (error) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text('Failed to load notes'),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => ref.notesProvider.reload(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  List<Note> _filterNotes(
    List<Note> notes,
    NoteCategory category,
    String query,
  ) {
    var filtered = notes;
    if (category != NoteCategory.all) {
      filtered = filtered.where((n) => n.category == category).toList();
    }
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      filtered = filtered
          .where(
            (n) =>
                n.title.toLowerCase().contains(lower) ||
                n.body.toLowerCase().contains(lower),
          )
          .toList();
    }
    return filtered;
  }

  void _showAddNoteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddNoteDialog(),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.selectedCategory});

  final NoteCategory selectedCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: NoteCategory.values.map((category) {
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_categoryLabel(category)),
              selected: isSelected,
              onSelected: (_) {
                ref.categoryFilterProvider.setState(category);
              },
              avatar: isSelected
                  ? null
                  : Icon(_categoryIcon(category), size: 18),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _categoryLabel(NoteCategory category) {
    return switch (category) {
      NoteCategory.all => 'All',
      NoteCategory.work => 'Work',
      NoteCategory.personal => 'Personal',
      NoteCategory.ideas => 'Ideas',
    };
  }

  IconData _categoryIcon(NoteCategory category) {
    return switch (category) {
      NoteCategory.all => Icons.dashboard_outlined,
      NoteCategory.work => Icons.work_outline,
      NoteCategory.personal => Icons.person_outline,
      NoteCategory.ideas => Icons.lightbulb_outline,
    };
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        ref.notesProvider.deleteNoteCommand.run(id: note.id);
        return true;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NoteDetailPage(noteId: note.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _CategoryBadge(category: note.category),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(note.updatedAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final NoteCategory category;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (category) {
      NoteCategory.all => (Colors.grey, 'All'),
      NoteCategory.work => (Colors.blue, 'Work'),
      NoteCategory.personal => (Colors.green, 'Personal'),
      NoteCategory.ideas => (Colors.orange, 'Ideas'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
