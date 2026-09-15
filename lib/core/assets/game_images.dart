import 'package:flutter/material.dart';

/// Caminhos padronizados dos assets visuais do caso.
class GameImages {
  static String photo(String photoId) => 'assets/images/photos/$photoId.jpg';

  static String avatar(String characterId) =>
      'assets/images/avatars/$characterId.jpg';

  static String wallpaper(String key) => 'assets/images/wallpapers/$key.jpg';
}

/// Imagem de asset com fallback se o arquivo ainda não existir.
class GameAssetImage extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final Widget? fallback;
  final double? width;
  final double? height;

  const GameAssetImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.fallback,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          fallback ??
          ColoredBox(
            color: Colors.white10,
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white24,
                size: ((width ?? 40) * 0.35).clamp(12, 48),
              ),
            ),
          ),
    );
  }
}

class GameAvatar extends StatelessWidget {
  final String? characterId;
  final String fallbackLetter;
  final double radius;

  const GameAvatar({
    super.key,
    required this.characterId,
    required this.fallbackLetter,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final letter = fallbackLetter.isNotEmpty
        ? fallbackLetter.characters.first.toUpperCase()
        : '?';
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white12,
      child: Text(letter, style: TextStyle(fontSize: radius * 0.85)),
    );
    final id = characterId;
    if (id == null || id.isEmpty) return fallback;
    return ClipOval(
      child: GameAssetImage(
        assetPath: GameImages.avatar(id),
        width: size,
        height: size,
        fallback: fallback,
      ),
    );
  }
}
