import 'package:flutter/material.dart';
import 'package:riverpod_craft/riverpod_craft.dart';

/// A generic dropdown that works with any [ProviderValue<List<T>>].
///
/// For synchronous providers — no loading or error states needed.
class SyncDropdown<T> extends ConsumerStatefulWidget {
  const SyncDropdown({
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
  final ProviderValue<List<T>> providerValue;
  final ValueChanged<T?>? onChanged;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? hint;
  final String? label;
  final double height;
  final Widget Function(T item)? selectedLabelBuilder;

  @override
  ConsumerState<SyncDropdown<T>> createState() => _SyncDropdownState<T>();
}

class _SyncDropdownState<T> extends ConsumerState<SyncDropdown<T>> {
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
    final items = provider.watch();
    final colorScheme = Theme.of(context).colorScheme;

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
              child: _buildMenuContent(context, items, colorScheme),
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
    List<T> items,
    ColorScheme colorScheme,
  ) {
    if (items.isEmpty) {
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

    return ListView.builder(
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
    );
  }
}
