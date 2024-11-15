import 'package:flutter/material.dart';
import 'package:flaviapp/services/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/migraine_entry.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchStatistics(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No data available.'));
                  } else {
                    final data = snapshot.data!;
                    print('DATOS: $data');
                    final mostUsedMedication =
                    _mostUsedMedication(data['medicationUsage']);
                    print('MEDICACIÓN MAS USADA: $mostUsedMedication');
                    final mostCommonIntensity =
                    _mostCommonIntensity(data['intensity']);
                    return ListView(
                      children: [
                          _buildPieChart(data['medicationUsage']),
                        _buildBarChart(data['intensity']),
                        ListTile(
                          title: Text('Most Used Medication'),
                          subtitle: Text(
                              '${mostUsedMedication.key}: ${mostUsedMedication.value} times'),
                        ),
                        ListTile(
                          title: Text('Most Common Intensity'),
                          subtitle: Text(
                              '${mostCommonIntensity.key}: ${mostCommonIntensity.value} times'),
                        ),
                      ],
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

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final entries = await DatabaseHelper.instance.getAllEntries();
    final medicationUsage = _calculateMedicationUsage(entries);
    final intensity = _calculateIntensity(entries);
    return {
      'medicationUsage': medicationUsage,
      'intensity': intensity,
    };
  }

  Map<String, double> _calculateMedicationUsage(List<MigraineEntry> entries) {
    final Map<String, double> medicationUsage = {};
    for (var entry in entries) {
      if (entry.medication != null) {
        medicationUsage.update(entry.medication!, (value) => value + 1,
            ifAbsent: () => 1);
      }
    }
    return medicationUsage;
  }

  Map<String, double> _calculateIntensity(List<MigraineEntry> entries) {
    final Map<String, double> intensity = {};
    for (var entry in entries) {
      if (entry.intensity != null) {
        intensity.update(entry.intensity!.toString(), (value) => value + 1,
            ifAbsent: () => 1);
      }
    }
    return intensity;
  }

  MapEntry<String, double> _mostUsedMedication(
      Map<String, double> medicationUsage) {
    return medicationUsage.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  MapEntry<String, double> _mostCommonIntensity(Map<String, double> intensity) {
    return intensity.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  Widget _buildPieChart(Map<String, double> data) {

    //return Text("sdsdsd");
    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: entry.key,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data) {
    return BarChart(
      BarChartData(
        barGroups: data.entries.map((entry) {
          int xValue;
          try {
            xValue = int.parse(entry.key);
          } catch (e) {
            xValue = 0; // or handle the error appropriately
          }
          return BarChartGroupData(
            x: xValue,
            barRods: [
              BarChartRodData(
                fromY: entry.value, toY: 0,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}