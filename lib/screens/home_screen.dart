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
  TypeOfMedia? _selectedCategory;
  String? _genreOne;
  String? _genreTwo;
  String? _serieGenreOne;
  String? _serieGenreTwo;
  String? _animeGenreOne;
  String? _animeGenreTwo;

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

  // GETTER SCREEN FILM
  List<MediaItem> get _lastFilms => _mediaItems
      .where((item) => item.typeOfMedia == TypeOfMedia.film)
      .toList()
      .reversed
      .take(10)
      .toList();

  List<MediaItem> get _filmsToWatch => _mediaItems
      .where((item) => item.typeOfMedia == TypeOfMedia.film && !item.doIWatched)
      .toList();

  List<MediaItem> get _topRatedFilms {
    final list = _mediaItems
        .where(
          (item) => item.typeOfMedia == TypeOfMedia.film && item.rating >= 8,
        )
        .toList();
    list.shuffle();
    return list.take(10).toList();
  }

  List<MediaItem> get _filmsByGenreOne => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.film &&
            item.genre.contains(_genreOne),
      )
      .toList();

  List<MediaItem> get _filmsByGenreTwo => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.film &&
            item.genre.contains(_genreTwo),
      )
      .toList();
  // END GETTER FILM

  // GETTER SERIES
  List<MediaItem> get _lastSeries => _mediaItems
      .where((item) => item.typeOfMedia == TypeOfMedia.serie)
      .toList()
      .reversed
      .take(10)
      .toList();

  List<MediaItem> get _seriesToWatch => _mediaItems
      .where(
        (item) => item.typeOfMedia == TypeOfMedia.serie && !item.doIWatched,
      )
      .toList();

  List<MediaItem> get _continueWatchingSeries => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.serie &&
            item.episodes != null &&
            item.watchedUntilEpisode != null &&
            item.watchedUntilEpisode! < item.episodes!,
      )
      .toList();

  List<MediaItem> get _topRatedSeries {
    final list = _mediaItems
        .where(
          (item) => item.typeOfMedia == TypeOfMedia.serie && item.rating >= 8,
        )
        .toList();
    list.shuffle();
    return list.take(10).toList();
  }

  List<MediaItem> get _seriesByGenreOne => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.serie &&
            item.genre.contains(_serieGenreOne),
      )
      .toList();

  List<MediaItem> get _seriesByGenreTwo => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.serie &&
            item.genre.contains(_serieGenreTwo),
      )
      .toList();
  // END GETTER SERIES

  // GETTER ANIME
  List<MediaItem> get _lastAnime => _mediaItems
      .where((item) => item.typeOfMedia == TypeOfMedia.anime)
      .toList()
      .reversed
      .take(10)
      .toList();

  List<MediaItem> get _animeToWatch => _mediaItems
      .where(
        (item) => item.typeOfMedia == TypeOfMedia.anime && !item.doIWatched,
      )
      .toList();

  List<MediaItem> get _continueWatchingAnime => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.anime &&
            item.episodes != null &&
            item.watchedUntilEpisode != null &&
            item.watchedUntilEpisode! < item.episodes!,
      )
      .toList();

  List<MediaItem> get _topRatedAnime {
    final list = _mediaItems
        .where(
          (item) => item.typeOfMedia == TypeOfMedia.anime && item.rating >= 8,
        )
        .toList();
    list.shuffle();
    return list.take(10).toList();
  }

  List<MediaItem> get _animeByGenreOne => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.anime &&
            item.genre.contains(_animeGenreOne),
      )
      .toList();

  List<MediaItem> get _animeByGenreTwo => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.anime &&
            item.genre.contains(_animeGenreTwo),
      )
      .toList();
  // END GETTER ANIME

  @override
  void initState() {
    super.initState();
    _loadMediaItems();
  }

  String? _pickGenre(List<String> generi, {String? exclude}) {
    final available = exclude != null
        ? generi.where((g) => g != exclude).toList()
        : generi;
    if (available.isEmpty) return null;
    available.shuffle();
    return available.first;
  }

  Widget _continueWatchingRow(List<MediaItem> items) {
    return Column(
      children: [
        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
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
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'S${item.seasons} · Ep ${item.watchedUntilEpisode} di ${item.episodes}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: item.watchedUntilEpisode! / item.episodes!,
                            backgroundColor: const Color(0xFF333333),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF5DCAA5),
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
        SizedBox(height: 10),
      ],
    );
  }

  Future<void> _loadMediaItems() async {
    final items = await widget.hiveService.getAllMediaItems();
    final toWatch = items.where((item) => !item.doIWatched).toList();
    toWatch.shuffle();

    final generi = items
        .where((item) => item.typeOfMedia == TypeOfMedia.film)
        .expand((item) => item.genre)
        .toSet()
        .toList();

    final generiSerie = items
        .where((item) => item.typeOfMedia == TypeOfMedia.serie)
        .expand((item) => item.genre)
        .toSet()
        .toList();

    final generiAnime = items
        .where((item) => item.typeOfMedia == TypeOfMedia.anime)
        .expand((item) => item.genre)
        .toSet()
        .toList();

    final g1 = _pickGenre(generi);
    final g2 = _pickGenre(generi, exclude: g1);
    final sg1 = _pickGenre(generiSerie);
    final sg2 = _pickGenre(generiSerie, exclude: sg1);
    final ag1 = _pickGenre(generiAnime);
    final ag2 = _pickGenre(generiAnime, exclude: ag1);

    setState(() {
      _mediaItems = items;
      _toWatchList = toWatch.take(10).toList();
      _genreOne = g1;
      _genreTwo = g2;
      _serieGenreOne = sg1;
      _serieGenreTwo = sg2;
      _animeGenreOne = ag1;
      _animeGenreTwo = ag2;
    });
  }

  List<Widget> _buildHomeView() {
    return [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ultimi aggiunti',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                          child: item.cover != null && item.cover!.isNotEmpty
                              ? Image.network(
                                  item.cover!,
                                  width: 100,
                                  height: 148,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 100,
                                        height: 148,
                                        color: const Color(0xFF1E1E1E),
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                'Vedi tutti',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
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
                            value: item.watchedUntilEpisode! / item.episodes!,
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                'Vedi tutti',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
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
                            child: item.cover != null && item.cover!.isNotEmpty
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
                                              color: const Color(0xFF1E1E1E),
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
    ];
  }

  // per categoria
  List<Widget> _buildCategoryView() {
    if (_selectedCategory == TypeOfMedia.film) {
      return [
        if (_lastFilms.isNotEmpty) ...[
          _sectionHeader('Ultimi film aggiunti'),
          _cardRow(_lastFilms),
        ],
        if (_filmsToWatch.isNotEmpty) ...[
          _sectionHeader('Film da guardare'),
          _cardRow(_filmsToWatch),
        ],
        if (_topRatedFilms.isNotEmpty) ...[
          _sectionHeader('Miglior valutazione'),
          _cardRow(_topRatedFilms),
        ],
        if (_genreOne != null && _filmsByGenreOne.isNotEmpty) ...[
          _sectionHeader('Film $_genreOne'),
          _cardRow(_filmsByGenreOne),
        ],
        if (_genreTwo != null && _filmsByGenreTwo.isNotEmpty) ...[
          _sectionHeader('Film $_genreTwo'),
          _cardRow(_filmsByGenreTwo),
        ],
      ];
    }

    if (_selectedCategory == TypeOfMedia.serie) {
      return [
        if (_lastSeries.isNotEmpty) ...[
          _sectionHeader('Ultime serie aggiunte'),
          _cardRow(_lastSeries),
        ],
        if (_continueWatchingSeries.isNotEmpty) ...[
          _sectionHeader('Continua a guardare'),
          _continueWatchingRow(_continueWatchingSeries),
        ],
        if (_seriesToWatch.isNotEmpty) ...[
          _sectionHeader('Serie da guardare'),
          _cardRow(_seriesToWatch),
        ],
        if (_topRatedSeries.isNotEmpty) ...[
          _sectionHeader('Miglior valutazione'),
          _cardRow(_topRatedSeries),
        ],
        if (_serieGenreOne != null && _seriesByGenreOne.isNotEmpty) ...[
          _sectionHeader('Serie $_serieGenreOne'),
          _cardRow(_seriesByGenreOne),
        ],
        if (_serieGenreTwo != null && _seriesByGenreTwo.isNotEmpty) ...[
          _sectionHeader('Serie $_serieGenreTwo'),
          _cardRow(_seriesByGenreTwo),
        ],
      ];
    }

    if (_selectedCategory == TypeOfMedia.anime) {
      return [
        if (_lastAnime.isNotEmpty) ...[
          _sectionHeader('Ultimi anime aggiunti'),
          _cardRow(_lastAnime),
        ],
        if (_continueWatchingAnime.isNotEmpty) ...[
          _sectionHeader('Continua a guardare'),
          _continueWatchingRow(_continueWatchingAnime),
        ],
        if (_animeToWatch.isNotEmpty) ...[
          _sectionHeader('Anime da guardare'),
          _cardRow(_animeToWatch),
        ],
        if (_topRatedAnime.isNotEmpty) ...[
          _sectionHeader('Miglior valutazione'),
          _cardRow(_topRatedAnime),
        ],
        if (_animeGenreOne != null && _animeByGenreOne.isNotEmpty) ...[
          _sectionHeader('Anime $_animeGenreOne'),
          _cardRow(_animeByGenreOne),
        ],
        if (_animeGenreTwo != null && _animeByGenreTwo.isNotEmpty) ...[
          _sectionHeader('Anime $_animeGenreTwo'),
          _cardRow(_animeByGenreTwo),
        ],
      ];
    }

    return [];
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const Text(
            'Vedi tutti',
            style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _cardRow(List<MediaItem> items) {
    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
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
                        child: item.cover != null && item.cover!.isNotEmpty
                            ? Image.network(
                                item.cover!,
                                width: 100,
                                height: 148,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 100,
                                      height: 148,
                                      color: const Color(0xFF1E1E1E),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                // CHIPS
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedCategory = null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _selectedCategory == null
                              ? const Color(0xFF333333)
                              : const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedCategory == null
                                ? const Color(0xFF888888)
                                : const Color(0xFF2a2a2a),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Tutti',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedCategory == null
                                ? Colors.white
                                : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                    ...TypeOfMedia.values.map((type) {
                      final isSelected = _selectedCategory == type;
                      final colors = {
                        TypeOfMedia.film: (
                          const Color(0xFF1e1e3a),
                          const Color(0xFFCECBF6),
                          const Color(0xFF3C3489),
                        ),
                        TypeOfMedia.serie: (
                          const Color(0xFF0a2a22),
                          const Color(0xFF9FE1CB),
                          const Color(0xFF085041),
                        ),
                        TypeOfMedia.anime: (
                          const Color(0xFF2a1208),
                          const Color(0xFFF5C4B3),
                          const Color(0xFF993C1D),
                        ),
                      };
                      final (bg, text, border) = colors[type]!;
                      final label = switch (type) {
                        TypeOfMedia.film => 'Film',
                        TypeOfMedia.serie => 'Serie',
                        TypeOfMedia.anime => 'Anime',
                      };
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? bg : const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? border
                                  : const Color(0xFF2a2a2a),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? text
                                  : const Color(0xFF666666),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              if (_selectedCategory == null)
                ..._buildHomeView()
              else
                ..._buildCategoryView(),

              // ULTIMI AGGIUNTI
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
