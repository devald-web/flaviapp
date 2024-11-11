import 'package:flaviapp/models/migraine_entry.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flaviapp/screens/migraine_form.dart';
import 'package:flaviapp/services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _datesWithEntries = {};

  @override
  void initState() {
    super.initState();
    _loadDatesWithEntries();
  }

  void _loadDatesWithEntries() async {
    final dates = await DatabaseHelper.instance.getDatesWithEntries();
    setState(() {
      _datesWithEntries = dates.map((date) => DateTime.parse(date)).toSet();
    });
    print('Dates with entries: $_datesWithEntries');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showMigraineForm(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                print('Event loader for day: $day');
                DateTime dayWithoutTime = DateTime(day.year, day.month, day.day);
                return _datesWithEntries.any((entry) {
                  DateTime entryDateWithoutTime = DateTime(entry.year, entry.month, entry.day);
                  return entryDateWithoutTime.isAtSameMomentAs(dayWithoutTime);
                }) ? [day] : [];
              },
            ),
            Expanded(
              child: _selectedDay == null
                  ? Center(child: Text('Select a date to see the entry.'))
                  : FutureBuilder<MigraineEntry?>(
                future: DatabaseHelper.instance.getEntryByDate(_selectedDay!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No entry for this date.'));
                  } else {
                    final entry = snapshot.data!;
                    return ListTile(
                      title: Text(entry.date.toIso8601String().split('T')[0]),
                      subtitle: Text(entry.hadMigraine ? 'Sí' : 'No'),
                      onTap: () => _showMigraineForm(entry.date),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMigraineForm(DateTime selectedDay) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(selectedDay);
    print('Selected date: $formattedDate');
    final existingEntry = await DatabaseHelper.instance.getEntryByDate(DateTime.parse(formattedDate));
    if (existingEntry != null) {
      print('Existing entry: ${existingEntry.toMap()}');
    } else {
      print('No existing entry for date: $formattedDate');
    }
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