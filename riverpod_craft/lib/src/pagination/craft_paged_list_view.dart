import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'paged_data_state.dart';

/// A paginated list view that works with riverpod_craft paginated providers.
///
/// Bridges [PagedDataState] from your provider to
/// [PagedListView] from `infinite_scroll_pagination`.
///
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final facade = ref.notesProvider(category: 'work');
///   final state = facade.watch();
///
///   return CraftPagedListView<Note>(
///     state: state,
///     fetchNextPage: facade.fetchNextPage,
///     itemBuilder: (context, note, index) => ListTile(title: Text(note.title)),
///   );
/// }
/// ```
class CraftPagedListView<T> extends StatefulWidget {
  const CraftPagedListView({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.itemBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
    this.padding,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : _separatorBuilder = null;

  const CraftPagedListView.separated({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.itemBuilder,
    required Widget Function(BuildContext context, int index) separatorBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
    this.padding,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : _separatorBuilder = separatorBuilder;

  /// The current pagination state from your provider's `.watch()`.
  final PagedDataState<T> state;

  /// Called when the next page needs to be loaded.
  /// Pass your provider facade's `.fetchNextPage`.
  final Future<void> Function() fetchNextPage;

  /// Builds each item in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Builds the separator between items (for `.separated` constructor).
  final Widget Function(BuildContext context, int index)? _separatorBuilder;

  /// Shown when the list is empty (loaded but no items).
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Shown while the first page is loading.
  final Widget Function(BuildContext context)? firstPageLoadingBuilder;

  /// Shown when the first page fails to load.
  final Widget Function(BuildContext context, Object? error)?
      firstPageErrorBuilder;

  /// Shown at the bottom while a new page is loading.
  final Widget Function(BuildContext context)? newPageLoadingBuilder;

  /// Shown at the bottom when a new page fails to load.
  final Widget Function(BuildContext context, Object? error)?
      newPageErrorBuilder;

  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;

  @override
  State<CraftPagedListView<T>> createState() => _CraftPagedListViewState<T>();
}

class _CraftPagedListViewState<T> extends State<CraftPagedListView<T>> {
  late PagingController<int, T> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((_) {
      widget.fetchNextPage();
    });
    _syncState();
  }

  @override
  void didUpdateWidget(CraftPagedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _syncState();
    }
  }

  void _syncState() {
    _pagingController.value = widget.state.pagingState;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delegate = PagedChildBuilderDelegate<T>(
      itemBuilder: (context, item, index) =>
          widget.itemBuilder(context, item, index),
      noItemsFoundIndicatorBuilder: widget.emptyBuilder,
      firstPageProgressIndicatorBuilder: widget.firstPageLoadingBuilder,
      firstPageErrorIndicatorBuilder: widget.firstPageErrorBuilder != null
          ? (context) =>
              widget.firstPageErrorBuilder!(context, widget.state.error)
          : null,
      newPageProgressIndicatorBuilder: widget.newPageLoadingBuilder,
      newPageErrorIndicatorBuilder: widget.newPageErrorBuilder != null
          ? (context) =>
              widget.newPageErrorBuilder!(context, widget.state.error)
          : null,
    );

    if (widget._separatorBuilder != null) {
      return PagedListView<int, T>.separated(
        pagingController: _pagingController,
        builderDelegate: delegate,
        separatorBuilder: widget._separatorBuilder!,
        padding: widget.padding,
        scrollController: widget.scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        cacheExtent: widget.cacheExtent,
        dragStartBehavior: widget.dragStartBehavior,
      );
    }

    return PagedListView<int, T>(
      pagingController: _pagingController,
      builderDelegate: delegate,
      padding: widget.padding,
      scrollController: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
    );
  }
}

/// A paginated sliver list view for use inside [CustomScrollView].
///
/// Same API as [CraftPagedListView] but renders as a sliver.
class CraftPagedSliverListView<T> extends StatefulWidget {
  const CraftPagedSliverListView({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.itemBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
  }) : _separatorBuilder = null;

  const CraftPagedSliverListView.separated({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.itemBuilder,
    required Widget Function(BuildContext context, int index) separatorBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
  }) : _separatorBuilder = separatorBuilder;

  final PagedDataState<T> state;
  final Future<void> Function() fetchNextPage;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? _separatorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? firstPageLoadingBuilder;
  final Widget Function(BuildContext context, Object? error)?
      firstPageErrorBuilder;
  final Widget Function(BuildContext context)? newPageLoadingBuilder;
  final Widget Function(BuildContext context, Object? error)?
      newPageErrorBuilder;

  @override
  State<CraftPagedSliverListView<T>> createState() =>
      _CraftPagedSliverListViewState<T>();
}

class _CraftPagedSliverListViewState<T>
    extends State<CraftPagedSliverListView<T>> {
  late PagingController<int, T> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((_) {
      widget.fetchNextPage();
    });
    _syncState();
  }

  @override
  void didUpdateWidget(CraftPagedSliverListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _syncState();
    }
  }

  void _syncState() {
    _pagingController.value = widget.state.pagingState;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delegate = PagedChildBuilderDelegate<T>(
      itemBuilder: (context, item, index) =>
          widget.itemBuilder(context, item, index),
      noItemsFoundIndicatorBuilder: widget.emptyBuilder,
      firstPageProgressIndicatorBuilder: widget.firstPageLoadingBuilder,
      firstPageErrorIndicatorBuilder: widget.firstPageErrorBuilder != null
          ? (context) =>
              widget.firstPageErrorBuilder!(context, widget.state.error)
          : null,
      newPageProgressIndicatorBuilder: widget.newPageLoadingBuilder,
      newPageErrorIndicatorBuilder: widget.newPageErrorBuilder != null
          ? (context) =>
              widget.newPageErrorBuilder!(context, widget.state.error)
          : null,
    );

    if (widget._separatorBuilder != null) {
      return PagedSliverList<int, T>.separated(
        pagingController: _pagingController,
        builderDelegate: delegate,
        separatorBuilder: widget._separatorBuilder!,
      );
    }

    return PagedSliverList<int, T>(
      pagingController: _pagingController,
      builderDelegate: delegate,
    );
  }
}
