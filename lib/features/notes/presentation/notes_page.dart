import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/icons/nojin_icons.dart';
import '../../../core/iran/iran_date.dart';
import '../../../core/layout/nojin_breakpoints.dart';
import '../../../core/theme/nojin_tokens.dart';
import '../application/notes_state.dart';
import '../data/notes_repository.dart';
import '../data/media_provider.dart';
import '../data/media_repository.dart';
import '../application/media_service.dart';
import '../application/audio_recorder_service.dart';
import '../domain/media_attachment.dart';
import '../domain/media_format.dart';
import '../domain/note.dart';
import '../domain/rich_block.dart';
import '../domain/rich_block_codec.dart';

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
    final mediaRepository = await ref.read(mediaRepositoryProvider.future);
    if (!mounted) return;
    final draft = await showModalBottomSheet<_Draft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _Editor(note: note, mediaRepository: mediaRepository),
    );
    if (!mounted || draft == null) return;
    final n = ref.read(notesStateProvider.notifier);
    Note saved;
    if (note == null) {
      saved = await n.create(
        title: draft.title,
        content: draft.content,
        category: draft.category,
      );
    } else {
      saved = note.copyWith(
        title: draft.title.trim().isEmpty ? 'یادداشت بدون عنوان' : draft.title.trim(),
        content: draft.content,
        category: draft.category,
      );
    }

    final mediaIds = <String, String>{};
    for (final pending in draft.pendingMedia) {
      final attachment = await mediaRepository.add(
        noteId: saved.id,
        type: pending.type,
        fileName: pending.fileName,
        mimeType: pending.mimeType,
        bytes: pending.bytes,
        durationMs: pending.durationMs,
      );
      mediaIds[pending.tempId] = attachment.id;
    }

    var document = RichDocument.decode(draft.content);
    document = RichDocument(document.blocks.map((block) {
      final mapped = block.mediaId == null ? null : mediaIds[block.mediaId!];
      return mapped == null ? block : block.copyWith(mediaId: mapped);
    }).toList(growable: false));

    if (note != null) {
      final previous = RichDocument.decode(note.content).blocks
          .map((b) => b.mediaId)
          .whereType<String>()
          .toSet();
      final current = document.blocks.map((b) => b.mediaId).whereType<String>().toSet();
      for (final id in previous.difference(current)) {
        await mediaRepository.delete(id);
      }
      await n.update(saved.copyWith(content: RichBlockCodec.toContent(document)));
    } else if (draft.pendingMedia.isNotEmpty) {
      await n.update(saved.copyWith(content: RichBlockCodec.toContent(document)));
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
        ListTile(title: const Text('قدیمی'), onTap: () { Navigator.pop(c); onSort(NoteSort.createdAsc); }),
        ListTile(title: const Text('سنجاق'), onTap: () { Navigator.pop(c); onSort(NoteSort.pinnedFirst); }),
        const SizedBox(height: 10),
      ])),
    );
  }

  static String _sortLabel(NoteSort s) => switch (s) {
    NoteSort.updatedDesc => 'جدید',
    NoteSort.createdAsc => 'قدیمی',
    NoteSort.pinnedFirst => 'سنجاق',
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
            Text(RichBlockCodec.preview(note.content), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: NojinColors.text2, height: 1.6)),
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
  const _Draft(this.title, this.content, this.category, this.pendingMedia);
  final String title;
  final String content;
  final NoteCategory category;
  final List<MediaDraft> pendingMedia;
}

class _Editor extends StatefulWidget {
  const _Editor({this.note, required this.mediaRepository});
  final Note? note;
  final MediaRepository mediaRepository;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final TextEditingController title;
  late NoteCategory category;
  late List<RichBlock> blocks;
  final List<MediaDraft> pendingMedia = [];
  final MediaService _media = MediaService();
  final AudioRecorderService _recorder = AudioRecorderService();

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.note?.title ?? '');
    category = widget.note?.category ?? NoteCategory.general;
    blocks = widget.note == null
        ? [_newBlock(RichBlockType.text)]
        : List.of(RichBlockCodec.fromContent(widget.note!.content).blocks);
    if (blocks.isEmpty) blocks = [_newBlock(RichBlockType.text)];
  }

  RichBlock _newBlock(RichBlockType type, [String text = '']) => RichBlock(
        id: DateTime.now().microsecondsSinceEpoch.toString() + '-' + blocks.length.toString(),
        type: type,
        text: text,
      );

  @override
  void dispose() {
    title.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _add(RichBlockType type) {
    setState(() => blocks.add(_newBlock(type)));
  }

  void _remove(int index) {
    if (blocks.length == 1) {
      setState(() => blocks[0] = _newBlock(RichBlockType.text));
      return;
    }
    setState(() => blocks.removeAt(index));
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= blocks.length) return;
    setState(() {
      final block = blocks.removeAt(index);
      blocks.insert(target, block);
    });
  }

  void _update(int index, String value) {
    blocks[index] = blocks[index].copyWith(text: value);
  }

  void _save() {
    final document = RichDocument(blocks);
    Navigator.pop(context, _Draft(
      title.text,
      RichBlockCodec.toContent(document),
      category,
      List.unmodifiable(pendingMedia),
    ));
  }

  Future<void> _addMedia(MediaDraft? draft) async {
    if (draft == null) return;
    if (draft.bytes.length > MediaLimits.maxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حجم فایل بیشتر از ۲۵ مگابایت است.')),
        );
      }
      return;
    }
    setState(() {
      pendingMedia.add(draft);
      blocks.add(RichBlock(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: switch (draft.type) {
          MediaType.image => RichBlockType.image,
          MediaType.video => RichBlockType.video,
          MediaType.audio => RichBlockType.audio,
          MediaType.file => RichBlockType.file,
        },
        mediaId: draft.tempId,
        text: draft.fileName,
      ));
    });
  }

  Future<void> _pickImage() async { await _addMedia(await _media.pickImage()); }
  Future<void> _pickVideo() async { await _addMedia(await _media.pickVideo()); }
  Future<void> _pickFile() async { await _addMedia(await _media.pickFile()); }

  Future<void> _recordAudio() async {
    if (_recorder.isRecording) {
      final bytes = await _recorder.stop();
      if (bytes != null) await _addMedia(_media.fromRecordedBytes(bytes: bytes));
      if (mounted) setState(() {});
      return;
    }
    final ok = await _recorder.start();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دسترسی میکروفون داده نشد.')),
      );
    }
    if (mounted) setState(() {});
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 760),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        editing ? 'ویرایش یادداشت' : 'یادداشت جدید',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: 'بستن',
                      onPressed: () => Navigator.pop(context),
                      icon: const NojinIcon(NojinIconName.close, size: 20),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: TextField(
                    controller: title,
                    autofocus: !editing,
                    decoration: const InputDecoration(labelText: 'عنوان'),
                  ),
                ),
                const SizedBox(height: 10),
                _BlockToolbar(onAdd: _add, onImage: _pickImage, onVideo: _pickVideo, onFile: _pickFile, onAudio: _recordAudio, recording: _recorder.isRecording),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) => _BlockEditor(
                      key: ValueKey(blocks[index].id),
                      block: blocks[index],
                      onChanged: (value) => setState(() => _update(index, value)),
                      onToggle: () => setState(() => blocks[index] =
                          blocks[index].copyWith(checked: !blocks[index].checked)),
                      onExpanded: () => setState(() => blocks[index] =
                          blocks[index].copyWith(expanded: !blocks[index].expanded)),
                      onDelete: () => _remove(index),
                      onUp: index == 0 ? null : () => _move(index, -1),
                      onDown: index == blocks.length - 1 ? null : () => _move(index, 1),
                      mediaRepository: widget.mediaRepository,
                      pendingMedia: pendingMedia,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                  child: Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<NoteCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'دسته‌بندی'),
                        items: NoteCategory.values
                            .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                            .toList(),
                        onChanged: (value) => setState(() => category = value ?? category),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _save,
                      child: Text(editing ? 'ذخیره' : 'ساخت'),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlockToolbar extends StatelessWidget {
  const _BlockToolbar({
    required this.onAdd,
    required this.onImage,
    required this.onVideo,
    required this.onFile,
    required this.onAudio,
    required this.recording,
  });

  final ValueChanged<RichBlockType> onAdd;
  final VoidCallback onImage;
  final VoidCallback onVideo;
  final VoidCallback onFile;
  final VoidCallback onAudio;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _Tool('متن', RichBlockType.text, onAdd),
          _Tool('عنوان', RichBlockType.heading, onAdd),
          _Tool('چک‌لیست', RichBlockType.checklist, onAdd),
          _Tool('لیست', RichBlockType.bulletList, onAdd),
          _Tool('شماره‌دار', RichBlockType.numberedList, onAdd),
          _Tool('تاریخ', RichBlockType.date, onAdd),
          _Tool('نقل‌قول', RichBlockType.quote, onAdd),
          _Tool('کد', RichBlockType.code, onAdd),
          _Tool('خط', RichBlockType.divider, onAdd),
          _Tool('بازشونده', RichBlockType.toggle, onAdd),
          const VerticalDivider(width: 18),
          _MediaTool('تصویر', onImage),
          _MediaTool('ویدئو', onVideo),
          _MediaTool(recording ? 'توقف ضبط' : 'ضبط صوت', onAudio),
          _MediaTool('فایل', onFile),
        ],
      ),
    );
  }
}

class _MediaTool extends StatelessWidget {
  const _MediaTool(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 6),
    child: ActionChip(
      avatar: const NojinIcon(NojinIconName.add, size: 14),
      label: Text(label),
      onPressed: onTap,
    ),
  );
}

class _Tool extends StatelessWidget {
  const _Tool(this.label, this.type, this.onAdd);
  final String label;
  final RichBlockType type;
  final ValueChanged<RichBlockType> onAdd;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 6),
    child: ActionChip(
      avatar: const NojinIcon(NojinIconName.add, size: 14),
      label: Text(label),
      onPressed: () => onAdd(type),
    ),
  );
}

class _BlockEditor extends StatefulWidget {
  const _BlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onToggle,
    required this.onExpanded,
    required this.onDelete,
    required this.onUp,
    required this.onDown,
    required this.mediaRepository,
    required this.pendingMedia,
  });
  final RichBlock block;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;
  final VoidCallback onExpanded;
  final VoidCallback onDelete;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final MediaRepository mediaRepository;
  final List<MediaDraft> pendingMedia;

  @override
  State<_BlockEditor> createState() => _BlockEditorState();
}

class _MediaBlockPreview extends StatefulWidget {
  const _MediaBlockPreview({
    required this.type,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    required this.sizeBytes,
  });

  final RichBlockType type;
  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final int sizeBytes;

  @override
  State<_MediaBlockPreview> createState() => _MediaBlockPreviewState();
}

class _MediaBlockPreviewState extends State<_MediaBlockPreview> {
  AudioPlayer? _player;
  bool _playing = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final player = _player ??= AudioPlayer();
    if (_playing) {
      await player.pause();
      if (mounted) setState(() => _playing = false);
      return;
    }
    await player.play(BytesSource(widget.bytes, mimeType: widget.mimeType));
    if (mounted) setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == RichBlockType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(NojinRadii.md),
        child: Image.memory(widget.bytes, fit: BoxFit.cover, width: double.infinity, height: 220),
      );
    }

    final icon = switch (widget.type) {
      RichBlockType.video => Icons.movie_outlined,
      RichBlockType.audio => Icons.mic_none,
      _ => Icons.insert_drive_file_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NojinColors.background,
        borderRadius: BorderRadius.circular(NojinRadii.md),
        border: Border.all(color: NojinColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: NojinColors.indigo),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(MediaFormat.size(widget.sizeBytes), style: const TextStyle(color: NojinColors.text3, fontSize: 11)),
              ],
            ),
          ),
          if (widget.type == RichBlockType.audio)
            IconButton(
              tooltip: _playing ? 'توقف' : 'پخش',
              onPressed: _toggleAudio,
              icon: NojinIcon(
                _playing ? NojinIconName.close : NojinIconName.sparkle,
                size: 18,
                color: NojinColors.indigo,
              ),
            ),
          if (widget.type == RichBlockType.video)
            const Text('ویدئو', style: TextStyle(color: NojinColors.text3, fontSize: 11)),
        ],
      ),
    );
  }
}

class _BlockEditorState extends State<_BlockEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.text);
  }

  @override
  void didUpdateWidget(covariant _BlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.text != widget.block.text && _controller.text != widget.block.text) {
      final selection = _controller.selection;
      _controller.value = TextEditingValue(text: widget.block.text,
        selection: selection.isValid && selection.end <= widget.block.text.length
            ? selection : TextSelection.collapsed(offset: widget.block.text.length));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    if (const [
      RichBlockType.image,
      RichBlockType.video,
      RichBlockType.audio,
      RichBlockType.file,
    ].contains(block.type)) {
      MediaDraft? pending;
      for (final item in widget.pendingMedia) {
        if (item.tempId == block.mediaId) { pending = item; break; }
      }
      if (pending != null) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _MediaBlockPreview(
            type: block.type,
            fileName: pending.fileName,
            mimeType: pending.mimeType,
            bytes: pending.bytes,
            sizeBytes: pending.bytes.length,
          ),
        );
      }
      return FutureBuilder<MediaAttachment?>(
        future: block.mediaId == null ? Future.value(null) : widget.mediaRepository.getById(block.mediaId!),
        builder: (context, snapshot) {
          final media = snapshot.data;
          if (media == null) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.broken_image_outlined),
                title: Text('رسانه پیدا نشد'),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MediaBlockPreview(
              type: block.type,
              fileName: media.fileName,
              mimeType: media.mimeType,
              bytes: media.bytes,
              sizeBytes: media.sizeBytes,
            ),
          );
        },
      );
    }

    if (block.type == RichBlockType.divider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          const Expanded(child: Divider()),
          IconButton(onPressed: widget.onDelete, tooltip: 'حذف', icon: const NojinIcon(NojinIconName.delete, size: 16)),
        ]),
      );
    }

    final decoration = InputDecoration(
      hintText: _hint,
      border: InputBorder.none,
      filled: true,
      fillColor: block.type == RichBlockType.code
          ? NojinColors.background
          : Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

    Widget editor;
    switch (widget.block.type) {
      case RichBlockType.heading:
        editor = TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          maxLines: 2,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          decoration: decoration,
        );
      case RichBlockType.checklist:
        editor = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Checkbox(value: block.checked, onChanged: (_) => widget.onToggle()),
          Expanded(child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            minLines: 1,
            maxLines: 5,
            decoration: decoration,
          )),
        ]);
      case RichBlockType.bulletList:
      case RichBlockType.numberedList:
        editor = TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          minLines: 3,
          maxLines: 8,
          decoration: decoration.copyWith(
            hintText: block.type == RichBlockType.bulletList ? 'هر مورد در یک خط...' : 'هر مورد در یک خط...',
            prefixText: block.type == RichBlockType.bulletList ? '• ' : '1. ',
          ),
        );
      case RichBlockType.date:
        final date = DateTime.tryParse(block.text)?.toUtc() ?? DateTime.now().toUtc();
        editor = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: NojinGradients.soft,
            borderRadius: BorderRadius.circular(NojinRadii.md),
          ),
          child: Row(children: [
            const NojinIcon(NojinIconName.sparkle, size: 18, color: NojinColors.indigo),
            const SizedBox(width: 8),
            Expanded(child: Text(IranDate.fromDateTime(date).display)),
            TextButton(onPressed: () => widget.onChanged(DateTime.now().toUtc().toIso8601String()), child: const Text('امروز')),
          ]),
        );
      case RichBlockType.quote:
        editor = Container(
          decoration: const BoxDecoration(
            border: BorderDirectional(start: BorderSide(color: NojinColors.indigo, width: 3)),
          ),
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            minLines: 2,
            maxLines: 8,
            decoration: decoration.copyWith(hintText: 'متن نقل‌قول'),
          ),
        );
      case RichBlockType.code:
        editor = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          minLines: 3,
          maxLines: 12,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: decoration.copyWith(hintText: 'کد'),
          ),
          Align(alignment: AlignmentDirectional.centerEnd, child: TextButton.icon(
            onPressed: () => Clipboard.setData(ClipboardData(text: block.text)),
            icon: const NojinIcon(NojinIconName.copy, size: 14),
            label: const Text('کپی کد'),
          )),
        ]);
      case RichBlockType.toggle:
        editor = Column(children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: NojinIcon(block.expanded ? NojinIconName.chevronDown : NojinIconName.chevronLeft, size: 18),
            title: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: decoration.copyWith(hintText: 'عنوان بازشونده'),
            ),
            onTap: widget.onExpanded,
          ),
          if (block.expanded)
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 40, bottom: 6),
              child: Align(alignment: AlignmentDirectional.centerStart, child: Text('محتوای بازشونده در فازهای بعدی قابل توسعه است.')),
            ),
        ]);
      case RichBlockType.image:
      case RichBlockType.video:
      case RichBlockType.audio:
      case RichBlockType.file:
        editor = const SizedBox.shrink();
      case RichBlockType.text:
        editor = TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          minLines: 2,
          maxLines: 8,
          decoration: decoration.copyWith(hintText: 'متن را بنویسید...'),
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(children: [
        editor,
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(onPressed: widget.onUp, tooltip: 'بالا', icon: const NojinIcon(NojinIconName.arrowUp, size: 16)),
          IconButton(onPressed: widget.onDown, tooltip: 'پایین', icon: const NojinIcon(NojinIconName.arrowDown, size: 16)),
          IconButton(onPressed: widget.onDelete, tooltip: 'حذف بلوک', icon: const NojinIcon(NojinIconName.delete, size: 16)),
        ]),
      ]),
    );
  }

  String get _hint => switch (widget.block.type) {
    RichBlockType.text => 'متن را بنویسید...',
    RichBlockType.heading => 'عنوان...',
    RichBlockType.checklist => 'کار موردنظر...',
    RichBlockType.quote => 'نقل‌قول...',
    RichBlockType.code => 'کد...',
    RichBlockType.bulletList => 'هر مورد در یک خط...',
    RichBlockType.numberedList => 'هر مورد در یک خط...',
    RichBlockType.date => '',
    RichBlockType.toggle => 'عنوان بازشونده...',
    RichBlockType.divider => '',
  };
}
