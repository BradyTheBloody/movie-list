import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:movie_list/models/media_item.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class CsvService {
  Future<List<MediaItem>> importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return [];

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content, eol: '\n');

    if (rows.isEmpty) return [];

    // salto la prima riga (intestazioni)
    final dataRows = rows.skip(1);

    final List<MediaItem> items = [];

    for (final row in dataRows) {
      if (row.length < 18) continue;

      try {
        final tipo = row[0].toString().toLowerCase().trim();
        final typeOfMedia = switch (tipo) {
          'film' => TypeOfMedia.film,
          'serie' => TypeOfMedia.serie,
          'anime' => TypeOfMedia.anime,
          _ => TypeOfMedia.film,
        };

        final generi = row[5]
            .toString()
            .split(';')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final star = row[17]
            .toString()
            .split(';')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        DateTime? parseDate(String val) {
          try {
            return DateFormat('dd/MM/yyyy').parse(val.trim());
          } catch (_) {
            return null;
          }
        }

        items.add(
          MediaItem(
            typeOfMedia: typeOfMedia,
            title: row[1].toString(),
            originalTitle: row[2].toString(),
            director: row[3].toString().isEmpty ? null : row[3].toString(),
            duration: int.tryParse(row[4].toString()),
            genre: generi,
            plot: row[6].toString().isEmpty ? null : row[6].toString(),
            cover: row[7].toString().isEmpty ? null : row[7].toString(),
            trailer: row[8].toString().isEmpty ? null : row[8].toString(),
            rating: double.tryParse(row[9].toString()) ?? 0,
            comment: row[10].toString().isEmpty ? null : row[10].toString(),
            doIWatched: row[11].toString().toLowerCase() == 'true',
            whenIWatched: parseDate(row[12].toString()),
            releaseDate: parseDate(row[13].toString()),
            seasons: int.tryParse(row[14].toString()),
            episodes: int.tryParse(row[15].toString()),
            watchedUntilEpisode: int.tryParse(row[16].toString()),
            star: star.isEmpty ? null : star,
          ),
        );
      } catch (e) {
        continue;
      }
    }

    return items;
  }
}
