import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

/// A generic dropdown that works with any [DataProviderValue<List<T>>].
///
/// Automatically handles loading, error, and data states via the provider.
class AsyncDropdown<T> extends ConsumerStatefulWidget {
  const AsyncDropdown({
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
  final DataProviderValue<List<T>, Object> providerValue;
  final ValueChanged<T?>? onChanged;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? hint;
  final String? label;
  final double height;
  final Widget Function(T item)? selectedLabelBuilder;

  @override
  ConsumerState<AsyncDropdown<T>> createState() => _AsyncDropdownState<T>();
}

class _AsyncDropdownState<T> extends ConsumerState<AsyncDropdown<T>> {
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
    } else if (state.isError) {
      prefixIcon = IconButton(
        onPressed: () => provider.reload(),
        icon: Icon(Icons.refresh_rounded, size: 22, color: colorScheme.error),
      );
    } else {
      prefixIcon = null;
    }

    final items = state.dataOrNull;

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
              child: _buildMenuContent(
                context,
                provider,
                state,
                items,
                colorScheme,
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

  Widget _buildMenuContent(
    BuildContext context,
    DataProviderFacade<List<T>, Object> provider,
    DataState<List<T>, Object> state,
    List<T>? items,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading && items == null) {
      return Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    if (state.isError && items == null) {
      return Center(
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => provider.reload(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (items == null || items.isEmpty) {
      return Center(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () => provider.reload(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() => _selectedValue = item);
              widget.onChanged?.call(item);
              _menuController.close();
            },
            child: widget.itemBuilder(context, item, index),
          );
        },
      ),
    );
  }
}
