import 'package:flutter/material.dart';
import 'package:movie_list/screens/form_screen.dart';
import 'package:movie_list/screens/media_screen.dart';
import 'package:movie_list/services/hive_services.dart';
import 'package:movie_list/models/media_item.dart';

class HomeScreen extends StatefulWidget {
  final HiveService hiveService;

  const HomeScreen({required this.hiveService, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MediaItem> _toWatchList = [];

  List<MediaItem> _mediaItems = [];

  List<MediaItem> get _lastAdded => _mediaItems.reversed.take(10).toList();

  List<MediaItem> get _continueWatching => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia != TypeOfMedia.film &&
            item.episodes != null &&
            item.watchedUntilEpisode != null &&
            item.watchedUntilEpisode! < item.episodes!,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _loadMediaItems();
  }

  Future<void> _loadMediaItems() async {
    final items = await widget.hiveService.getAllMediaItems();
    final toWatch = items.where((item) => !item.doIWatched).toList();
    toWatch.shuffle();
    setState(() {
      _mediaItems = items;
      _toWatchList = toWatch.take(10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ULTIMI AGGIUNTI
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ultimi aggiunti',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Vedi tutti',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 195,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _lastAdded.length,
                  itemBuilder: (context, index) {
                    final item = _lastAdded[index]; // o _toWatch[index]
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaScreen(
                              mediaItem: item,
                              hiveService: widget.hiveService,
                            ),
                          ),
                        );
                        _loadMediaItems();
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      item.cover != null &&
                                          item.cover!.isNotEmpty
                                      ? Image.network(
                                          item.cover!,
                                          width: 100,
                                          height: 148,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 100,
                                                    height: 148,
                                                    color: const Color(
                                                      0xFF1E1E1E,
                                                    ),
                                                  ),
                                        )
                                      : Container(
                                          width: 100,
                                          height: 148,
                                          color: const Color(0xFF1E1E1E),
                                        ),
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
                                        TypeOfMedia.film => const Color(
                                          0xFF3C3489,
                                        ),
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
                            const SizedBox(height: 5),
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
                      ),
                    );
                  },
                ),
              ),
              // CONTINUA A GUARDARE
              if (_continueWatching.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Continua a guardare',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Vedi tutti',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_continueWatching.isNotEmpty)
                SizedBox(
                  height: 65,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _continueWatching.length,
                    itemBuilder: (context, index) {
                      final item = _continueWatching[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MediaScreen(
                                mediaItem: item,
                                hiveService: widget.hiveService,
                              ),
                            ),
                          );
                          _loadMediaItems();
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'S${item.seasons} · Ep ${item.watchedUntilEpisode} di ${item.episodes}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const Spacer(),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value:
                                        item.watchedUntilEpisode! /
                                        item.episodes!,
                                    backgroundColor: const Color(0xFF333333),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFF5DCAA5),
                                    ),
                                    minHeight: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_toWatchList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Da guardare',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Vedi tutti',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              // DA GUARDARE
              if (_toWatchList.isNotEmpty)
                SizedBox(
                  height: 195,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _toWatchList.length,
                    itemBuilder: (context, index) {
                      final item = _toWatchList[index]; // o _toWatch[index]
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MediaScreen(
                                mediaItem: item,
                                hiveService: widget.hiveService,
                              ),
                            ),
                          );
                          _loadMediaItems();
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        item.cover != null &&
                                            item.cover!.isNotEmpty
                                        ? Image.network(
                                            item.cover!,
                                            width: 100,
                                            height: 148,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      width: 100,
                                                      height: 148,
                                                      color: const Color(
                                                        0xFF1E1E1E,
                                                      ),
                                                    ),
                                          )
                                        : Container(
                                            width: 100,
                                            height: 148,
                                            color: const Color(0xFF1E1E1E),
                                          ),
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
                                          TypeOfMedia.film => const Color(
                                            0xFF3C3489,
                                          ),
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
                              const SizedBox(height: 5),
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
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormScreen(hiveService: widget.hiveService),
            ),
          );
          _loadMediaItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
