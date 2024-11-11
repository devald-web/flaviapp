import 'package:flutter/material.dart';
import 'package:flaviapp/models/migraine_entry.dart';
import 'package:flaviapp/services/database_helper.dart';

class MigraineForm extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onSave;
  final MigraineEntry? existingEntry;

  const MigraineForm({Key? key, required this.selectedDate, required this.onSave, this.existingEntry}) : super(key: key);

  @override
  _MigraineFormState createState() => _MigraineFormState();
}

class _MigraineFormState extends State<MigraineForm> {
  bool _hadMigraine = false;
  String? _medication;
  String? _trigger;
  String _intensity = 'Moderado';
  String? _notes;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _hadMigraine = widget.existingEntry!.hadMigraine;
      _medication = widget.existingEntry!.medication;
      _trigger = widget.existingEntry!.trigger;
      _intensity = widget.existingEntry!.intensity ?? 'Moderado';
      _notes = widget.existingEntry!.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Registro de Migraña',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildMigraineQuestion(),
            if (_hadMigraine) ...[
              const SizedBox(height: 16),
              _buildMedicationField(),
              const SizedBox(height: 16),
              _buildTriggerField(),
              const SizedBox(height: 16),
              _buildIntensitySelector(),
              const SizedBox(height: 16),
              _buildNotesField(),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveEntry,
              child: const Text('Guardar'),
            ),
            if (widget.existingEntry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deleteEntry,
                child: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMigraineQuestion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Has tenido migraña hoy?'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Sí'),
                    value: true,
                    groupValue: _hadMigraine,
                    onChanged: (value) => setState(() => _hadMigraine = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: _hadMigraine,
                    onChanged: (value) => setState(() => _hadMigraine = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '¿Tomaste medicamento? ¿Cuál fue?',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => _medication = value,
    );
  }

  Widget _buildTriggerField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '¿Cuál fue el desencadenante?',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => _trigger = value,
    );
  }

  Widget _buildIntensitySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Qué tan intenso fue?'),
            Wrap(
              spacing: 8.0,
              children: ['Moderado', 'Intenso', 'Insoportable'].map((
                  String intensity) {
                return ChoiceChip(
                  label: Text(intensity),
                  selected: _intensity == intensity,
                  onSelected: (bool selected) {
                    setState(() {
                      _intensity = intensity;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Notas adicionales',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => _notes = value,
    );
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate() && _hadMigraine) {
      final entry = MigraineEntry(
        date: widget.selectedDate,
        hadMigraine: _hadMigraine,
        medication: _medication,
        trigger: _trigger,
        intensity: _intensity,
        notes: _notes,
      );

      if (widget.existingEntry == null) {
        await DatabaseHelper.instance.insertEntry(entry);
      } else {
        print('Updating entry with id: $entry');
        await DatabaseHelper.instance.updateEntry(entry);
      }
      widget.onSave();
    }
  }

  void _deleteEntry() async {
    if (widget.existingEntry != null) {
      await DatabaseHelper.instance.deleteEntry(widget.existingEntry!.id ?? 0);
      widget.onSave();
    }
  }
}