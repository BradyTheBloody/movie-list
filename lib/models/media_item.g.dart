// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaItemAdapter extends TypeAdapter<MediaItem> {
  @override
  final int typeId = 0;

  @override
  MediaItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaItem(
      typeOfMedia: fields[0] as TypeOfMedia,
      title: fields[1] as String,
      originalTitle: fields[2] as String,
      genre: (fields[6] as List).cast<String>(),
      rating: fields[10] as double,
      doIWatched: fields[17] as bool,
      releaseDate: fields[3] as DateTime?,
      director: fields[4] as String?,
      duration: fields[5] as int?,
      plot: fields[7] as String?,
      cover: fields[8] as String?,
      trailer: fields[9] as String?,
      comment: fields[11] as String?,
      star: (fields[12] as List?)?.cast<String>(),
      seasons: fields[13] as int?,
      episodes: fields[14] as int?,
      watchedUntilEpisode: fields[15] as int?,
      whenIWatched: fields[16] as DateTime?,
      lastModified: fields[18] as DateTime?,
      status: fields[19] as MediaStatus?,
      endYear: fields[20] as int?,
      collection: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MediaItem obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.typeOfMedia)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.originalTitle)
      ..writeByte(3)
      ..write(obj.releaseDate)
      ..writeByte(4)
      ..write(obj.director)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.plot)
      ..writeByte(8)
      ..write(obj.cover)
      ..writeByte(9)
      ..write(obj.trailer)
      ..writeByte(10)
      ..write(obj.rating)
      ..writeByte(11)
      ..write(obj.comment)
      ..writeByte(12)
      ..write(obj.star)
      ..writeByte(13)
      ..write(obj.seasons)
      ..writeByte(14)
      ..write(obj.episodes)
      ..writeByte(15)
      ..write(obj.watchedUntilEpisode)
      ..writeByte(16)
      ..write(obj.whenIWatched)
      ..writeByte(17)
      ..write(obj.doIWatched)
      ..writeByte(18)
      ..write(obj.lastModified)
      ..writeByte(19)
      ..write(obj.status)
      ..writeByte(20)
      ..write(obj.endYear)
      ..writeByte(21)
      ..write(obj.collection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TypeOfMediaAdapter extends TypeAdapter<TypeOfMedia> {
  @override
  final int typeId = 1;

  @override
  TypeOfMedia read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TypeOfMedia.film;
      case 1:
        return TypeOfMedia.serie;
      case 2:
        return TypeOfMedia.anime;
      default:
        return TypeOfMedia.film;
    }
  }

  @override
  void write(BinaryWriter writer, TypeOfMedia obj) {
    switch (obj) {
      case TypeOfMedia.film:
        writer.writeByte(0);
        break;
      case TypeOfMedia.serie:
        writer.writeByte(1);
        break;
      case TypeOfMedia.anime:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeOfMediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaStatusAdapter extends TypeAdapter<MediaStatus> {
  @override
  final int typeId = 2;

  @override
  MediaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MediaStatus.inCorso;
      case 1:
        return MediaStatus.completata;
      case 2:
        return MediaStatus.cancellata;
      default:
        return MediaStatus.inCorso;
    }
  }

  @override
  void write(BinaryWriter writer, MediaStatus obj) {
    switch (obj) {
      case MediaStatus.inCorso:
        writer.writeByte(0);
        break;
      case MediaStatus.completata:
        writer.writeByte(1);
        break;
      case MediaStatus.cancellata:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
