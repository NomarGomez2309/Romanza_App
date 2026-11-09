import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../design_system/romanza_theme.dart';
import 'capture_controller.dart';
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
    if (controller.busy) return;
    if (controller.draft != null && caption.text != controller.draft!.caption) {
      await controller.saveCaption(caption.text);
      if (controller.error != null) return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => PopScope(
      canPop:
          !controller.busy &&
          (controller.draft == null ||
              caption.text == controller.draft!.caption),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) close();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: controller.reviewing
            ? AppBar(
                leading: IconButton(
                  tooltip: 'Cerrar revisión',
                  onPressed: controller.busy ? null : close,
                  icon: const Icon(Icons.close),
                ),
                title: const Text('Revisar foto'),
              )
            : null,
        body: SafeArea(
          child: controller.reviewing && controller.draft != null
              ? review(context)
              : camera(context),
        ),
      ),
    ),
  );
  Widget camera(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: c.memory),
                  if (controller.ready)
                    LayoutBuilder(
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
                    ),
                  if (controller.busy)
                    const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Preparando cámara',
                      ),
                    ),
                  if (!controller.busy && controller.error != null)
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 64, 24, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            if (!controller.error!.contains('permiso'))
                              TextButton(
                                onPressed: controller.retryCamera,
                                child: const Text('Reintentar'),
                              ),
                            TextButton(
                              onPressed: controller.gallery,
                              child: const Text('Galería'),
                            ),
                            TextButton(
                              onPressed: close,
                              child: const Text('Volver'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton.filledTonal(
                      tooltip: 'Cerrar cámara',
                      onPressed: controller.busy ? null : close,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 107,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: 'Abrir galería',
                  onPressed: controller.busy ? null : controller.gallery,
                  icon: const Icon(Icons.photo_outlined, size: 28),
                ),
                Semantics(
                  button: true,
                  label: 'Tomar foto',
                  enabled: controller.ready && !controller.busy,
                  child: InkResponse(
                    onTap: controller.ready && !controller.busy
                        ? controller.capture
                        : null,
                    radius: 40,
                    child: Container(
                      width: 74,
                      height: 74,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.primary, width: 3),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.ink),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Girar cámara',
                  onPressed:
                      controller.busy ||
                          !controller.canFlip ||
                          !controller.ready
                      ? null
                      : controller.flip,
                  icon: const Icon(Icons.cameraswitch_outlined, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget review(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      SizedBox(
        height: MediaQuery.sizeOf(context).height * .38,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            File(controller.draft!.path),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Center(
              child: Text('No pudimos abrir esta foto. Puedes repetirla.'),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: caption,
        minLines: 1,
        maxLines: 5,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          labelText: 'Texto opcional',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Borrador privado en este dispositivo. Para publicar y guardar en Recuerdos harán falta una cuenta y una pareja vinculada.',
      ),
      const SizedBox(height: 12),
      const FilledButton(onPressed: null, child: Text('Publicar')),
      OutlinedButton(
        onPressed: controller.busy
            ? null
            : () async {
                await controller.saveCaption(caption.text);
                if (context.mounted && controller.error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Borrador guardado en este dispositivo'),
                    ),
                  );
                }
              },
        child: const Text('Guardar borrador'),
      ),
      Wrap(
        spacing: 8,
        children: [
          TextButton(
            onPressed: controller.busy
                ? null
                : () async {
                    await controller.saveCaption(caption.text);
                    if (controller.error == null) await controller.repeat();
                  },
            child: const Text('Repetir'),
          ),
          TextButton(
            onPressed: controller.busy
                ? null
                : () async {
                    await controller.saveCaption(caption.text);
                    if (controller.error == null) await controller.gallery();
                  },
            child: const Text('Volver a seleccionar'),
          ),
          TextButton(
            onPressed: controller.busy ? null : discard,
            child: const Text('Descartar borrador'),
          ),
        ],
      ),
      if (controller.busy)
        const LinearProgressIndicator(semanticsLabel: 'Guardando borrador'),
      if (controller.error != null)
        Semantics(liveRegion: true, child: Text(controller.error!)),
    ],
  );
  Future<void> discard() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar el borrador?'),
        content: const Text(
          'Se eliminarán la copia privada de esta foto y su texto. El original de la galería no se modifica.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) await controller.discard();
  }
}
