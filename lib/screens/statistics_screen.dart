import 'package:flutter/material.dart';
import 'package:flaviapp/services/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/migraine_entry.dart';
import '../screens/home_screen.dart';

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
                    return ListView(
                      children: [
                        _buildPieChart(data['medicationUsage']),
                        _buildBarChart(data['intensity']),
                        // Add more charts as needed
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
    return {
      'medicationUsage': _processMedicationUsage(entries),
      'intensity': _processIntensity(entries),
    };
  }

  Map<String, double> _processMedicationUsage(List<MigraineEntry> entries) {
    // Implementation
    return {};
  }

  Map<String, double> _processIntensity(List<MigraineEntry> entries) {
    // Implementation
    return {};
  }

  Widget _buildPieChart(Map<String, double> data) {
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
          return BarChartGroupData(
            x: int.parse(entry.key),
            barRods: [
              BarChartRodData(
                y: entry.value,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
