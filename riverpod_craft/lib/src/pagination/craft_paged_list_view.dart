import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'paged_data_provider_facade.dart';

/// A paginated list view that works with riverpod_craft paginated providers.
///
/// Pass the provider facade — the widget calls `.of(ref)` internally
/// to watch state and trigger `fetchNextPage`.
///
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   return CraftPagedListView<Note>(
///     provider: ref.notesProvider(category: 'work'),
///     itemBuilder: (context, note, index) => ListTile(title: Text(note.title)),
///   );
/// }
/// ```
class CraftPagedListView<T> extends ConsumerStatefulWidget {
  const CraftPagedListView({
    super.key,
    required this.provider,
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
    required this.provider,
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

  /// The paginated provider value.
  ///
  /// Pass the facade from your extension:
  /// `ref.notesProvider(category: 'work')`
  final PagedProviderValue<T> provider;

  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? _separatorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? firstPageLoadingBuilder;
  final Widget Function(BuildContext context, Object? error)?
      firstPageErrorBuilder;
  final Widget Function(BuildContext context)? newPageLoadingBuilder;
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
  ConsumerState<CraftPagedListView<T>> createState() =>
      _CraftPagedListViewState<T>();
}

class _CraftPagedListViewState<T>
    extends ConsumerState<CraftPagedListView<T>> {
  late PagingController<int, T> _pagingController;
  late PagedDataProviderFacade<T> _facade;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((_) {
      _facade.fetchNextPage();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _facade = widget.provider.of(ref);
    final state = _facade.watch();
    _pagingController.value = state.pagingState;

    final delegate = PagedChildBuilderDelegate<T>(
      itemBuilder: (context, item, index) =>
          widget.itemBuilder(context, item, index),
      noItemsFoundIndicatorBuilder: widget.emptyBuilder,
      firstPageProgressIndicatorBuilder: widget.firstPageLoadingBuilder,
      firstPageErrorIndicatorBuilder: widget.firstPageErrorBuilder != null
          ? (context) => widget.firstPageErrorBuilder!(context, state.error)
          : null,
      newPageProgressIndicatorBuilder: widget.newPageLoadingBuilder,
      newPageErrorIndicatorBuilder: widget.newPageErrorBuilder != null
          ? (context) => widget.newPageErrorBuilder!(context, state.error)
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
class CraftPagedSliverListView<T> extends ConsumerStatefulWidget {
  const CraftPagedSliverListView({
    super.key,
    required this.provider,
    required this.itemBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
  }) : _separatorBuilder = null;

  const CraftPagedSliverListView.separated({
    super.key,
    required this.provider,
    required this.itemBuilder,
    required Widget Function(BuildContext context, int index) separatorBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
  }) : _separatorBuilder = separatorBuilder;

  final PagedProviderValue<T> provider;
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
  ConsumerState<CraftPagedSliverListView<T>> createState() =>
      _CraftPagedSliverListViewState<T>();
}

class _CraftPagedSliverListViewState<T>
    extends ConsumerState<CraftPagedSliverListView<T>> {
  late PagingController<int, T> _pagingController;
  late PagedDataProviderFacade<T> _facade;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener((_) {
      _facade.fetchNextPage();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _facade = widget.provider.of(ref);
    final state = _facade.watch();
    _pagingController.value = state.pagingState;

    final delegate = PagedChildBuilderDelegate<T>(
      itemBuilder: (context, item, index) =>
          widget.itemBuilder(context, item, index),
      noItemsFoundIndicatorBuilder: widget.emptyBuilder,
      firstPageProgressIndicatorBuilder: widget.firstPageLoadingBuilder,
      firstPageErrorIndicatorBuilder: widget.firstPageErrorBuilder != null
          ? (context) => widget.firstPageErrorBuilder!(context, state.error)
          : null,
      newPageProgressIndicatorBuilder: widget.newPageLoadingBuilder,
      newPageErrorIndicatorBuilder: widget.newPageErrorBuilder != null
          ? (context) => widget.newPageErrorBuilder!(context, state.error)
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
