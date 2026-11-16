# Icono de instalación y nombre Romanza

Fuente aprobada por el usuario: R + corazón Default sobre crema, independiente de las paletas interiores. `assets/launcher/romanza-symbol.svg` conserva los trazados originales de Romanza-Default.svg. Colores fijos: R #9FA0FF, corazón #FF7171, fondo #FFF3E3.

## Regenerar

Desde la raíz, con Flutter y dependencias instaladas:

```powershell
flutter pub get
flutter test tools/branding/generate_launcher_sources_test.dart
dart run flutter_launcher_icons
dart run tools/branding/validate_launcher.dart
flutter build apk --debug
```

`flutter_launcher_icons.yaml` configura Android e iOS. La versión resuelta está en pubspec.lock. Los PNG fuente de 1024 se generan mediante Flutter SVG, no mediante un redibujo. El icono opaco usa símbolo de ancho 650; foreground y monochrome usan ancho 500 sobre lienzo transparente. El radio máximo de los píxeles visibles es 30.88dp en un plano adaptativo de 108dp: cabe dentro del círculo seguro de radio 33dp. El inset adicional es cero porque el margen ya está incluido.

Android: mipmaps heredados, foreground adaptativo, fondo crema y monochrome para iconos temáticos. icon y roundIcon referencian ic_launcher. El launcher decide la máscara y los colores de la variante temática, independientemente del tema de la app.

iOS: AppIcon.appiconset generado sin canal alfa, sin redondeado artificial. Se validan las dimensiones de las 25 entradas del catálogo. No se modifican splash, identificadores ni servicios.

Nombre visible Android: android:label="Romanza" en el manifest principal; no hay overrides de label en debug/profile ni flavors. iOS: CFBundleDisplayName=Romanza en Runner/Info.plist; no se encontraron overrides localizados o de build. CFBundleName interno y PRODUCT_BUNDLE_IDENTIFIER se conservan, al igual que applicationId, paquete Dart y Firebase.

## Evidencia y límites

Ver el informe de validación en docs/qa/launcher-pixel-2026-11-15.md. Compilar Android o generar el catálogo no demuestra una compilación/instalación de iOS, pendiente de macOS/Xcode y un dispositivo Apple.
