import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _notes = StorageService.getAllNotes());
  }

  Future<void> _addOrEdit({Note? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    DateTime? reminder = existing?.reminderDate;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? 'Nueva nota' : 'Editar nota',
                    style: const TextStyle(color: AppTheme.neonCyan, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Contenido'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_outlined, color: AppTheme.neonOrange),
                    title: Text(
                      reminder == null
                          ? 'Sin recordatorio'
                          : 'Recordatorio: ${DateFormat('dd/MM/yyyy').format(reminder!)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: reminder != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.redAccent),
                            onPressed: () => setModal(() => reminder = null),
                          )
                        : null,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: reminder ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                        locale: const Locale('es', 'ES'),
                        builder: (c, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(primary: AppTheme.neonOrange, surface: AppTheme.cardBg),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) setModal(() => reminder = picked);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      Navigator.pop(ctx, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      final note = existing == null
          ? Note(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: titleCtrl.text.trim(),
              content: contentCtrl.text.trim(),
              createdAt: DateTime.now(),
              reminderDate: reminder,
            )
          : existing.copyWith(
              title: titleCtrl.text.trim(),
              content: contentCtrl.text.trim(),
              reminderDate: reminder,
            );
      await StorageService.saveNote(note);
      _load();
    }
  }

  Future<void> _delete(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Eliminar nota', style: TextStyle(color: AppTheme.neonCyan)),
        content: const Text('¿Seguro?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.deleteNote(note.id);
      _load();
    }
  }

  Future<void> _toggleComplete(Note note) async {
    final updated = note.copyWith(isCompleted: !note.isCompleted);
    await StorageService.saveNote(updated);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        backgroundColor: AppTheme.neonCyan,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text('No hay notas todavía', style: TextStyle(color: Colors.white38, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final n = _notes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppTheme.premiumCard(
                    borderColor: n.isCompleted ? Colors.green : AppTheme.neonCyan.withOpacity(0.4),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: IconButton(
                      icon: Icon(
                        n.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: n.isCompleted ? Colors.green : AppTheme.neonCyan,
                      ),
                      onPressed: () => _toggleComplete(n),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: n.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (n.content.isNotEmpty)
                          Text(n.content, style: const TextStyle(color: Colors.white60), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(n.createdAt),
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                        if (n.reminderDate != null)
                          Text(
                            '🔔 ${DateFormat('dd/MM/yyyy').format(n.reminderDate!)}',
                            style: const TextStyle(color: AppTheme.neonOrange, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.neonOrange, size: 20),
                          onPressed: () => _addOrEdit(existing: n),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _delete(n),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
