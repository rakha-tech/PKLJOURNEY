import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    required this.entries,
    required this.onAddEntry,
  });

  final List<JournalEntry> entries;
  final ValueChanged<JournalEntry> onAddEntry;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  Future<void> _openEntryForm() async {
    final entry = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _JournalFormSheet(),
    );
    if (entry != null) widget.onAddEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Jurnal kegiatan',
            subtitle: 'Simpan pengalaman dan hal baru yang kamu pelajari.',
            trailing: IconButton.filled(
              onPressed: _openEntryForm,
              tooltip: 'Tambah jurnal',
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.paleAmber,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cream),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: AppColors.amber),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Catatan kecil hari ini bisa jadi bekal besar untuk masa depan.',
                    style: TextStyle(
                      color: AppColors.taupe,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionLabel(
            'Catatanmu',
            action: '${widget.entries.length} kegiatan',
          ),
          if (widget.entries.isEmpty)
            WhiteCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.maroon,
                    size: 38,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada jurnal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mulai catat pengalaman PKL pertamamu hari ini.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _openEntryForm,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tulis jurnal'),
                  ),
                ],
              ),
            )
          else
            ...widget.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _JournalCard(entry: entry),
              ),
            ),
          const SizedBox(height: 5),
          OutlinedButton.icon(
            onPressed: _openEntryForm,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah catatan kegiatan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.maroon),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Jurnal tersimpan selama aplikasi demo terbuka.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.date,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InfoPill(
                label: entry.tag,
                color: AppColors.cream,
                textColor: AppColors.taupe,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            entry.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(entry.description),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.muted),
              const SizedBox(width: 5),
              Text(
                'Ditambahkan pukul ${entry.time}',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalFormSheet extends StatefulWidget {
  const _JournalFormSheet();

  @override
  State<_JournalFormSheet> createState() => _JournalFormSheetState();
}

class _JournalFormSheetState extends State<_JournalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _tag = 'Kegiatan';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: currentDateLabel(),
      time:
          '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}',
      tag: _tag,
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                Text(
                  'Tulis jurnal baru',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                const Text('Apa yang kamu kerjakan atau pelajari hari ini?'),
                const SizedBox(height: 19),
                const _FormLabel('JUDUL KEGIATAN'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Membuat halaman profil',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Judul kegiatan wajib diisi'
                          : null,
                ),
                const SizedBox(height: 15),
                const _FormLabel('CERITA KEGIATAN'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan ringkasan kegiatan dan hal yang kamu pelajari...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) =>
                      value == null || value.trim().length < 8
                          ? 'Ceritakan kegiatan minimal 8 karakter'
                          : null,
                ),
                const SizedBox(height: 15),
                const _FormLabel('KATEGORI'),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  value: _tag,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'Kegiatan', child: Text('Kegiatan')),
                    DropdownMenuItem(
                      value: 'Pembelajaran',
                      child: Text('Pembelajaran'),
                    ),
                    DropdownMenuItem(value: 'Orientasi', child: Text('Orientasi')),
                    DropdownMenuItem(value: 'Proyek', child: Text('Proyek')),
                  ],
                  onChanged: (value) =>
                      setState(() => _tag = value ?? 'Kegiatan'),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Simpan jurnal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}