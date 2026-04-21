import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

/// A paginated list view that works with riverpod_craft paginated providers.
///
/// Pass the provider facade — the widget calls `.of(ref)` internally
/// to watch state and trigger `fetchNextPage`.
///
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   return CraftPagedListView<Note>(
///     providerValue: ref.notesProvider(category: 'work'),
///     itemBuilder: (context, note, index) => ListTile(title: Text(note.title)),
///   );
/// }
/// ```
class CraftPagedListView<T> extends ConsumerStatefulWidget {
  /// Creates a [CraftPagedListView] backed by a paginated provider.
  const CraftPagedListView({
    super.key,
    required this.providerValue,
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

  /// Creates a [CraftPagedListView] with separators between items.
  const CraftPagedListView.separated({
    super.key,
    required this.providerValue,
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
  /// Pass the value from your extension:
  /// `ref.notesProvider(category: 'work')`
  final PagedProviderValue<T> providerValue;

  /// Builds each item in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? _separatorBuilder;

  /// Widget shown when the list has no items.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Widget shown while the first page is loading.
  final Widget Function(BuildContext context)? firstPageLoadingBuilder;

  /// Widget shown when the first page fails to load.
  final Widget Function(BuildContext context, Object? error)?
  firstPageErrorBuilder;

  /// Widget shown while a subsequent page is loading.
  final Widget Function(BuildContext context)? newPageLoadingBuilder;

  /// Widget shown when a subsequent page fails to load.
  final Widget Function(BuildContext context, Object? error)?
  newPageErrorBuilder;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Optional external scroll controller.
  final ScrollController? scrollController;

  /// The axis along which the list scrolls.
  final Axis scrollDirection;

  /// Whether the list scrolls in the reading direction.
  final bool reverse;

  /// Whether this is the primary scroll view.
  final bool? primary;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Whether the list should shrink-wrap its contents.
  final bool shrinkWrap;

  /// The viewport's cache extent in logical pixels.
  final double? cacheExtent;

  /// Determines the way drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;

  @override
  ConsumerState<CraftPagedListView<T>> createState() =>
      _CraftPagedListViewState<T>();
}

class _CraftPagedListViewState<T> extends ConsumerState<CraftPagedListView<T>> {
  @override
  Widget build(BuildContext context) {
    final provider = widget.providerValue.of(ref);
    final state = provider.watch();

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
        state: state.pagingState,
        fetchNextPage: provider.fetchNextPage,
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
      state: state.pagingState,
      fetchNextPage: provider.fetchNextPage,
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
  /// Creates a [CraftPagedSliverListView] backed by a paginated provider.
  const CraftPagedSliverListView({
    super.key,
    required this.providerValue,
    required this.itemBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
  }) : _separatorBuilder = null;

  /// Creates a [CraftPagedSliverListView] with separators between items.
  const CraftPagedSliverListView.separated({
    super.key,
    required this.providerValue,
    required this.itemBuilder,
    required Widget Function(BuildContext context, int index) separatorBuilder,
    this.emptyBuilder,
    this.firstPageLoadingBuilder,
    this.firstPageErrorBuilder,
    this.newPageLoadingBuilder,
    this.newPageErrorBuilder,
  }) : _separatorBuilder = separatorBuilder;

  /// The paginated provider value.
  final PagedProviderValue<T> providerValue;

  /// Builds each item in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? _separatorBuilder;

  /// Widget shown when the list has no items.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Widget shown while the first page is loading.
  final Widget Function(BuildContext context)? firstPageLoadingBuilder;

  /// Widget shown when the first page fails to load.
  final Widget Function(BuildContext context, Object? error)?
  firstPageErrorBuilder;

  /// Widget shown while a subsequent page is loading.
  final Widget Function(BuildContext context)? newPageLoadingBuilder;

  /// Widget shown when a subsequent page fails to load.
  final Widget Function(BuildContext context, Object? error)?
  newPageErrorBuilder;

  @override
  ConsumerState<CraftPagedSliverListView<T>> createState() =>
      _CraftPagedSliverListViewState<T>();
}

class _CraftPagedSliverListViewState<T>
    extends ConsumerState<CraftPagedSliverListView<T>> {
  @override
  Widget build(BuildContext context) {
    final provider = widget.providerValue.of(ref);
    final state = provider.watch();

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
        state: state.pagingState,
        fetchNextPage: provider.fetchNextPage,
        builderDelegate: delegate,
        separatorBuilder: widget._separatorBuilder!,
      );
    }

    return PagedSliverList<int, T>(
      state: state.pagingState,
      fetchNextPage: provider.fetchNextPage,
      builderDelegate: delegate,
    );
  }
}
