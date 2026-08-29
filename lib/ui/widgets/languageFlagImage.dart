import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Small circular flag/icon shown next to a language name (e.g. in the
/// change-language picker). The panel serves either a raster (jpg/png) or a
/// vector (svg) image for the same field, so the url's extension decides
/// which widget renders it.
///
/// SVGs are fetched and validated manually instead of via `SvgPicture
/// .network`: the locked flutter_svg version has no network-error callback,
/// so a bad url or a non-SVG response (e.g. an HTML error page) would
/// otherwise leave a blank circle forever instead of falling back cleanly.
class LanguageFlagImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const LanguageFlagImage({super.key, required this.imageUrl, this.size = 26});

  bool get _isSvg => (imageUrl ?? '').toLowerCase().endsWith('.svg');

  // In-memory per-url cache so re-rendering this row (e.g. on every language
  // switch, since the picker rebuilds on each state change) does not refetch
  // the same flag over and over.
  static final Map<String, Future<String?>> _svgCache = {};

  Future<String?> _loadSvg(String url) {
    final cached = _svgCache[url];
    if (cached != null) {
      return cached;
    }

    final request = () async {
      try {
        final response = await Dio().get<String>(
          url,
          options: Options(
            responseType: ResponseType.plain,
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        final body = response.data?.trim() ?? '';
        // Guard against non-SVG payloads (404/error pages) reaching the
        // renderer, which would otherwise throw during an async paint pass.
        // Such a url will not start working, so the miss stays cached.
        return body.contains('<svg') ? body : null;
      } catch (_) {
        // Network-level failure (offline, timeout): drop the entry so the next
        // rebuild retries, instead of showing the placeholder for the rest of
        // the session.
        _svgCache.remove(url);
        return null;
      }
    }();

    _svgCache[url] = request;
    return request;
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? _fallback(context)
            : _isSvg
                ? FutureBuilder<String?>(
                    future: _loadSvg(imageUrl!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return _loading(context);
                      }
                      final svgData = snapshot.data;
                      return svgData == null
                          ? _fallback(context)
                          : SvgPicture.string(
                              svgData,
                              width: size,
                              height: size,
                              fit: BoxFit.cover,
                            );
                    },
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _loading(context),
                    errorWidget: (_, __, ___) => _fallback(context),
                  ),
      ),
    );
  }

  Widget _loading(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surface,
      );

  Widget _fallback(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surface,
        alignment: Alignment.center,
        child: Icon(
          Icons.language,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
}
