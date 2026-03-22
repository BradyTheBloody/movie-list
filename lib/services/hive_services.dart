import 'package:hive_flutter/adapters.dart';
import 'package:movie_list/models/media_item.dart';

class HiveService {
  late Box<MediaItem> _box;

  Future<void> init() async {
    _box = await Hive.openBox<MediaItem>('mediaItems');
  }

  Future<void> addMediaItem(MediaItem media_item) async {
    await _box.add(media_item);
  }

  Future<List<MediaItem>> getAllMediaItems() async {
    return _box.values.toList();
  }

  Future<void> deleteMediaItem(MediaItem media_item) async {
    await _box.delete(media_item.key);
  }

  Future<void> updateMediaItem(MediaItem media_item) async {
    media_item.lastModified = DateTime.now();
    await _box.put(media_item.key, media_item);
  }
}
