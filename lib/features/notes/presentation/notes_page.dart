import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/icons/nojin_icons.dart';
import '../../../core/iran/iran_date.dart';
import '../../../core/layout/nojin_breakpoints.dart';
import '../../../core/theme/nojin_tokens.dart';
import '../application/notes_state.dart';
import '../data/notes_repository.dart';
import '../domain/note.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});
  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(notesStateProvider.notifier).setQuery(value);
    });
  }

  Future<void> _edit([Note? note]) async {
    final draft = await showModalBottomSheet<_Draft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _Editor(note: note),
    );
    if (!mounted || draft == null) return;
    final n = ref.read(notesStateProvider.notifier);
    if (note == null) {
      await n.create(title: draft.title, content: draft.content, category: draft.category);
    } else {
      await n.update(note.copyWith(
        title: draft.title.trim().isEmpty ? 'یادداشت بدون عنوان' : draft.title.trim(),
        content: draft.content,
        category: draft.category,
      ));
    }
  }

  Future<void> _delete(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('حذف یادداشت'),
        content: const Text('این یادداشت برای همیشه حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(notesStateProvider.notifier).delete(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesStateProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: FilledButton(
          onPressed: () => ref.read(notesStateProvider.notifier).refresh(),
          child: const Text('تلاش دوباره'),
        ),
      ),
      data: (view) => LayoutBuilder(
        builder: (context, box) {
          final p = NojinBreakpoints.pagePadding(box.maxWidth);
          final max = NojinBreakpoints.contentMaxWidth(box.maxWidth);
          return Scaffold(
            backgroundColor: NojinColors.background,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _edit(),
              icon: const NojinIcon(NojinIconName.add, size: 20, color: Colors.white),
              label: const Text('یادداشت جدید'),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: max == double.infinity ? double.infinity : max),
                child: Column(
                  children: [
                    _Toolbar(
                      controller: _search,
                      view: view,
                      onSearch: _searchChanged,
                      onCategory: (v) => ref.read(notesStateProvider.notifier).setCategory(v),
                      onPinned: (v) => ref.read(notesStateProvider.notifier).setPinnedOnly(v),
                      onArchived: (v) => ref.read(notesStateProvider.notifier).setIncludeArchived(v),
                      onSort: (v) => ref.read(notesStateProvider.notifier).setSort(v),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref.read(notesStateProvider.notifier).refresh(),
                        child: view.notes.isEmpty
                            ? _Empty(onCreate: () => _edit())
                            : ListView(
                                padding: EdgeInsets.fromLTRB(p.left, 12, p.right, 110),
                                children: view.notes.map((n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _Card(
                                    note: n,
                                    onEdit: () => _edit(n),
                                    onPin: () => ref.read(notesStateProvider.notifier).togglePinned(n),
                                    onArchive: () => ref.read(notesStateProvider.notifier).toggleArchived(n),
                                    onDelete: () => _delete(n),
                                  ),
                                )).toList(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.view,
    required this.onSearch,
    required this.onCategory,
    required this.onPinned,
    required this.onArchived,
    required this.onSort,
  });
  final TextEditingController controller;
  final NotesViewState view;
  final ValueChanged<String> onSearch;
  final ValueChanged<NoteCategory?> onCategory;
  final ValueChanged<bool> onPinned;
  final ValueChanged<bool> onArchived;
  final ValueChanged<NoteSort> onSort;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(children: [
          TextField(
            controller: controller,
            onChanged: onSearch,
            decoration: const InputDecoration(
              hintText: 'جستجو در یادداشت‌ها',
              prefixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: NojinIcon(NojinIconName.search, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip('همه', view.category == null && !view.pinnedOnly && !view.includeArchived, () {
                  onCategory(null); onPinned(false); onArchived(false);
                }),
                ...NoteCategory.values.map((c) => _Chip(c.label, view.category == c, () {
                  onCategory(view.category == c ? null : c);
                })),
                _Chip('سنجاق‌شده', view.pinnedOnly, () => onPinned(!view.pinnedOnly)),
                _Chip('بایگانی', view.includeArchived, () => onArchived(!view.includeArchived)),
                _Chip(_sortLabel(view.sort), false, () => _sort(context)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _sort(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (c) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const ListTile(title: Text('مرتب‌سازی')),
        ListTile(title: const Text('آخرین تغییر'), onTap: () { Navigator.pop(c); onSort(NoteSort.updatedDesc); }),
        ListTile(title: const Text('جدیدترین ایجاد'), onTap: () { Navigator.pop(c); onSort(NoteSort.createdDesc); }),
        ListTile(title: const Text('عنوان'), onTap: () { Navigator.pop(c); onSort(NoteSort.titleAsc); }),
        const SizedBox(height: 10),
      ])),
    );
  }

  static String _sortLabel(NoteSort s) => switch (s) {
    NoteSort.updatedDesc => 'آخرین تغییر',
    NoteSort.createdDesc => 'جدیدترین',
    NoteSort.titleAsc => 'عنوان',
  };
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 6),
    child: ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: selected ? NojinColors.indigo : Theme.of(context).colorScheme.surface,
      side: BorderSide(color: selected ? Colors.transparent : NojinColors.border),
      labelStyle: TextStyle(color: selected ? Colors.white : NojinColors.text2, fontSize: 12),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.note, required this.onEdit, required this.onPin, required this.onArchive, required this.onDelete});
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NojinRadii.md), side: const BorderSide(color: NojinColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(note.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
            if (note.isPinned) const NojinIcon(NojinIconName.pin, size: 17, color: NojinColors.indigo),
          ]),
          if (note.content.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(note.content.trim(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: NojinColors.text2, height: 1.6)),
          ],
          const SizedBox(height: 9),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(gradient: NojinGradients.soft, borderRadius: BorderRadius.circular(NojinRadii.pill)),
              child: Text(note.category.label, style: const TextStyle(color: NojinColors.indigo, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const Spacer(),
            Text(IranDate.fromDateTime(note.updatedAt).display, style: const TextStyle(color: NojinColors.text3, fontSize: 11)),
          ]),
          const SizedBox(height: 9),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _Action('ویرایش', NojinIconName.edit, onEdit),
            _Action(note.isPinned ? 'برداشتن سنجاق' : 'سنجاق', NojinIconName.pin, onPin),
            _Action(note.isArchived ? 'بازگردانی' : 'بایگانی', NojinIconName.archive, onArchive),
            _Action('حذف', NojinIconName.delete, onDelete, danger: true),
          ]),
        ]),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.label, this.icon, this.onTap, {this.danger = false});
  final String label;
  final NojinIconName icon;
  final VoidCallback onTap;
  final bool danger;
  @override
  Widget build(BuildContext context) {
    final color = danger ? NojinColors.danger : NojinColors.text2;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: NojinIcon(icon, size: 14, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        textStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 80),
      Center(child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(gradient: NojinGradients.soft, borderRadius: BorderRadius.circular(22)),
        child: const Center(child: NojinIcon(NojinIconName.notes, size: 34, color: NojinColors.indigo)),
      )),
      const SizedBox(height: 18),
      const Text('هنوز یادداشتی ندارید', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('ایده‌ها، کارها و یادداشت‌های روزمره‌تان را اینجا نگه دارید.', textAlign: TextAlign.center, style: TextStyle(color: NojinColors.text2, height: 1.7)),
      const SizedBox(height: 20),
      Center(child: FilledButton.icon(
        onPressed: onCreate,
        icon: const NojinIcon(NojinIconName.add, size: 18, color: Colors.white),
        label: const Text('ساخت اولین یادداشت'),
      )),
    ],
  );
}

class _Draft {
  const _Draft(this.title, this.content, this.category);
  final String title;
  final String content;
  final NoteCategory category;
}

class _Editor extends StatefulWidget {
  const _Editor({this.note});
  final Note? note;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final TextEditingController title;
  late final TextEditingController content;
  late NoteCategory category;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.note?.title ?? '');
    content = TextEditingController(text: widget.note?.content ?? '');
    category = widget.note?.category ?? NoteCategory.general;
  }

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final editing = widget.note != null;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: NojinColors.border, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 18),
              Text(editing ? 'ویرایش یادداشت' : 'یادداشت جدید', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: title, autofocus: !editing, decoration: const InputDecoration(labelText: 'عنوان')),
              const SizedBox(height: 12),
              TextField(controller: content, minLines: 5, maxLines: 10, decoration: const InputDecoration(labelText: 'متن یادداشت', alignLabelWithHint: true)),
              const SizedBox(height: 14),
              const Text('دسته‌بندی', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(spacing: 7, children: NoteCategory.values.map((c) => ChoiceChip(
                label: Text(c.label), selected: category == c, onSelected: (_) => setState(() => category = c),
              )).toList()),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () => Navigator.pop(context, _Draft(title.text, content.text, category)),
                child: Text(editing ? 'ذخیره تغییرات' : 'ساخت یادداشت'),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}
