import 'package:flutter/material.dart';
import 'book_card.dart';

class BooksGrid extends StatelessWidget {
  final List<Map<String, String>> books;

  const BooksGrid({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          title: book['titulo']!,
          author: book['autor']!,
          area: book['area']!,
        );
      },
    );
  }
}