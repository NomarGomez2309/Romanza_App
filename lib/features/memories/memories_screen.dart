import 'package:flutter/material.dart';
import '../../design_system/components.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';

part 'memory_tiles.dart';
part 'memory_viewer.dart';

const _memoryMonths = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];
String _memoryDate(DateTime value, {bool year = false}) {
  final date = value.toLocal();
  return '${date.day} ${_memoryMonths[date.month - 1].substring(0, 3)}${year ? ' ${date.year}' : ''}';
}

String _memoryMonth(DateTime value) {
  final date = value.toLocal();
  final month = _memoryMonths[date.month - 1];
  return '${month[0].toUpperCase()}${month.substring(1)} ${date.year}';
}

String _memoryCount(int count) =>
    '$count ${count == 1 ? 'recuerdo' : 'recuerdos'}';

enum MemoryLibraryView { photos, collections }

enum MemoryGrouping { all, months, years }

enum MemoryCollection {
  us('Nosotros', RomanzaSymbol.heart),
  outings('Escapadas', RomanzaSymbol.calendarDays),
  everyday('Lo cotidiano', RomanzaSymbol.house);

  const MemoryCollection(this.label, this.icon);
  final String label;
  final RomanzaSymbol icon;
}

/// Presentation input only. The caller must supply authorized published records.
/// Camera drafts and generated preview fixtures never enter this list implicitly.
@immutable
class MemoryRecord {
  const MemoryRecord({
    required this.id,
    required this.photo,
    required this.publishedAt,
    this.collection = MemoryCollection.everyday,
    this.caption = '',
  });
  final String id, caption;
  final ImageProvider photo;
  final DateTime publishedAt;
  final MemoryCollection collection;
}

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({
    super.key,
    required this.onCamera,
    this.memories = const [],
    this.initialView = MemoryLibraryView.photos,
    this.initialGrouping = MemoryGrouping.all,
  });
  final VoidCallback onCamera;
  final List<MemoryRecord> memories;
  final MemoryLibraryView initialView;
  final MemoryGrouping initialGrouping;
  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  late MemoryLibraryView view = widget.initialView;
  late MemoryGrouping grouping = widget.initialGrouping;
  int preferredColumns = 3;
  List<MemoryRecord> get records =>
      [...widget.memories]
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

  void open(List<MemoryRecord> items, int index) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MemoryViewer(memories: items, initialIndex: index),
    ),
  );
  void album(String title, List<MemoryRecord> items) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(title, style: RomanzaType.section)),
            body: SafeArea(
              top: false,
              child: _MemoryScroll(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        _memoryCount(items.length),
                        style: RomanzaType.days,
                      ),
                    ),
                  ),
                  _memoryGrid(items, preferredColumns, (i) => open(items, i)),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final items = records;
    return _MemoryScroll(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text('Recuerdos', style: RomanzaType.greeting),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Preparar una foto',
                      onPressed: widget.onCamera,
                      style: IconButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: c.onPrimary,
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const RomanzaIcon(RomanzaSymbol.camera, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Pequeños momentos, una historia.',
                  style: RomanzaType.days.copyWith(color: c.secondary),
                ),
                const SizedBox(height: 20),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final value in MemoryLibraryView.values) ...[
                        if (value == MemoryLibraryView.collections)
                          const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => view = value),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: view == value
                                  ? c.ink
                                  : Colors.transparent,
                              foregroundColor: view == value
                                  ? c.background
                                  : c.ink,
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(
                                color: view == value ? c.ink : c.border,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: Semantics(
                              selected: view == value,
                              child: Text(
                                value == MemoryLibraryView.photos
                                    ? 'Fotos'
                                    : 'Colecciones',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (items.isNotEmpty && view == MemoryLibraryView.photos) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final value in MemoryGrouping.values)
                        ChoiceChip(
                          label: Text(switch (value) {
                            MemoryGrouping.all => 'Todas',
                            MemoryGrouping.months => 'Meses',
                            MemoryGrouping.years => 'Años',
                          }),
                          selected: grouping == value,
                          selectedColor: c.note,
                          backgroundColor: c.background,
                          labelStyle: RomanzaType.body.copyWith(
                            color: grouping == value ? c.ink : c.secondary,
                          ),
                          side: BorderSide(
                            color: grouping == value ? c.secondary : c.border,
                          ),
                          shape: const StadiumBorder(),
                          showCheckmark: false,
                          onSelected: (_) => setState(() => grouping = value),
                        ),
                      if (grouping == MemoryGrouping.all)
                        IconButton(
                          tooltip: preferredColumns == 3
                              ? 'Ver en dos columnas'
                              : 'Ver en tres columnas',
                          onPressed: () => setState(
                            () => preferredColumns = preferredColumns == 3
                                ? 2
                                : 3,
                          ),
                          icon: const RomanzaIcon(
                            RomanzaSymbol.images,
                            size: 22,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _memoryCount(items.length),
                    style: RomanzaType.caption.copyWith(color: c.secondary),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: RomanzaEmptyState(
              icon: RomanzaSymbol.romanzaRecuerdos,
              title: 'Lo que quieren conservar',
              message:
                  'Todavía no hay recuerdos compartidos. Puedes preparar una foto como borrador en este dispositivo.',
              action: FilledButton(
                onPressed: widget.onCamera,
                child: const Text('Preparar una foto'),
              ),
            ),
          )
        else if (view == MemoryLibraryView.collections)
          ..._collections(items, c)
        else if (grouping == MemoryGrouping.all)
          _memoryGrid(items, preferredColumns, (i) => open(items, i))
        else
          ..._groups(items, grouping == MemoryGrouping.years),
      ],
    );
  }

  List<Widget> _groups(List<MemoryRecord> items, bool years) {
    final groups = <String, List<MemoryRecord>>{};
    for (final item in items) {
      final date = item.publishedAt.toLocal();
      final key = years ? '${date.year}' : '${date.year}-${date.month}';
      groups.putIfAbsent(key, () => []).add(item);
    }
    final values = groups.values.toList();
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: values.length,
          itemBuilder: (context, index) {
            final group = values[index];
            final title = years
                ? '${group.first.publishedAt.toLocal().year}'
                : _memoryMonth(group.first.publishedAt);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: years
                  ? _MemoryCover(
                      title: title,
                      items: group,
                      onTap: () => album(title, group),
                    )
                  : _MemoryMonthCard(
                      title: title,
                      items: group,
                      onTap: () => album(title, group),
                    ),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _collections(List<MemoryRecord> items, RomanzaColors c) {
    final albums = MemoryCollection.values
        .where((value) => items.any((item) => item.collection == value))
        .toList();
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: _MemoryCover(
            title: 'Nuestro libro',
            items: items,
            onTap: () => album('Nuestro libro', items),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        sliver: SliverToBoxAdapter(
          child: Text('Álbumes', style: RomanzaType.section),
        ),
      ),
      SliverLayoutBuilder(
        builder: (context, constraints) {
          final columns =
              MediaQuery.textScalerOf(context).scale(14) > 21 ||
                  constraints.crossAxisExtent < 340
              ? 1
              : 2;
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: (albums.length / columns).ceil(),
              itemBuilder: (context, row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < columns; col++) ...[
                        if (col > 0) const SizedBox(width: 12),
                        Expanded(
                          child: row * columns + col >= albums.length
                              ? const SizedBox()
                              : Builder(
                                  builder: (context) {
                                    final value = albums[row * columns + col];
                                    final group = items
                                        .where(
                                          (item) => item.collection == value,
                                        )
                                        .toList();
                                    return _MemoryAlbumCard(
                                      title: value.label,
                                      items: group,
                                      onTap: () => album(value.label, group),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
}

/// The bottom inset supplied by an extended Scaffold keeps the last tile above
/// Romanza's floating tab bar. Slivers avoid building the entire photo library.
class _MemoryScroll extends StatelessWidget {
  const _MemoryScroll({required this.slivers});
  final List<Widget> slivers;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: RomanzaSpace.maxWidth),
      child: CustomScrollView(
        slivers: [
          ...slivers,
          SliverToBoxAdapter(
            child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    ),
  );
}

Widget _memoryGrid(
  List<MemoryRecord> items,
  int preferred,
  ValueChanged<int> onOpen,
) => SliverLayoutBuilder(
  builder: (context, constraints) {
    final available = constraints.crossAxisExtent - 32;
    final minimum = MediaQuery.textScalerOf(context).scale(11) > 16.5
        ? 150.0
        : 80.0;
    final columns = ((available + 6) / (minimum + 6)).floor().clamp(
      1,
      preferred,
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => MemoryPhotoCard(
            key: ValueKey('memory-${items[index].id}'),
            photo: items[index].photo,
            publishedAt: items[index].publishedAt,
            aspectRatio: 1,
            compact: true,
            onOpen: () => onOpen(index),
          ),
          childCount: items.length,
        ),
      ),
    );
  },
);
