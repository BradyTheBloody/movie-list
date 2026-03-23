import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_list/config/secret.dart';
import 'package:movie_list/models/media_item.dart';

class TmdbService {
  static const String _apiKey = Secrets.tmdbApiKey;
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<List<Map<String, dynamic>>> searchMedia(
    String query,
    TypeOfMedia type,
  ) async {
    final endpoint = type == TypeOfMedia.film ? 'movie' : 'tv';
    final url = Uri.parse(
      '$_baseUrl/search/$endpoint?api_key=$_apiKey&query=$query&language=it-IT',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results'] ?? []);
  }

  Future<Map<String, dynamic>?> getDetails(int id, TypeOfMedia type) async {
    final endpoint = type == TypeOfMedia.film ? 'movie' : 'tv';
    final url = Uri.parse(
      '$_baseUrl/$endpoint/$id?api_key=$_apiKey&language=it-IT&append_to_response=credits',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    return json.decode(response.body);
  }

  String? getImageUrl(String? path) {
    if (path == null) return null;
    return '$_imageBaseUrl$path';
  }

  Map<String, dynamic> mapToMediaItem(
    Map<String, dynamic> details,
    TypeOfMedia type,
  ) {
    final credits = details['credits'] as Map<String, dynamic>?;
    final crew = credits?['crew'] as List? ?? [];
    final cast = credits?['cast'] as List? ?? [];

    final directors = crew
        .where((c) => c['job'] == 'Director')
        .map((c) => c['name'] as String)
        .toList();

    final stars = cast.take(5).map((c) => c['name'] as String).toList();

    final genres = (details['genres'] as List? ?? [])
        .map((g) => g['name'] as String)
        .toList();

    if (type == TypeOfMedia.film) {
      return {
        'title': details['title'] ?? '',
        'originalTitle': details['original_title'] ?? '',
        'plot': details['overview'] ?? '',
        'cover': getImageUrl(details['poster_path']),
        'releaseDate': details['release_date'],
        'duration': details['runtime'],
        'directors': directors,
        'stars': stars,
        'genres': genres,
      };
    } else {
      return {
        'title': details['name'] ?? '',
        'originalTitle': details['original_name'] ?? '',
        'plot': details['overview'] ?? '',
        'cover': getImageUrl(details['poster_path']),
        'releaseDate': details['first_air_date'],
        'duration': details['episode_run_time']?.first,
        'seasons': details['number_of_seasons'],
        'episodes': details['number_of_episodes'],
        'directors': directors,
        'stars': stars,
        'genres': genres,
      };
    }
  }
}
