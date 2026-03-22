import 'package:flutter/material.dart';
import 'package:movie_list/screens/form_screen.dart';
import 'package:movie_list/screens/list_screen.dart';
import 'package:movie_list/screens/media_screen.dart';
import 'package:movie_list/services/csv_service.dart';
import 'package:movie_list/services/hive_services.dart';
import 'package:movie_list/models/media_item.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  final HiveService hiveService;

  const HomeScreen({required this.hiveService, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CsvService _csvService = CsvService();

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _filterGenre;
  String? _filterStar;
  String? _filterDirector;

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

  List<MediaItem> get _continueWatching =>
      _mediaItems
          .where(
            (item) =>
                item.typeOfMedia != TypeOfMedia.film &&
                item.episodes != null &&
                item.watchedUntilEpisode != null &&
                item.watchedUntilEpisode! < item.episodes!,
          )
          .toList()
        ..sort((a, b) {
          final aDate = a.lastModified ?? DateTime(0);
          final bDate = b.lastModified ?? DateTime(0);
          return bDate.compareTo(aDate);
        });

  //Coming Soon lists
  List<MediaItem> get _comingSoon => _mediaItems
      .where(
        (item) =>
            item.releaseDate != null &&
            item.releaseDate!.isAfter(DateTime.now()),
      )
      .toList();

  List<MediaItem> get _comingSoonFilms => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.film &&
            item.releaseDate != null &&
            item.releaseDate!.isAfter(DateTime.now()),
      )
      .toList();

  List<MediaItem> get _comingSoonSeries => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.serie &&
            item.releaseDate != null &&
            item.releaseDate!.isAfter(DateTime.now()),
      )
      .toList();

  List<MediaItem> get _comingSoonAnime => _mediaItems
      .where(
        (item) =>
            item.typeOfMedia == TypeOfMedia.anime &&
            item.releaseDate != null &&
            item.releaseDate!.isAfter(DateTime.now()),
      )
      .toList();
  // END COMING SOON LISTS

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

  List<MediaItem> get _continueWatchingSeries =>
      _mediaItems
          .where(
            (item) =>
                item.typeOfMedia == TypeOfMedia.serie &&
                item.episodes != null &&
                item.watchedUntilEpisode != null &&
                item.watchedUntilEpisode! < item.episodes!,
          )
          .toList()
        ..sort((a, b) {
          final aDate = a.lastModified ?? DateTime(0);
          final bDate = b.lastModified ?? DateTime(0);
          return bDate.compareTo(aDate);
        });

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

  List<MediaItem> get _continueWatchingAnime =>
      _mediaItems
          .where(
            (item) =>
                item.typeOfMedia == TypeOfMedia.anime &&
                item.episodes != null &&
                item.watchedUntilEpisode != null &&
                item.watchedUntilEpisode! < item.episodes!,
          )
          .toList()
        ..sort((a, b) {
          final aDate = a.lastModified ?? DateTime(0);
          final bDate = b.lastModified ?? DateTime(0);
          return bDate.compareTo(aDate);
        });

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

  // GETTER SEARCH
  List<MediaItem> get _searchResults => _mediaItems.where((item) {
    final query = _searchQuery.toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        item.title.toLowerCase().contains(query) ||
        item.originalTitle.toLowerCase().contains(query) ||
        (item.director?.toLowerCase().contains(query) ?? false) ||
        item.genre.any((g) => g.toLowerCase().contains(query)) ||
        (item.star?.any((s) => s.toLowerCase().contains(query)) ?? false);

    final matchesGenre =
        _filterGenre == null || item.genre.contains(_filterGenre);
    final matchesStar =
        _filterStar == null || (item.star?.contains(_filterStar) ?? false);
    final matchesDirector =
        _filterDirector == null || item.director == _filterDirector;

    return matchesQuery && matchesGenre && matchesStar && matchesDirector;
  }).toList();
  // END GETTER SEARCH

  @override
  void dispose() {
    _searchController.dispose();
  }

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

  String _buildYearRange(MediaItem item) {
    final start = item.releaseDate?.year;
    final end = item.endYear;
    if (start == null) return '';
    if (item.typeOfMedia == TypeOfMedia.film) return start.toString();
    if (end != null && end != start) return '$start - $end';
    if (end != null && end == start) return start.toString();
    return '$start - ';
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ultimi aggiunti',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                              ? CachedNetworkImage(
                                  imageUrl: item.cover!,
                                  width: 100,
                                  height: 148,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, error, stackTrace) =>
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
                      _buildYearRange(item),
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
        _sectionHeader('Continua a guardare', _continueWatching),
      if (_continueWatching.isNotEmpty) _continueWatchingRow(_continueWatching),
      // DA GUARDARE
      if (_toWatchList.isNotEmpty) _sectionHeader('Da guardare', _toWatchList),
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
                                ? CachedNetworkImage(
                                    imageUrl: item.cover!,
                                    width: 100,
                                    height: 148,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, error, stackTrace) =>
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
                        _buildYearRange(item),
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
      if (_comingSoon.isNotEmpty) _sectionHeader('In arrivo', _comingSoon),
      if (_comingSoon.isNotEmpty) _cardRow(_comingSoon),
    ];
  }

  // per categoria
  List<Widget> _buildCategoryView() {
    if (_selectedCategory == TypeOfMedia.film) {
      return [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListScreen(
                title: 'Tutti i film',
                items: _mediaItems
                    .where((item) => item.typeOfMedia == TypeOfMedia.film)
                    .toList(),
                hiveService: widget.hiveService,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e3a),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3C3489), width: 1),
            ),
            child: Center(
              child: Text(
                'Vedi tutti i film (${_mediaItems.where((item) => item.typeOfMedia == TypeOfMedia.film).length})',
                style: const TextStyle(fontSize: 13, color: Color(0xFFCECBF6)),
              ),
            ),
          ),
        ),
        if (_lastFilms.isNotEmpty) ...[
          _sectionHeader(
            'Ultimi film aggiunti',
            _lastFilms,
            showViewAll: false,
          ),
          _cardRow(_lastFilms),
        ],
        if (_filmsToWatch.isNotEmpty) ...[
          _sectionHeader('Film da guardare', _filmsToWatch),
          _cardRow(_filmsToWatch),
        ],
        if (_topRatedFilms.isNotEmpty) ...[
          _sectionHeader('Miglior valutazione', _topRatedFilms),
          _cardRow(_topRatedFilms),
        ],
        if (_genreOne != null && _filmsByGenreOne.isNotEmpty) ...[
          _sectionHeader('Film $_genreOne', _filmsByGenreOne),
          _cardRow(_filmsByGenreOne),
        ],
        if (_genreTwo != null && _filmsByGenreTwo.isNotEmpty) ...[
          _sectionHeader('Film $_genreTwo', _filmsByGenreTwo),
          _cardRow(_filmsByGenreTwo),
        ],
        if (_comingSoonFilms.isNotEmpty) ...[
          _sectionHeader('Film in arrivo', _comingSoonFilms),
          _cardRow(_comingSoonFilms),
        ],
      ];
    }

    if (_selectedCategory == TypeOfMedia.serie) {
      return [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListScreen(
                title: 'Tutte le serie',
                items: _mediaItems
                    .where((item) => item.typeOfMedia == TypeOfMedia.serie)
                    .toList(),
                hiveService: widget.hiveService,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0a2a22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF085041), width: 1),
            ),
            child: Center(
              child: Text(
                'Vedi tutte le serie (${_mediaItems.where((item) => item.typeOfMedia == TypeOfMedia.serie).length})',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9FE1CB)),
              ),
            ),
          ),
        ),
        if (_lastSeries.isNotEmpty) ...[
          _sectionHeader(
            'Ultime serie aggiunte',
            _lastSeries,
            showViewAll: false,
          ),
          _cardRow(_lastSeries),
        ],
        if (_continueWatchingSeries.isNotEmpty) ...[
          _sectionHeader('Continua a guardare', _continueWatchingSeries),
          _continueWatchingRow(_continueWatchingSeries),
        ],
        if (_seriesToWatch.isNotEmpty) ...[
          _sectionHeader('Serie da guardare', _seriesToWatch),
          _cardRow(_seriesToWatch),
        ],
        if (_topRatedSeries.isNotEmpty) ...[
          _sectionHeader('Miglior valutazione', _topRatedSeries),
          _cardRow(_topRatedSeries),
        ],
        if (_serieGenreOne != null && _seriesByGenreOne.isNotEmpty) ...[
          _sectionHeader('Serie $_serieGenreOne', _seriesByGenreOne),
          _cardRow(_seriesByGenreOne),
        ],
        if (_serieGenreTwo != null && _seriesByGenreTwo.isNotEmpty) ...[
          _sectionHeader('Serie $_serieGenreTwo', _seriesByGenreTwo),
          _cardRow(_seriesByGenreTwo),
        ],
        if (_comingSoonSeries.isNotEmpty) ...[
          _sectionHeader('Serie in arrivo', _comingSoonSeries),
          _cardRow(_comingSoonSeries),
        ],
      ];
    }

    if (_selectedCategory == TypeOfMedia.anime) {
      return [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListScreen(
                title: 'Tutti gli Anime',
                items: _mediaItems
                    .where((item) => item.typeOfMedia == TypeOfMedia.anime)
                    .toList(),
                hiveService: widget.hiveService,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2a1208),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF993C1D), width: 1),
            ),
            child: Center(
              child: Text(
                'Vedi tutti gli anime (${_mediaItems.where((item) => item.typeOfMedia == TypeOfMedia.anime).length})',
                style: const TextStyle(fontSize: 13, color: Color(0xFFF5C4B3)),
              ),
            ),
          ),
        ),
        if (_lastAnime.isNotEmpty) ...[
          _sectionHeader(
            'Ultimi anime aggiunti',
            _lastAnime,
            showViewAll: false,
          ),
          _cardRow(_lastAnime),
        ],
        if (_continueWatchingAnime.isNotEmpty) ...[
          _sectionHeader('Continua a guardare', _continueWatchingAnime),
          _continueWatchingRow(_continueWatchingAnime),
        ],
        if (_animeToWatch.isNotEmpty) ...[
          _sectionHeader('Anime da guardare', _animeToWatch),
          _cardRow(_animeToWatch),
        ],
        if (_topRatedAnime.isNotEmpty) ...[
          _sectionHeader('Miglior valutazione', _topRatedAnime),
          _cardRow(_topRatedAnime),
        ],
        if (_animeGenreOne != null && _animeByGenreOne.isNotEmpty) ...[
          _sectionHeader('Anime $_animeGenreOne', _animeByGenreOne),
          _cardRow(_animeByGenreOne),
        ],
        if (_animeGenreTwo != null && _animeByGenreTwo.isNotEmpty) ...[
          _sectionHeader('Anime $_animeGenreTwo', _animeByGenreTwo),
          _cardRow(_animeByGenreTwo),
        ],
        if (_comingSoonAnime.isNotEmpty) ...[
          _sectionHeader('Anime in arrivo', _comingSoonAnime),
          _cardRow(_comingSoonAnime),
        ],
      ];
    }

    return [];
  }

  List<Widget> _buildSearchView() {
    // raccolgo tutti i generi, star e registi unici
    final allGenres =
        _mediaItems.expand((item) => item.genre).toSet().toList().cast<String>()
          ..sort();
    final allStars =
        _mediaItems
            .expand((item) => item.star ?? [])
            .toSet()
            .toList()
            .cast<String>()
          ..sort();
    final allDirectors =
        _mediaItems
            .map((item) => item.director)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    return [
      // FILTRI
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // filtro genere
              _filterChip(
                'Genere',
                _filterGenre,
                allGenres,
                (val) => setState(() => _filterGenre = val),
              ),
              const SizedBox(width: 8),
              // filtro star
              _filterChip(
                'Attore',
                _filterStar,
                allStars,
                (val) => setState(() => _filterStar = val),
              ),
              const SizedBox(width: 8),
              // filtro regista
              _filterChip(
                'Regista',
                _filterDirector,
                allDirectors,
                (val) => setState(() => _filterDirector = val),
              ),
            ],
          ),
        ),
      ),

      // RISULTATI
      if (_searchResults.isEmpty)
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Nessun risultato',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
        )
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 100 / 175,
          ),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final item = _searchResults[index];
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.cover != null && item.cover!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.cover!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(color: const Color(0xFF1E1E1E)),
                                  placeholder: (context, url) =>
                                      Container(color: const Color(0xFF1a1a1a)),
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
    ];
  }

  Widget _filterChip(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: const Color(0xFF1a1a1a),
          builder: (context) => ListView(
            children: [
              ListTile(
                title: const Text(
                  'Tutti',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, null),
              ),
              ...options.map(
                (option) => ListTile(
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: selectedValue == option
                      ? const Icon(Icons.check, color: Color(0xFF3C3489))
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
              ),
            ],
          ),
        );
        if (selected != null || selectedValue != null) {
          onSelected(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selectedValue != null
              ? const Color(0xFF1e1e3a)
              : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedValue != null
                ? const Color(0xFF3C3489)
                : const Color(0xFF2a2a2a),
            width: 1,
          ),
        ),
        child: Text(
          selectedValue ?? label,
          style: TextStyle(
            fontSize: 12,
            color: selectedValue != null
                ? const Color(0xFFCECBF6)
                : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    List<MediaItem> items, {
    bool showViewAll = true,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListScreen(
                    title: title,
                    items: items,
                    hiveService: widget.hiveService,
                  ),
                ),
              ),
              child: const Text(
                'Vedi tutti',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
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
                            ? CachedNetworkImage(
                                imageUrl: item.cover!,
                                width: 100,
                                height: 148,
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) =>
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
                    _buildYearRange(item),
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
      appBar: AppBar(title: Text("Watch List")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARRA DI RICERCA
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: GestureDetector(
                  onTap: () => setState(() => _isSearching = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a1a),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isSearching
                            ? const Color(0xFF3C3489)
                            : const Color(0xFF2a2a2a),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF666666),
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Cerca per titolo, regista, genere...',
                              hintStyle: TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            onTap: () => setState(() => _isSearching = true),
                          ),
                        ),
                        if (_isSearching)
                          GestureDetector(
                            onTap: () => setState(() {
                              _isSearching = false;
                              _searchQuery = '';
                              _searchController.clear();
                              _filterGenre = null;
                              _filterStar = null;
                              _filterDirector = null;
                            }),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.close,
                                color: Color(0xFF666666),
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!_isSearching)
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
              if (_isSearching)
                ..._buildSearchView()
              else if (_selectedCategory == null)
                ..._buildHomeView()
              else
                ..._buildCategoryView(),
              // ULTIMI AGGIUNTI
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFF3C3489),
        foregroundColor: const Color(0xFFCECBF6),
        activeBackgroundColor: const Color(0xFF1e1e3a),
        elevation: 0,
        spacing: 12,
        spaceBetweenChildren: 8,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add, color: Color(0xFFCECBF6)),
            label: 'Aggiungi manualmente',
            backgroundColor: const Color(0xFF3C3489),
            elevation: 0,
            labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
            labelBackgroundColor: const Color(0xFF2a2a2a),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FormScreen(hiveService: widget.hiveService),
                ),
              );
              _loadMediaItems();
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_upload, color: Color(0xFFCECBF6)),
            label: 'Importa CSV',
            backgroundColor: const Color(0xFF3C3489),
            elevation: 0,
            labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
            labelBackgroundColor: const Color(0xFF2a2a2a),
            onTap: () async {
              final items = await _csvService.importCsv();
              for (final item in items) {
                await widget.hiveService.addMediaItem(item);
              }
              _loadMediaItems();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${items.length} titoli importati!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
