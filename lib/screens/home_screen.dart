import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flaviapp/models/migraine_entry.dart';
import 'package:flaviapp/services/database_helper.dart';
import 'package:flaviapp/screens/migraine_form.dart';
import 'package:flaviapp/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomeScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _datesWithEntries = {};
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDatesWithEntries();
    Intl.defaultLocale = 'es_ES';
  }

  void _loadDatesWithEntries() async {
    final dates = await DatabaseHelper.instance.getDatesWithEntries();
    setState(() {
      _datesWithEntries = dates.map((date) => DateTime.parse(date)).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF7C3AED),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(const Color(0xFF7C3AED)),
          trackColor: MaterialStateProperty.all(const Color(0xFFEDE9FE)),
        ),
        cardColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1F2937)),
          bodyMedium: TextStyle(color: Color(0xFF1F2937)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF7C3AED),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(const Color(0xFF7C3AED)),
          trackColor: MaterialStateProperty.all(const Color(0xFF4A4A4A)),
        ),
        cardColor: Colors.grey[850],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Migraña'),
          actions: [
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                widget.onThemeChanged(value);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.utc(2021, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: const CalendarStyle(
                    cellMargin: EdgeInsets.symmetric(vertical: 5),
                    markersMaxCount: 1,
                    markerDecoration: BoxDecoration(
                      color: Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF7C3AED),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFEDE9FE),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  eventLoader: (day) {
                    DateTime dayWithoutTime = DateTime(day.year, day.month, day.day);
                    return _datesWithEntries.any((entry) {
                      DateTime entryDateWithoutTime = DateTime(entry.year, entry.month, entry.day);
                      return entryDateWithoutTime.isAtSameMomentAs(dayWithoutTime);
                    }) ? [day] : [];
                  },
                ),
              ),
              Expanded(
                child: _selectedDay == null
                    ? Center(
                  child: Text(
                    'Seleccione una fecha',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                )
                    : FutureBuilder<MigraineEntry?>(
                  future: DatabaseHelper.instance.getEntryByDate(_selectedDay!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text(
                          'No hay registros para esta fecha',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      );
                    } else {
                      return _buildMigraineCard(snapshot.data!);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (_selectedDay != null) {
                  _showMigraineForm(_selectedDay!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, selecciona una fecha'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              backgroundColor: const Color(0xFF7C3AED),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                );
              },
              backgroundColor: const Color(0xFF7C3AED),
              child: const Icon(Icons.bar_chart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMigraineCard(MigraineEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoTile(
              icon: Icons.medication,
              label: 'Medicamento',
              value: entry.medication ?? 'Ninguno',
              color: (_isDarkMode ? Colors.grey[700] : const Color(0xFFEDE9FE)) ?? const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.warning_rounded,
              label: 'Desencadenante',
              value: entry.trigger ?? 'Ninguno',
              color: (_isDarkMode ? Colors.grey[700] : const Color(0xFFEDE9FE)) ?? const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.show_chart_rounded,
              label: 'Intensidad',
              value: entry.intensity ?? 'No especificada',
              color: (_isDarkMode ? Colors.grey[700] : const Color(0xFFEDE9FE)) ?? const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.note_rounded,
              label: 'Notas',
              value: entry.notes ?? 'Ninguna',
              color: (_isDarkMode ? Colors.grey[700] : const Color(0xFFEDE9FE)) ?? const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMigraineForm(DateTime selectedDay) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(selectedDay);
    final existingEntry = await DatabaseHelper.instance.getEntryByDate(DateTime.parse(formattedDate));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: MigraineForm(
            selectedDate: selectedDay,
            existingEntry: existingEntry,
            onSave: () {
              _loadDatesWithEntries();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}