import 'package:flutter/material.dart';
import 'package:movie_list/models/media_item.dart';
import 'package:movie_list/services/hive_services.dart';
import 'package:intl/intl.dart';

class FormScreen extends StatefulWidget {
  final MediaItem? mediaItem;
  final HiveService hiveService;

  const FormScreen({this.mediaItem, required this.hiveService, super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.mediaItem != null) {
      _titleController.text = widget.mediaItem!.title;
      _originaltitleController.text = widget.mediaItem!.originalTitle;
      _directorController.text = widget.mediaItem!.director ?? '';
      _plotController.text = widget.mediaItem!.plot ?? '';
      _coverController.text = widget.mediaItem!.cover ?? '';
      _commentController.text = widget.mediaItem!.comment ?? '';
      _trailerController.text = widget.mediaItem!.trailer ?? '';
      _durationController.text = widget.mediaItem!.duration?.toString() ?? '';
      _seasonsController.text = widget.mediaItem!.seasons?.toString() ?? '';
      _episodesController.text = widget.mediaItem!.episodes?.toString() ?? '';
      _watchedUntilEpisodeController.text =
          widget.mediaItem!.watchedUntilEpisode?.toString() ?? '';
      _releaseDateController.text = widget.mediaItem!.releaseDate != null
          ? DateFormat('dd/MM/yyyy').format(widget.mediaItem!.releaseDate!)
          : '';
      _whenIWatchedController.text = widget.mediaItem!.whenIWatched != null
          ? DateFormat('dd/MM/yyyy').format(widget.mediaItem!.whenIWatched!)
          : '';
      _stars = widget.mediaItem!.star ?? [];
      _genres = widget.mediaItem!.genre ?? [];
      _rating = widget.mediaItem!.rating;
      _doIWatched = widget.mediaItem!.doIWatched;
      _selectedType = widget.mediaItem!.typeOfMedia;
    }
  }

  TypeOfMedia _selectedType = TypeOfMedia.film;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _originaltitleController =
      TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _trailerController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _seasonsController = TextEditingController();
  final TextEditingController _episodesController = TextEditingController();
  final TextEditingController _watchedUntilEpisodeController =
      TextEditingController();

  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _whenIWatchedController = TextEditingController();

  final TextEditingController _starsController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();

  double? _rating;
  List<String> _stars = [];
  List<String> _genres = [];
  bool _doIWatched = false;

  @override
  void dispose() {
    _titleController.dispose();
    _originaltitleController.dispose();
    _directorController.dispose();
    _plotController.dispose();
    _coverController.dispose();
    _trailerController.dispose();
    _commentController.dispose();
    _durationController.dispose();
    _seasonsController.dispose();
    _episodesController.dispose();
    _watchedUntilEpisodeController.dispose();
    _releaseDateController.dispose();
    _whenIWatchedController.dispose();
    _starsController.dispose();
    _genresController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mediaItem != null ? 'Modifica Titolo' : 'Aggiungi Titolo',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: TypeOfMedia.values.map((type) {
                      final isSelected = _selectedType == type;
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
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = type),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? bg : const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? border
                                    : const Color(0xFF2a2a2a),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? text
                                    : const Color(0xFF666666),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Titolo'),
                  ),
                  TextFormField(
                    controller: _originaltitleController,
                    decoration: InputDecoration(labelText: 'Titolo Originale'),
                  ),
                  TextFormField(
                    controller: _directorController,
                    decoration: InputDecoration(labelText: 'Regista'),
                  ),
                  TextFormField(
                    controller: _plotController,
                    decoration: InputDecoration(labelText: 'Trama'),
                  ),
                  TextFormField(
                    controller: _coverController,
                    decoration: InputDecoration(labelText: 'Copertina'),
                  ),
                  TextFormField(
                    controller: _trailerController,
                    decoration: InputDecoration(labelText: 'Trailer'),
                  ),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Commento Personale',
                    ),
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(labelText: 'Durata'),
                    keyboardType: TextInputType.number,
                  ),
                  if (_selectedType != TypeOfMedia.film)
                    TextFormField(
                      controller: _seasonsController,
                      decoration: InputDecoration(labelText: 'Stagioni'),
                      keyboardType: TextInputType.number,
                    ),
                  if (_selectedType != TypeOfMedia.film)
                    TextFormField(
                      controller: _episodesController,
                      decoration: InputDecoration(labelText: 'Episodi'),
                      keyboardType: TextInputType.number,
                    ),
                  if (_selectedType != TypeOfMedia.film)
                    TextFormField(
                      controller: _watchedUntilEpisodeController,
                      decoration: InputDecoration(
                        labelText: 'Numero ultimo episodio guardato',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  TextFormField(
                    controller: _releaseDateController,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                      );
                      if (picked != null) {
                        setState(
                          () => _releaseDateController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked),
                        );
                      }
                    },
                    decoration: InputDecoration(labelText: 'Data di uscita'),
                  ),
                  TextFormField(
                    controller: _whenIWatchedController,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(
                          () => _whenIWatchedController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Quando l\'ho guardato',
                    ),
                  ),
                  CheckboxListTile(
                    value: _doIWatched,
                    onChanged: (bool? value) {
                      setState(() {
                        _doIWatched = value ?? false;
                      });
                    },
                    title: Text('L\'ho visto?'),
                  ),
                  TextFormField(
                    controller: _starsController,
                    decoration: InputDecoration(
                      labelText: 'Star',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (_starsController.text.isNotEmpty) {
                            setState(() {
                              _stars.add(_starsController.text);
                              _starsController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Wrap(
                    children: _stars
                        .map(
                          (star) => Chip(
                            label: Text(star),
                            onDeleted: () {
                              setState(() {
                                _stars.remove(star);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  TextFormField(
                    controller: _genresController,
                    decoration: InputDecoration(
                      labelText: 'Genere',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (_genresController.text.isNotEmpty) {
                            setState(() {
                              _genres.add(_genresController.text);
                              _genresController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Wrap(
                    children: _genres
                        .map(
                          (genre) => Chip(
                            label: Text(genre),
                            onDeleted: () {
                              setState(() {
                                _genres.remove(genre);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Voto'),
                        Text(_rating != null ? '${_rating}/10' : '0/10'),
                      ],
                    ),
                  ),
                  Slider(
                    value: _rating ?? 0,
                    min: 0,
                    max: 10,
                    divisions: 20,
                    label: _rating?.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C3489),
                      foregroundColor: const Color(0xFFCECBF6),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (widget.mediaItem != null) {
                        widget.mediaItem!.typeOfMedia = _selectedType;
                        widget.mediaItem!.title = _titleController.text;
                        widget.mediaItem!.originalTitle =
                            _originaltitleController.text;
                        widget.mediaItem!.director =
                            _directorController.text.isEmpty
                            ? null
                            : _directorController.text;
                        widget.mediaItem!.plot = _plotController.text.isEmpty
                            ? null
                            : _plotController.text;
                        widget.mediaItem!.cover = _coverController.text.isEmpty
                            ? null
                            : _coverController.text;
                        widget.mediaItem!.trailer =
                            _trailerController.text.isEmpty
                            ? null
                            : _trailerController.text;
                        widget.mediaItem!.comment =
                            _commentController.text.isEmpty
                            ? null
                            : _commentController.text;
                        widget.mediaItem!.duration = int.tryParse(
                          _durationController.text,
                        );
                        widget.mediaItem!.seasons = int.tryParse(
                          _seasonsController.text,
                        );
                        widget.mediaItem!.episodes = int.tryParse(
                          _episodesController.text,
                        );
                        widget.mediaItem!.watchedUntilEpisode = int.tryParse(
                          _watchedUntilEpisodeController.text,
                        );
                        widget.mediaItem!.releaseDate =
                            _releaseDateController.text.isEmpty
                            ? null
                            : DateFormat(
                                'dd/MM/yyyy',
                              ).parse(_releaseDateController.text);
                        widget.mediaItem!.whenIWatched =
                            _whenIWatchedController.text.isEmpty
                            ? null
                            : DateFormat(
                                'dd/MM/yyyy',
                              ).parse(_whenIWatchedController.text);
                        widget.mediaItem!.genre = _genres;
                        widget.mediaItem!.star = _stars;
                        widget.mediaItem!.rating = _rating ?? 0;
                        widget.mediaItem!.doIWatched = _doIWatched;
                        await widget.hiveService.updateMediaItem(
                          widget.mediaItem!,
                        );
                      } else {
                        await widget.hiveService.addMediaItem(
                          MediaItem(
                            typeOfMedia: _selectedType,
                            title: _titleController.text,
                            originalTitle: _originaltitleController.text,
                            director: _directorController.text.isEmpty
                                ? null
                                : _directorController.text,
                            plot: _plotController.text.isEmpty
                                ? null
                                : _plotController.text,
                            cover: _coverController.text.isEmpty
                                ? null
                                : _coverController.text,
                            trailer: _trailerController.text.isEmpty
                                ? null
                                : _trailerController.text,
                            comment: _commentController.text.isEmpty
                                ? null
                                : _commentController.text,
                            duration: int.tryParse(_durationController.text),
                            seasons: int.tryParse(_seasonsController.text),
                            episodes: int.tryParse(_episodesController.text),
                            watchedUntilEpisode: int.tryParse(
                              _watchedUntilEpisodeController.text,
                            ),
                            releaseDate: _releaseDateController.text.isEmpty
                                ? null
                                : DateFormat(
                                    'dd/MM/yyyy',
                                  ).parse(_releaseDateController.text),
                            whenIWatched: _whenIWatchedController.text.isEmpty
                                ? null
                                : DateFormat(
                                    'dd/MM/yyyy',
                                  ).parse(_whenIWatchedController.text),
                            genre: _genres,
                            star: _stars,
                            rating: _rating ?? 0,
                            doIWatched: _doIWatched,
                          ),
                        );
                      }

                      // Pulisco i campi
                      _titleController.clear();
                      _originaltitleController.clear();
                      _directorController.clear();
                      _plotController.clear();
                      _coverController.clear();
                      _trailerController.clear();
                      _commentController.clear();
                      _durationController.clear();
                      _seasonsController.clear();
                      _episodesController.clear();
                      _watchedUntilEpisodeController.clear();
                      _releaseDateController.clear();
                      _whenIWatchedController.clear();
                      _starsController.clear();
                      _genresController.clear();

                      setState(() {
                        _rating = null;
                        _stars = [];
                        _genres = [];
                        _doIWatched = false;
                        _selectedType = TypeOfMedia.film;
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Titolo salvato con successo!')),
                      );
                      Navigator.pop(context);
                    },
                    child: Text("Salva"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
