import 'package:flutter/material.dart';

class CustomIconBox extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double borderRadius;
  final VoidCallback onTap;

  const CustomIconBox({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    this.iconColor = Colors.white, // Blanc par défaut
    this.size = 50.0,              // 50px par défaut
    this.borderRadius = 12.0,      // 12px par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // On utilise Material pour permettre l'effet "Ink" (vaguelette) au clic
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        // L'effet Splash se dessine sur le Material
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.5, // L'icône fera toujours la moitié de la box
          ),
        ),
      ),
    );
  }
}
