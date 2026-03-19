import 'package:hive/hive.dart';

part 'media_item.g.dart';

@HiveType(typeId: 1)
enum TypeOfMedia {
  @HiveField(0)
  film,
  @HiveField(1)
  serie,
  @HiveField(2)
  anime,
}

@HiveType(typeId: 0)
class MediaItem extends HiveObject {
  @HiveField(0)
  TypeOfMedia typeOfMedia;
  @HiveField(1)
  String title;
  @HiveField(2)
  String originalTitle;
  @HiveField(3)
  DateTime? releaseDate;
  @HiveField(4)
  String? director;
  @HiveField(5)
  int? duration;
  @HiveField(6)
  List<String> genre;
  @HiveField(7)
  String? plot;
  @HiveField(8)
  String? cover;
  @HiveField(9)
  String? trailer;
  @HiveField(10)
  double rating;
  @HiveField(11)
  String? comment;
  @HiveField(12)
  List<String>? star;
  @HiveField(13)
  int? seasons;
  @HiveField(14)
  int? episodes;
  @HiveField(15)
  int? watchedUntilEpisode;
  @HiveField(16)
  DateTime? whenIWatched;
  @HiveField(17)
  bool doIWatched;

  MediaItem({
    required this.typeOfMedia,
    required this.title,
    required this.originalTitle,
    required this.genre,
    required this.rating,
    required this.doIWatched,
    this.releaseDate,
    this.director,
    this.duration,
    this.plot,
    this.cover,
    this.trailer,
    this.comment,
    this.star,
    this.seasons,
    this.episodes,
    this.watchedUntilEpisode,
    this.whenIWatched,
  });
}
