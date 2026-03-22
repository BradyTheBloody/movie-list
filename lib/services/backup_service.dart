import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:movie_list/models/media_item.dart';

class BackupService {
  static const int maxBackups = 4;
  static const String backupFolder = 'WatchList/Backups';

  Future<String?> createBackup(List<MediaItem> items) async {
    try {
      // richiedi permessi
      PermissionStatus status;
      if (Platform.isAndroid) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) return null;

      // trova la cartella Download
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/$backupFolder');
      } else {
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/$backupFolder');
      }

      // crea la cartella se non esiste
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // nome del file con data
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${directory.path}/backup_$date.csv');

      // genera il CSV
      final buffer = StringBuffer();
      buffer.writeln(
        'tipo,titolo,titolo_originale,regista,durata,generi,trama,copertina,trailer,voto,commento,guardato,quando_guardato,data_uscita,stagioni,episodi,ultimo_episodio,star,status,anno_fine',
      );

      for (final item in items) {
        final tipo = switch (item.typeOfMedia) {
          TypeOfMedia.film => 'film',
          TypeOfMedia.serie => 'serie',
          TypeOfMedia.anime => 'anime',
        };
        final status = item.status == null
            ? ''
            : switch (item.status!) {
                MediaStatus.inCorso => 'in corso',
                MediaStatus.completata => 'completata',
                MediaStatus.cancellata => 'cancellata',
              };

        buffer.writeln(
          [
            tipo,
            item.title,
            item.originalTitle,
            item.director ?? '',
            item.duration?.toString() ?? '',
            item.genre.join(';'),
            item.plot ?? '',
            item.cover ?? '',
            item.trailer ?? '',
            item.rating.toString(),
            item.comment ?? '',
            item.doIWatched.toString(),
            item.whenIWatched != null
                ? DateFormat('dd/MM/yyyy').format(item.whenIWatched!)
                : '',
            item.releaseDate != null
                ? DateFormat('dd/MM/yyyy').format(item.releaseDate!)
                : '',
            item.seasons?.toString() ?? '',
            item.episodes?.toString() ?? '',
            item.watchedUntilEpisode?.toString() ?? '',
            item.star?.join(';') ?? '',
            status,
            item.endYear?.toString() ?? '',
          ].join(','),
        );
      }

      await file.writeAsString(buffer.toString());

      // elimina i backup vecchi mantenendo solo gli ultimi 4
      await _cleanOldBackups(directory);

      return file.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cleanOldBackups(Directory directory) async {
    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.csv'))
            .toList()
          ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          );

    if (files.length > maxBackups) {
      for (final file in files.sublist(maxBackups)) {
        await file.delete();
      }
    }
  }
}
