import 'package:flutter/material.dart';

import 'app_page_header.dart';
import 'app_placeholder_state.dart';

/// Standard list page placeholder: header (title + optional New), controls bar, grid area.
/// Docs: 11_List_Page_Pattern_v1.md (A. Page Header, B. Controls Bar, C. Data Grid)
class AppListPagePlaceholder extends StatelessWidget {
  const AppListPagePlaceholder({
    super.key,
    required this.title,
    this.showNewButton = false,
    this.onNewPressed,
    this.placeholderMessage = 'No data',
  });

  final String title;
  final bool showNewButton;
  final VoidCallback? onNewPressed;
  final String placeholderMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPageHeader(
          title: title,
          actions: showNewButton
              ? [
                  FilledButton.icon(
                    onPressed: onNewPressed,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                  ),
                ]
              : null,
        ),
        const Divider(height: 1),
        // Controls bar placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 240,
                height: 32,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    isDense: true,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () {}, child: const Text('Filter')),
            ],
          ),
        ),
        const Divider(height: 1),
        // Grid area
        Expanded(child: AppPlaceholderState(message: placeholderMessage)),
      ],
    );
  }
}
