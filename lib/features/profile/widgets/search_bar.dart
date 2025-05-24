// lib/features/profile/widgets/friend_search_bar.dart
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final ColorScheme colorScheme;
  final VoidCallback? onBackPressed;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.colorScheme,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(50),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button (always visible)
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.primary,
                size: 22,
              ),
              onPressed: onBackPressed,
              padding: EdgeInsets.zero,
            ),

            // Middle content
            Expanded(
              child:
                  isSearching
                      ? TextField(
                        controller: controller,
                        autofocus: true,
                        onChanged: onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: 15,
                        ),
                      )
                      : Center(
                        child: Text(
                          'Friends',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
            ),

            // Search/Close button (always visible)
            IconButton(
              icon: Icon(
                isSearching ? Icons.close : Icons.search_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
              onPressed: onToggleSearch,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
