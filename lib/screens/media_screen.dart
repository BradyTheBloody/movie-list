import 'package:flutter/material.dart';
import 'package:movie_list/models/media_item.dart';
import 'package:movie_list/screens/form_screen.dart';
import 'package:movie_list/services/hive_services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaScreen extends StatefulWidget {
  final MediaItem mediaItem;
  final HiveService hiveService;

  const MediaScreen({
    required this.mediaItem,
    required this.hiveService,
    super.key,
  });

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

void _showCoverDialog(BuildContext context, String coverUrl) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  Container(color: const Color(0xFF1a1a1a), height: 300),
              errorWidget: (context, url, error) =>
                  Container(color: const Color(0xFF1E1E1E), height: 300),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MediaScreenState extends State<MediaScreen> {
  String? _getYoutubeId(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }
    return uri.queryParameters['v'];
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
      ),
    );
  }

  String _buildYearRange() {
    final start = widget.mediaItem.releaseDate?.year;
    final end = widget.mediaItem.endYear;
    if (start == null) return '';
    if (widget.mediaItem.typeOfMedia == TypeOfMedia.film)
      return start.toString();
    if (end != null && end != start) return '$start - $end';
    if (end != null && end == start) return start.toString();
    return '$start - ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dettagli"),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Elimina'),
                  content: Text('Sei sicuro di voler eliminare questo titolo?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annulla'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.hiveService.deleteMediaItem(widget.mediaItem);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Elimina'),
                    ),
                  ],
                ),
              );
              setState(() {});
            },
            icon: Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormScreen(
                    hiveService: widget.hiveService,
                    mediaItem: widget.mediaItem,
                  ),
                ),
              );
              setState(() {});
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HERO
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap:
                          widget.mediaItem.cover != null &&
                              widget.mediaItem.cover!.isNotEmpty
                          ? () => _showCoverDialog(
                              context,
                              widget.mediaItem.cover!,
                            )
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            widget.mediaItem.cover != null &&
                                widget.mediaItem.cover!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.mediaItem.cover!,
                                width: 100,
                                height: 148,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
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
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mediaItem.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.mediaItem.originalTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (widget.mediaItem.typeOfMedia ==
                                  TypeOfMedia.film)
                                if (widget.mediaItem.releaseDate != null)
                                  _chip(
                                    widget.mediaItem.releaseDate!.year
                                        .toString(),
                                  ),
                              if (widget.mediaItem.typeOfMedia !=
                                  TypeOfMedia.film)
                                if (widget.mediaItem.releaseDate != null)
                                  _chip(_buildYearRange()),
                              if (widget.mediaItem.status != null)
                                _chip(switch (widget.mediaItem.status!) {
                                  MediaStatus.inCorso => 'In corso',
                                  MediaStatus.completata => 'Completata',
                                  MediaStatus.cancellata => 'Cancellata',
                                }),
                              if (widget.mediaItem.duration != null)
                                _chip('${widget.mediaItem.duration} min'),
                              if (widget.mediaItem.director != null)
                                _chip(widget.mediaItem.director!),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                widget.mediaItem.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFEF9F27),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '/10',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // GUARDATO
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.mediaItem.doIWatched
                            ? const Color(0xFF3C3489)
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: widget.mediaItem.doIWatched
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Color(0xFFCECBF6),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Guardato',
                      style: TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
                    ),
                    const Spacer(),
                    if (widget.mediaItem.whenIWatched != null)
                      Text(
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(widget.mediaItem.whenIWatched!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF1E1E1E), thickness: 0.5),
              if (widget.mediaItem.trailer != null &&
                  widget.mediaItem.trailer!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRAILER',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555555),
                          letterSpacing: 0.06,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            launchUrl(Uri.parse(widget.mediaItem.trailer!)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      'https://img.youtube.com/vi/${_getYoutubeId(widget.mediaItem.trailer)}/hqdefault.jpg',
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(color: const Color(0xFF1E1E1E)),
                                  placeholder: (context, url) =>
                                      Container(color: const Color(0xFF1a1a1a)),
                                ),
                                Container(color: Colors.black26),
                                const Center(
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white24,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(color: Color(0xFF1E1E1E), thickness: 0.5),

              // TRAMA
              if (widget.mediaItem.plot != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRAMA',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555555),
                          letterSpacing: 0.06,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.mediaItem.plot!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFAAAAAA),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(color: Color(0xFF1E1E1E), thickness: 0.5),

              // GENERI
              if (widget.mediaItem.genre.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GENERI',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555555),
                          letterSpacing: 0.06,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.mediaItem.genre
                            .map(
                              (g) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1e1e3a),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFCECBF6),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),

              // ATTORI
              if (widget.mediaItem.star != null &&
                  widget.mediaItem.star!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ATTORI',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555555),
                          letterSpacing: 0.06,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.mediaItem.star!
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0a2a22),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9FE1CB),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),

              const Divider(color: Color(0xFF1E1E1E), thickness: 0.5),

              // COMMENTO
              if (widget.mediaItem.comment != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IL MIO COMMENTO',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555555),
                          letterSpacing: 0.06,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.mediaItem.comment!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFAAAAAA),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
