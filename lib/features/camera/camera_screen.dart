import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/romanza_theme.dart';
import 'capture_controller.dart';
import 'camera_icons.dart';
import 'draft_repository.dart';

class InstantCameraScreen extends StatefulWidget {
  const InstantCameraScreen({super.key, this.repository});
  final DraftRepository? repository;
  @override
  State<InstantCameraScreen> createState() => _InstantCameraScreenState();
}

class _InstantCameraScreenState extends State<InstantCameraScreen>
    with WidgetsBindingObserver {
  late final CaptureController controller;
  final caption = TextEditingController();
  String? _draftPath;
  bool closing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = CaptureController(widget.repository ?? LocalDraftRepository());
    controller.addListener(changed);
    controller.start();
  }

  void changed() {
    if (controller.draft?.path != _draftPath) {
      _draftPath = controller.draft?.path;
      caption.text = controller.draft?.caption ?? '';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) controller.suspend();
    if (state == AppLifecycleState.resumed) controller.resume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(changed);
    controller.dispose();
    caption.dispose();
    super.dispose();
  }

  Future<void> close() async {
    if (controller.busy || closing) return;
    closing = true;
    try {
      if (controller.draft != null) {
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tu borrador'),
            content: const Text(
              'Puedes conservar la foto y el texto en este dispositivo o descartarlos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'discard'),
                child: const Text('Descartar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, 'save'),
                child: const Text('Guardar y salir'),
              ),
            ],
          ),
        );
        if (action == null || !mounted) return;
        if (action == 'discard') {
          await controller.discard(reopen: false);
        } else {
          await controller.saveCaption(caption.text);
        }
        if (controller.error != null) return;
      }
      if (mounted) Navigator.pop(context);
    } finally {
      closing = false;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final c = RomanzaColors.of(context);
      final reviewing = controller.reviewing && controller.draft != null;
      return PopScope(
        canPop: !controller.busy && controller.draft == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) close();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: c.background.computeLuminance() > .179
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Stack(
              children: [
                SafeArea(
                  child: CameraComposition(
                    reviewing: reviewing,
                    caption: caption,
                    onClose: controller.busy ? null : close,
                    onCapture: controller.ready && !controller.busy
                        ? controller.capture
                        : null,
                    onFlip:
                        controller.canFlip &&
                            controller.ready &&
                            !controller.busy
                        ? controller.flip
                        : null,
                    onFlash: controller.canFlash && !controller.busy
                        ? controller.toggleFlash
                        : null,
                    flashEnabled: controller.flashEnabled,
                    frontFlash: controller.isFront,
                    busy: controller.busy,
                    error: reviewing || controller.ready
                        ? controller.error
                        : null,
                    onRepeat: controller.busy
                        ? null
                        : () async {
                            await controller.saveCaption(caption.text);
                            if (controller.error == null) {
                              await controller.repeat();
                            }
                          },
                    preview: reviewing
                        ? Image.file(
                            File(controller.draft!.path),
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Center(
                              child: Text(
                                'No pudimos abrir esta foto. Puedes repetirla.',
                              ),
                            ),
                          )
                        : controller.ready
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              final camera = controller.camera!;
                              final portrait =
                                  MediaQuery.orientationOf(context) ==
                                  Orientation.portrait;
                              final ratio = portrait
                                  ? 1 / camera.value.aspectRatio
                                  : camera.value.aspectRatio;
                              return ClipRect(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: constraints.maxHeight * ratio,
                                    height: constraints.maxHeight,
                                    child: CameraPreview(camera),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: controller.busy
                                ? const CircularProgressIndicator(
                                    semanticsLabel: 'Preparando cámara',
                                  )
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          controller.error ??
                                              'Cámara no disponible',
                                          textAlign: TextAlign.center,
                                        ),
                                        TextButton(
                                          onPressed: controller.start,
                                          child: const Text('Reintentar'),
                                        ),
                                        TextButton(
                                          onPressed: close,
                                          child: const Text('Volver'),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                  ),
                ),
                if (controller.screenFlash)
                  const Positioned.fill(
                    child: AbsorbPointer(
                      child: ColoredBox(
                        key: ValueKey('screen-flash'),
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Shared geometry keeps the square in the same place before/after capture.
class CameraComposition extends StatelessWidget {
  const CameraComposition({
    super.key,
    required this.preview,
    required this.reviewing,
    required this.caption,
    this.onClose,
    this.onCapture,
    this.onFlip,
    this.onFlash,
    this.onRepeat,
    this.flashEnabled = false,
    this.frontFlash = false,
    this.busy = false,
    this.error,
  });
  final Widget preview;
  final bool reviewing, flashEnabled, frontFlash, busy;
  final String? error;
  final TextEditingController caption;
  final VoidCallback? onClose, onCapture, onFlip, onFlash, onRepeat;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape =
            MediaQuery.orientationOf(context) == Orientation.landscape;
        final side = landscape
            ? math.min(
                constraints.maxWidth - 32,
                math.max(120.0, constraints.maxHeight - 179),
              )
            : constraints.maxWidth - 32;
        final gap = landscape ? 16.0 : 55.0;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(
                children: [
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: IconButton(
                      tooltip: reviewing
                          ? 'Cerrar confirmación'
                          : 'Cerrar cámara',
                      onPressed: onClose,
                      icon: CameraControlIcon(
                        CameraGlyph.close,
                        enabled: onClose != null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: reviewing
                        ? Text(
                            'Tu instantánea',
                            style: RomanzaType.heading(27, 32, 500),
                          )
                        : const SizedBox(),
                  ),
                  if (!reviewing)
                    Semantics(
                      toggled: flashEnabled,
                      child: IconButton(
                        tooltip: onFlash == null
                            ? 'Flash no disponible'
                            : '${frontFlash ? 'Flash de pantalla' : 'Flash'} ${flashEnabled ? 'encendido' : 'apagado'}',
                        onPressed: onFlash,
                        icon: CameraControlIcon(
                          flashEnabled
                              ? CameraGlyph.flashOn
                              : CameraGlyph.flashOff,
                          enabled: onFlash != null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: gap),
            Center(
              child: SizedBox(
                key: const ValueKey('square-viewport'),
                width: side,
                height: side,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColoredBox(color: c.memory, child: preview),
                ),
              ),
            ),
            if (reviewing) ...[
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(minHeight: 104),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: caption,
                      minLines: 2,
                      maxLines: 5,
                      enabled: !busy,
                      decoration: const InputDecoration(
                        hintText: 'Añade un texto…',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: RomanzaType.body.copyWith(fontSize: 16),
                    ),
                    Text('Opcional', style: RomanzaType.caption),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Visible durante 24 horas al publicar'),
              Text(
                'Borrador local · Publicación no disponible sin cuenta y pareja.',
                style: RomanzaType.caption.copyWith(color: c.secondary),
              ),
              if (error != null)
                Semantics(liveRegion: true, child: Text(error!)),
              if (busy)
                const LinearProgressIndicator(semanticsLabel: 'Guardando foto'),
            ],
            const Spacer(),
            if (!reviewing && controllerErrorVisible)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, textAlign: TextAlign.center),
              ),
            SizedBox(
              height: 107,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (reviewing)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 27,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: onRepeat,
                              child: Text('Repetir', style: RomanzaType.card),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: null,
                              child: Text('Publicar', style: RomanzaType.card),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Positioned(
                      top: 19,
                      child: Semantics(
                        button: true,
                        label: 'Tomar foto',
                        enabled: onCapture != null,
                        child: InkResponse(
                          onTap: onCapture,
                          radius: 40,
                          child: Container(
                            width: 74,
                            height: 74,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: c.primary, width: 2),
                            ),
                            child: busy
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: c.ink),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 32,
                      child: IconButton(
                        tooltip: 'Girar cámara',
                        onPressed: onFlip,
                        icon: CameraControlIcon(
                          CameraGlyph.flip,
                          enabled: onFlip != null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(child: content),
          ),
        );
      },
    );
  }

  bool get controllerErrorVisible => error != null && !busy;
}
