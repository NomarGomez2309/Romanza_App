part of 'memories_screen.dart';

class _MemoryImage extends StatelessWidget {
  const _MemoryImage(this.photo, {this.fit = BoxFit.cover});
  final ImageProvider photo;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => Image(
    image: photo,
    fit: fit,
    excludeFromSemantics: true,
    frameBuilder: (context, child, frame, sync) => sync || frame != null
        ? child
        : ColoredBox(
            color: RomanzaColors.of(context).memory,
            child: const Center(
              child: RomanzaIcon(RomanzaSymbol.images, size: 28),
            ),
          ),
    errorBuilder: (context, _, stack) => ColoredBox(
      color: RomanzaColors.of(context).memory,
      child: const Center(
        child: RomanzaIcon(
          RomanzaSymbol.images,
          size: 28,
          semanticLabel: 'Foto no disponible',
        ),
      ),
    ),
  );
}

/// Existing portrait card remains available. Library tiles opt into square,
/// compact geometry while retaining the approved date/fade treatment.
class MemoryPhotoCard extends StatelessWidget {
  const MemoryPhotoCard({
    super.key,
    required this.photo,
    required this.publishedAt,
    required this.onOpen,
    this.aspectRatio = 175 / 243,
    this.compact = false,
  });
  final ImageProvider photo;
  final DateTime publishedAt;
  final VoidCallback onOpen;
  final double aspectRatio;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(publishedAt.toLocal());
    return Semantics(
      button: true,
      label: 'Recuerdo del $date',
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: RomanzaColors.of(context).memory,
            child: InkWell(
              onTap: onOpen,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _MemoryImage(photo),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: BoxConstraints(minHeight: compact ? 0 : 85),
                      padding: compact
                          ? const EdgeInsets.fromLTRB(8, 20, 8, 8)
                          : const EdgeInsets.fromLTRB(12, 32, 12, 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xA6000000),
                            Color(0xC9000000),
                          ],
                          stops: [0, .5, 1],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              compact ? _memoryDate(publishedAt) : date,
                              style: RomanzaType.body.copyWith(
                                fontSize: compact ? 11 : 13,
                                height: compact ? 14 / 11 : 18 / 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryMonthCard extends StatelessWidget {
  const _MemoryMonthCard({
    required this.title,
    required this.items,
    required this.onTap,
  });
  final String title;
  final List<MemoryRecord> items;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Material(
      color: c.memory,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: RomanzaType.heading(22, 28, 600)),
                        Text(
                          _memoryCount(items.length),
                          style: RomanzaType.caption.copyWith(
                            color: c.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RomanzaIcon(RomanzaSymbol.chevronRight, size: 22),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  Widget tile(int index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _MemoryImage(items[index].photo),
                  );
                  if (items.length == 1) {
                    return AspectRatio(aspectRatio: 1.8, child: tile(0));
                  }
                  if (items.length == 2) {
                    return AspectRatio(
                      aspectRatio: 2,
                      child: Row(
                        children: [
                          Expanded(child: tile(0)),
                          const SizedBox(width: 6),
                          Expanded(child: tile(1)),
                        ],
                      ),
                    );
                  }
                  return SizedBox(
                    height: (constraints.maxWidth - 6) * 2 / 3,
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: tile(0)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: tile(1)),
                              const SizedBox(height: 6),
                              Expanded(child: tile(2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryCover extends StatelessWidget {
  const _MemoryCover({
    required this.title,
    required this.items,
    required this.onTap,
  });
  final String title;
  final List<MemoryRecord> items;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$title, ${_memoryCount(items.length)}',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 210 + (MediaQuery.textScalerOf(context).scale(24) - 24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _MemoryImage(items.first.photo),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xA6000000),
                        Color(0xD9000000),
                      ],
                      stops: [0, .45, 1],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          style: RomanzaType.section.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _memoryCount(items.length),
                          style: RomanzaType.body.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _MemoryAlbumCard extends StatelessWidget {
  const _MemoryAlbumCard({
    required this.title,
    required this.items,
    required this.onTap,
  });
  final String title;
  final List<MemoryRecord> items;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Material(
      color: c.memory,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: _MemoryImage(items.first.photo),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RomanzaType.card),
                  const SizedBox(height: 4),
                  Text(
                    _memoryCount(items.length),
                    style: RomanzaType.caption.copyWith(color: c.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
