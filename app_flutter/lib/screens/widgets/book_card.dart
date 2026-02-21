import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String area;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔥 PORTADA 3D
          Container(
            height: 160,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFF5F1ED),
            child: Row(
              children: [

                // LOMO
                Container(
                  width: 12,
                  color: const Color(0xFF6B5B45),
                ),

                // PORTADA
                Expanded(
                  child: Container(
                    color: const Color(0xFF8B7355),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // PAGINAS
                Container(
                  width: 8,
                  color: const Color(0xFFE5DDD5),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  author,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF8B8B8B),
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: const Color(0xFF8B7355)),
                  ),
                  child: Text(
                    area,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  height: 28,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF8B7355),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Solicitar",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}