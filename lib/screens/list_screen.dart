import 'package:flutter/material.dart';
import 'package:movie_list/models/media_item.dart';
import 'package:movie_list/screens/media_screen.dart';
import 'package:movie_list/services/hive_services.dart';

class ListScreen extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final HiveService hiveService;

  const ListScreen({
    required this.title,
    required this.items,
    required this.hiveService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 100 / 175,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MediaScreen(mediaItem: item, hiveService: hiveService),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.cover != null && item.cover!.isNotEmpty
                            ? Image.network(
                                item.cover!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: const Color(0xFF1E1E1E)),
                              )
                            : Container(color: const Color(0xFF1E1E1E)),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: switch (item.typeOfMedia) {
                              TypeOfMedia.film => const Color(0xFF3C3489),
                              TypeOfMedia.serie => const Color(0xFF085041),
                              TypeOfMedia.anime => const Color(0xFF993C1D),
                            },
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            switch (item.typeOfMedia) {
                              TypeOfMedia.film => 'Film',
                              TypeOfMedia.serie => 'Serie',
                              TypeOfMedia.anime => 'Anime',
                            },
                            style: TextStyle(
                              fontSize: 9,
                              color: switch (item.typeOfMedia) {
                                TypeOfMedia.film => const Color(0xFFCECBF6),
                                TypeOfMedia.serie => const Color(0xFF9FE1CB),
                                TypeOfMedia.anime => const Color(0xFFF5C4B3),
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFCCCCCC),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.releaseDate != null
                      ? item.releaseDate!.year.toString()
                      : '',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
