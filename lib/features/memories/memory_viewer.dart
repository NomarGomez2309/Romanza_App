part of 'memories_screen.dart';

/// Read-only viewer. No draft is published and no ownership/deletion authority
/// is inferred by this presentation component.
class MemoryViewer extends StatefulWidget {
  const MemoryViewer({super.key, required this.memories, this.initialIndex = 0})
    : assert(memories.length > 0),
      assert(initialIndex >= 0 && initialIndex < memories.length);
  final List<MemoryRecord> memories;
  final int initialIndex;
  @override
  State<MemoryViewer> createState() => _MemoryViewerState();
}

class _MemoryViewerState extends State<MemoryViewer> {
  late int index = widget.initialIndex;
  late final pages = PageController(initialPage: index);
  final strip = ScrollController();
  @override
  void dispose() {
    pages.dispose();
    strip.dispose();
    super.dispose();
  }

  void select(int value) {
    if (value < 0 || value >= widget.memories.length) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      pages.jumpToPage(value);
    } else {
      pages.animateToPage(
        value,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void changed(int value) {
    setState(() => index = value);
    if (strip.hasClients) {
      final offset = (value * 64 - strip.position.viewportDimension / 2 + 32)
          .clamp(0.0, strip.position.maxScrollExtent);
      if (MediaQuery.disableAnimationsOf(context)) {
        strip.jumpTo(offset);
      } else {
        strip.animateTo(
          offset,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final item = widget.memories[index];
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Su recuerdo', style: RomanzaType.heading(22, 28, 600)),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              Expanded(
                child: PageView.builder(
                  key: const ValueKey('memory-pages'),
                  controller: pages,
                  onPageChanged: changed,
                  itemCount: widget.memories.length,
                  itemBuilder: (_, value) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _MemoryImage(
                        widget.memories[value].photo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * .35,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatFullDate(item.publishedAt.toLocal()),
                        style: RomanzaType.days,
                        textAlign: TextAlign.center,
                      ),
                      if (item.caption.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            item.caption,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Recuerdo anterior',
                            onPressed: index > 0
                                ? () => select(index - 1)
                                : null,
                            icon: const RomanzaIcon(
                              RomanzaSymbol.arrowLeft,
                              size: 22,
                            ),
                          ),
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                '${index + 1} de ${widget.memories.length}',
                                textAlign: TextAlign.center,
                                style: RomanzaType.caption,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Recuerdo siguiente',
                            onPressed: index < widget.memories.length - 1
                                ? () => select(index + 1)
                                : null,
                            icon: const RomanzaIcon(
                              RomanzaSymbol.arrowLeft,
                              forward: true,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  controller: strip,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  itemCount: widget.memories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, value) => Semantics(
                    label: 'Abrir recuerdo ${value + 1}',
                    selected: value == index,
                    button: true,
                    child: InkWell(
                      key: ValueKey('memory-thumb-$value'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => select(value),
                      child: Container(
                        width: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 2,
                            color: value == index
                                ? c.primary
                                : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _MemoryImage(widget.memories[value].photo),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
