import 'package:flutter/material.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';

import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _nameController = TextEditingController();

  ItemCategory? _category;
  ItemColor? _color;
  ItemStyle? _style;
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    await ClosetRepository.instance.load();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultScreen(
          nameQuery: _nameController.text.trim(),
          category: _category,
          color: _color,
          style: _style,
          favoritesOnly: _favoritesOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 30, 32, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Search',
                  style: tt.titleLarge?.copyWith(
                    fontSize: 24,
                    color: cs.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // NAME
              const _FieldLabel('NAME'),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: cs.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: cs.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // CATEGORY
              const _FieldLabel('CATEGORY'),
              _FilterDropdown<ItemCategory>(
                value: _category,
                emptyLabel: 'All Categories',
                values: ItemCategory.values,
                labelOf: (item) => item.label,
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // COLOR
              const _FieldLabel('COLOR'),
              _FilterDropdown<ItemColor>(
                value: _color,
                emptyLabel: 'Any Color',
                values: ItemColor.values,
                labelOf: (item) => item.label,
                onChanged: (value) {
                  setState(() {
                    _color = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // STYLE
              const _FieldLabel('FORMAL/CASUAL'),
              _FilterDropdown<ItemStyle>(
                value: _style,
                emptyLabel: 'All Styles',
                values: ItemStyle.values,
                labelOf: (item) => item.label,
                onChanged: (value) {
                  setState(() {
                    _style = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              // FAVORITE
              Row(
                children: [
                  Checkbox(
                    value: _favoritesOnly,
                    activeColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _favoritesOnly = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _favoritesOnly = !_favoritesOnly;
                      });
                    },
                    child: Text(
                      'Favorites Only',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // SEARCH BUTTON
              Center(
                child: Material(
                  color: cs.primary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    key: const Key('search_button'),
                    customBorder: const CircleBorder(),
                    onTap: _search,
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: Icon(
                        Icons.search,
                        color: cs.onPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        text,
        style: tt.bodySmall?.copyWith(
          fontSize: 11,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.emptyLabel,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final T? value;
  final String emptyLabel;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: cs.onSurfaceVariant,
          ),
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface,
          ),
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(emptyLabel),
            ),
            ...values.map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(labelOf(item)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}