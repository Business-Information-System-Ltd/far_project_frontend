// lib/widgets/reusable_pagination.dart
import 'package:flutter/material.dart';

class ReusablePagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final List<int> availablePageSizes;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageSizeChanged;

  const ReusablePagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    this.availablePageSizes = const [5, 10, 25, 50],
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 ? onPrevious : null,
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages ? onNext : null,
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              const Text('Rows per page: '),
              DropdownButton<int>(
                value: pageSize,
                items: availablePageSizes
                    .map(
                      (size) =>
                          DropdownMenuItem(value: size, child: Text('$size')),
                    )
                    .toList(),
                onChanged: (newSize) {
                  if (newSize != null) onPageSizeChanged(newSize);
                },
                underline: const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
