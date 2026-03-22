import 'package:flutter/material.dart';
import 'package:movie_list/models/media_item.dart';
import 'package:movie_list/screens/media_screen.dart';
import 'package:movie_list/services/hive_services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListScreen extends StatefulWidget {
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
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late List<MediaItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<MediaItem>.from(widget.items)
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  String _buildYearRange(MediaItem item) {
    final start = item.releaseDate?.year;
    final end = item.endYear;
    if (start == null) return '';
    if (item.typeOfMedia == TypeOfMedia.film) return start.toString();
    if (end != null && end != start) return '$start - $end';
    if (end != null && end == start) return start.toString();
    return '$start - ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'Nessun titolo',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 15,
                childAspectRatio: 100 / 175,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onTap: () async {
                    final deleted = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaScreen(
                          mediaItem: item,
                          hiveService: widget.hiveService,
                          allMediaItems: widget.items,
                        ),
                      ),
                    );
                    if (deleted == true) {
                      setState(() {
                        _items.remove(item);
                      });
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  item.cover != null && item.cover!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.cover!,
                                      width: 100,
                                      height: 148,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 100,
                                                height: 148,
                                                color: const Color(0xFF1E1E1E),
                                              ),
                                      placeholder: (context, url) => Container(
                                        width: 100,
                                        height: 148,
                                        color: const Color(0xFF1a1a1a),
                                      ),
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
                                    TypeOfMedia.serie => const Color(
                                      0xFF085041,
                                    ),
                                    TypeOfMedia.anime => const Color(
                                      0xFF993C1D,
                                    ),
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
                                      TypeOfMedia.film => const Color(
                                        0xFFCECBF6,
                                      ),
                                      TypeOfMedia.serie => const Color(
                                        0xFF9FE1CB,
                                      ),
                                      TypeOfMedia.anime => const Color(
                                        0xFFF5C4B3,
                                      ),
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
                        _buildYearRange(item),
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
