import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Fotos de cultivo: cada storageKey incluye GUID + timestamp, por lo que
/// una vez subida una imagen nunca cambia. Por eso usamos un stalePeriod
/// largo en vez del default de flutter_cache_manager (7 días).
class CropImageCacheManager {
  static const key = 'cropImagesCache';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );
}
