import 'package:flutter/material.dart';
import 'book_card.dart';

class BooksGrid extends StatelessWidget {
  final List<Map<String, String>> books;
  final void Function(String id, String title)? onRequest;

  const BooksGrid({super.key, required this.books, this.onRequest});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        // calculate columns dynamically based on card width approx 300
        int crossAxisCount = (available / 320).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;
        if (crossAxisCount > 4) crossAxisCount = 4;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return BookCard(
              id: book['id_libro'] ?? '',
              title: book['titulo']!,
              author: book['autor']!,
              area: book['area']!,
              onRequest: onRequest,
            );
          },
        );
      },
    );
  }
}
