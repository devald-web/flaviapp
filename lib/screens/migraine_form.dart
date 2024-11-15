import 'package:flutter/material.dart';
import 'package:flaviapp/models/migraine_entry.dart';
import 'package:flaviapp/services/database_helper.dart';

class MigraineForm extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onSave;
  final MigraineEntry? existingEntry;

  const MigraineForm(
      {Key? key,
      required this.selectedDate,
      required this.onSave,
      this.existingEntry})
      : super(key: key);

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

  final List<String> _medications = [
    'Ibuprofeno',
    'Paracetamol',
    'Sumatriptán',
    'Dorixina Relax',
    'Migradorixina'
  ];

  final List<String> _triggers = [
    'Estrés',
    'Chocolate',
    'Alimento procesado',
    'Cafeína',
    'Alcohol',
    'Cambios hormonales',
    'Alteraciones en el sueño',
    'Deshidratación',
    'Cambios en el clima',
    'Luces brillantes',
    'Olores fuertes'
  ];

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
            const Text(
              'Registro de Migraña',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.existingEntry == null ? 'Guardar' : 'Actualizar',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            if (widget.existingEntry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deleteEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Eliminar',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMigraineQuestion() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEDE9FE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Has tenido migraña hoy?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Sí'),
                    value: true,
                    groupValue: _hadMigraine,
                    onChanged: (value) => setState(() => _hadMigraine = value!),
                    activeColor: const Color(0xFF7C3AED),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: _hadMigraine,
                    onChanged: (value) => setState(() => _hadMigraine = value!),
                    activeColor: const Color(0xFF7C3AED),
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
    return DropdownButtonFormField<String>(
      value: _medication,
      decoration: InputDecoration(
        labelText: '¿Tomaste medicamento? ¿Cuál fue?',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDE9FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDE9FE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED)),
        ),
      ),
      items: _medications.map((medication) {
        return DropdownMenuItem(
          value: medication,
          child: Text(medication),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _medication = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona un medicamento';
        }
        return null;
      },
    );
  }

  Widget _buildTriggerField() {
    return DropdownButtonFormField<String>(
      value: _trigger,
      decoration: InputDecoration(
        labelText: '¿Cuál fue el desencadenante?',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDE9FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDE9FE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED)),
        ),
      ),
      items: _triggers.map((trigger) {
        return DropdownMenuItem(
          value: trigger,
          child: Text(trigger),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _trigger = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona un desencadenante';
        }
        return null;
      },
    );
  }

  Widget _buildIntensitySelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEDE9FE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué tan intenso fue?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: ['Moderado', 'Intenso', 'Insoportable']
                  .map((String intensity) {
                return ChoiceChip(
                  label: Text(intensity),
                  selected: _intensity == intensity,
                  onSelected: (bool selected) {
                    setState(() {
                      _intensity = intensity;
                    });
                  },
                  selectedColor: const Color(0xFF7C3AED),
                  labelStyle: TextStyle(
                    color: _intensity == intensity
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
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
      decoration: InputDecoration(
        labelText: 'Notas adicionales',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDE9FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEDE9FE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED)),
        ),
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
        entry.id = widget.existingEntry!.id;
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
