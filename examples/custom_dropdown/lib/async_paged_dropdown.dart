import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

/// A generic paged dropdown that works with any [PagedProviderValue<T>].
///
/// Supports infinite scrolling, pull-to-refresh, and loading/error states.
class AsyncPagedDropdown<T> extends ConsumerStatefulWidget {
  const AsyncPagedDropdown({
    super.key,
    required this.providerValue,
    required this.itemBuilder,
    this.onChanged,
    this.hint,
    this.label,
    this.height = 300,
    this.selectedLabelBuilder,
  });

  // providerValue is an accessor for the provider, not the actual provider.
  final PagedProviderValue<T> providerValue;
  final ValueChanged<T?>? onChanged;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? hint;
  final String? label;
  final double height;
  final Widget Function(T item)? selectedLabelBuilder;

  @override
  ConsumerState<AsyncPagedDropdown<T>> createState() =>
      _AsyncPagedDropdownState<T>();
}

class _AsyncPagedDropdownState<T> extends ConsumerState<AsyncPagedDropdown<T>> {
  final MenuController _menuController = MenuController();
  T? _selectedValue;

  void _toggle() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use .of(ref) to access the actual provider in this widget.
    final provider = widget.providerValue.of(ref);
    final state = provider.watch();
    final colorScheme = Theme.of(context).colorScheme;

    final Widget? prefixIcon;
    if (state.isLoading) {
      prefixIcon = Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      );
    } else if (state.hasError && state.items == null) {
      prefixIcon = IconButton(
        onPressed: () => provider.invalidate(),
        icon: Icon(Icons.refresh_rounded, size: 22, color: colorScheme.error),
      );
    } else {
      prefixIcon = null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.maxWidth;
        return MenuAnchor(
          controller: _menuController,
          style: MenuStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outline),
              ),
            ),
            backgroundColor: WidgetStatePropertyAll(
              colorScheme.surfaceContainerLowest,
            ),
            elevation: const WidgetStatePropertyAll(4),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0)),
            maximumSize: WidgetStatePropertyAll(Size(menuWidth, widget.height)),
          ),
          menuChildren: [
            SizedBox(
              width: menuWidth,
              height: widget.height,
              child: RefreshIndicator(
                color: colorScheme.primary,
                onRefresh: () async => provider.invalidate(),
                child: CraftPagedListView<T>(
                  provider: widget.providerValue,
                  itemBuilder: (context, item, index) => InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() => _selectedValue = item);
                      widget.onChanged?.call(item);
                      _menuController.close();
                    },
                    child: widget.itemBuilder(context, item, index),
                  ),
                  firstPageLoadingBuilder: (context) => Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  firstPageErrorBuilder: (context, error) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 32,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load items',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.error),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () => provider.invalidate(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  emptyBuilder: (context) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 32,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No items found',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  newPageLoadingBuilder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          builder: (context, controller, child) {
            return GestureDetector(
              onTap: _toggle,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: prefixIcon,
                  suffixIcon: AnimatedRotation(
                    turns: _menuController.isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                child:
                    _selectedValue != null &&
                        widget.selectedLabelBuilder != null
                    ? widget.selectedLabelBuilder!(_selectedValue as T)
                    : (widget.hint ??
                          Text(
                            'Select',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          )),
              ),
            );
          },
        );
      },
    );
  }
}
