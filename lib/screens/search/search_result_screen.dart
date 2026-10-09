import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';

import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/l10n/clothing_localizations.dart';

class SearchResultScreen extends StatelessWidget {
  const SearchResultScreen({
    super.key,
    required this.nameQuery,
    required this.category,
    required this.color,
    required this.style,
    required this.favoritesOnly,
  });

  final String nameQuery;
  final ItemCategory? category;
  final ItemColor? color;
  final ItemStyle? style;
  final bool favoritesOnly;

  List<ClothingItem> _filter(List<ClothingItem> items) {
    final query = nameQuery.toLowerCase();

    return items.where((item) {
      // Name
      if (query.isNotEmpty &&
          !item.name.toLowerCase().contains(query)) {
        return false;
      }

      // Category
      if (category != null &&
          item.category != category) {
        return false;
      }

      // Color
      if (color != null &&
          item.color != color) {
        return false;
      }

      // Style
      if (style != null &&
          item.style != style) {
        return false;
      }

      // Favorite
      if (favoritesOnly && !item.isFavorite) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                0,
              ),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.outlineVariant,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),

                    Text(
                      l10n.searchResult,
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ValueListenableBuilder<List<ClothingItem>>(
                valueListenable:
                    ClosetRepository.instance.items,
                builder: (context, items, _) {
                  final results = _filter(items);

                  if (results.isEmpty) {
                    return const _EmptyResult();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          12,
                        ),
                        child: Text(
                          '${results.length} '
                          '${results.length == 1 ? l10n.item : l10n.items}'
                          '${l10n.found}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),

                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            24,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            mainAxisExtent: 220,
                          ),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final item = results[index];

                            return _ResultItemCard(
                              item: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PreviewItemScreen(
                                      item: item,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultItemCard extends StatelessWidget {
  const _ResultItemCard({
    required this.item,
    required this.onTap,
  });

  final ClothingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      key: Key('search_item_${item.id}'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: cs.surfaceContainerHigh,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.contain,
                      cacheWidth: 400,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.broken_image_outlined,
                          color: cs.onSurfaceVariant,
                          size: 40,
                        );
                      },
                    ),
                  ),

                  if (item.isFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.surface.withValues(
                            alpha: 0.9,
                          ),
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 16,
                          color: cs.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            '${item.category.localizedLabel(l10n)} • ${item.color.localizedLabel(l10n)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_very_dissatisfied,
              size: 64,
              color: cs.primary,
            ),

            const SizedBox(height: 14),

            Text(
              l10n.noClothesFound,
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              l10n.noClothesFoundHint,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}