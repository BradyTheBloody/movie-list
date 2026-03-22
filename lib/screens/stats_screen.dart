import 'package:flutter/material.dart';
import 'package:movie_list/models/media_item.dart';

class StatsScreen extends StatelessWidget {
  final List<MediaItem> mediaItems;

  const StatsScreen({required this.mediaItems, super.key});

  int get _totalFilmsWatched => mediaItems
      .where((i) => i.typeOfMedia == TypeOfMedia.film && i.doIWatched)
      .length;

  int get _totalSeriesWatched => mediaItems
      .where((i) => i.typeOfMedia == TypeOfMedia.serie && i.doIWatched)
      .length;

  int get _totalAnimeWatched => mediaItems
      .where((i) => i.typeOfMedia == TypeOfMedia.anime && i.doIWatched)
      .length;

  int get _totalToWatch => mediaItems.where((i) => !i.doIWatched).length;

  // ore totali guardate (solo titoli con durata)
  int get _totalMinutesWatched {
    int total = 0;
    for (final item in mediaItems.where((i) => i.doIWatched)) {
      if (item.typeOfMedia == TypeOfMedia.film) {
        total += item.duration ?? 0;
      } else {
        final episodes = item.watchedUntilEpisode ?? item.episodes ?? 0;
        total += (item.duration ?? 0) * episodes;
      }
    }
    return total;
  }

  int get _totalMinutesToWatch {
    int total = 0;
    for (final item in mediaItems.where((i) => !i.doIWatched)) {
      if (item.typeOfMedia == TypeOfMedia.film) {
        total += item.duration ?? 0;
      } else {
        final episodes = item.episodes ?? 0;
        total += (item.duration ?? 0) * episodes;
      }
    }
    return total;
  }

  int get _filmMinutes => mediaItems
      .where((i) => i.typeOfMedia == TypeOfMedia.film && i.doIWatched)
      .fold(0, (sum, i) => sum + (i.duration ?? 0));

  int get _serieMinutes => mediaItems
      .where((i) => i.typeOfMedia == TypeOfMedia.serie && i.doIWatched)
      .fold(
        0,
        (sum, i) =>
            sum +
            (i.duration ?? 0) * (i.watchedUntilEpisode ?? i.episodes ?? 0),
      );

  int get _animeMinutes => mediaItems
      .where((i) => i.typeOfMedia == TypeOfMedia.anime && i.doIWatched)
      .fold(
        0,
        (sum, i) =>
            sum +
            (i.duration ?? 0) * (i.watchedUntilEpisode ?? i.episodes ?? 0),
      );

  String _formatHours(int minutes) {
    final hours = minutes ~/ 60;
    return '${hours}h';
  }

  String _formatDays(int minutes) {
    final days = minutes ~/ 1440;
    return '$days giorni';
  }

  double _barWidth(int minutes, int total) {
    if (total == 0) return 0;
    return minutes / total;
  }

  Widget _statCard(String label, String value, String sub, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _barRow(String label, int minutes, int total, Color color) {
    final width = _barWidth(minutes, total);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: width,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              _formatHours(minutes),
              style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = _totalMinutesWatched;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOTALE TITOLI
              const Text(
                'TOTALE TITOLI',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Film',
                      '$_totalFilmsWatched',
                      'visti',
                      const Color(0xFFCECBF6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      'Serie',
                      '$_totalSeriesWatched',
                      'viste',
                      const Color(0xFF9FE1CB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      'Anime',
                      '$_totalAnimeWatched',
                      'visti',
                      const Color(0xFFF5C4B3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E1E1E), thickness: 0.5),
              const SizedBox(height: 16),

              // ORE GUARDATE
              const Text(
                'ORE GUARDATE',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatHours(totalMinutes),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFEF9F27),
                          ),
                        ),
                        const Text(
                          'ore totali guardate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDays(totalMinutes),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                        const Text(
                          'equivalenti',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E1E1E), thickness: 0.5),
              const SizedBox(height: 16),

              // ORE PER CATEGORIA
              const Text(
                'ORE PER CATEGORIA',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 10),
              _barRow(
                'Film',
                _filmMinutes,
                totalMinutes,
                const Color(0xFF3C3489),
              ),
              _barRow(
                'Serie',
                _serieMinutes,
                totalMinutes,
                const Color(0xFF085041),
              ),
              _barRow(
                'Anime',
                _animeMinutes,
                totalMinutes,
                const Color(0xFF993C1D),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E1E1E), thickness: 0.5),
              const SizedBox(height: 16),

              // DA GUARDARE
              const Text(
                'ANCORA DA GUARDARE',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Titoli',
                      '$_totalToWatch',
                      'in lista',
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      'Ore stimate',
                      _formatHours(_totalMinutesToWatch),
                      'da guardare',
                      const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
