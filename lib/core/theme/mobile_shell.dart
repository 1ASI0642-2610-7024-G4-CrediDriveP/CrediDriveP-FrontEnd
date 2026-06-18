import 'package:flutter/material.dart';

/// Envuelve el contenido de cualquier pantalla para mantener el diseño
/// mobile-first: ancho máximo de 430 logical pixels (≈ iPhone 14 Pro Max)
/// centrado horizontalmente. En pantallas más anchas (web/desktop) se
/// pinta un fondo gris para que la app conserve la silueta de una app móvil.
class MobileShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool addBottomInset;
  const MobileShell({
    super.key,
    required this.child,
    this.maxWidth = 430,
    this.padding,
    this.addBottomInset = false,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.only(
                bottom: addBottomInset ? viewPadding.bottom : 0,
              ),
          child: child,
        ),
      ),
    );
  }
}
