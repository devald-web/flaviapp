import 'package:flutter/material.dart';
import 'package:flaviapp/services/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/migraine_entry.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, int> _medicationUsage = {};
  Map<String, int> _triggerUsage = {};

  // Definimos una paleta de colores más vibrantes y femeninos
  final List<Color> _customColors = [
    const Color(0xFFFF69B4), // Hot Pink
    const Color(0xFFFF1493), // Deep Pink
    const Color(0xFFFF98DC), // Rosa brillante
    const Color(0xFF9370DB), // Púrpura medio
    const Color(0xFFDA70D6), // Orquídea
    const Color(0xFFFF69B4), // Rosa intenso
    const Color(0xFFBA55D3), // Orquídea medio
    const Color(0xFFEE82EE), // Violeta
  ];

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    final entries = await DatabaseHelper.instance.getAllEntries();
    final medicationUsage = <String, int>{};
    final triggerUsage = <String, int>{};

    for (var entry in entries) {
      if (entry.medication != null) {
        medicationUsage[entry.medication!] = (medicationUsage[entry.medication!] ?? 0) + 1;
      }
      if (entry.trigger != null) {
        triggerUsage[entry.trigger!] = (triggerUsage[entry.trigger!] ?? 0) + 1;
      }
    }

    setState(() {
      _medicationUsage = medicationUsage;
      _triggerUsage = triggerUsage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFDF4F5),
        title: Text(
          'Mis Estadísticas',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7D6E83),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5),
              Color(0xFFFFF0FA),
            ],
          ),
        ),
        child: _medicationUsage.isEmpty && _triggerUsage.isEmpty
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5BEEC)),
          ),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de medicamentos
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicamentos Utilizados',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7D6E83),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _medicationUsage.entries.map((entry) {
                                final index = _medicationUsage.keys.toList().indexOf(entry.key);
                                return PieChartSectionData(
                                  value: entry.value.toDouble(),
                                  title: '${entry.key}\n${entry.value}',
                                  titleStyle: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  color: _customColors[index % _customColors.length],
                                  radius: 110,
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              centerSpaceColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sección de disparadores
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Factores Desencadenantes',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7D6E83),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _triggerUsage.values.fold(0, (max, value) => value > max ? value : max).toDouble(),
                              barGroups: _triggerUsage.entries.map((entry) {
                                final index = _triggerUsage.keys.toList().indexOf(entry.key);
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.toDouble(),
                                      color: _customColors[index % _customColors.length],
                                      width: 20,
                                      borderRadius: BorderRadius.circular(8),
                                      backDrawRodData: BackgroundBarChartRodData(
                                        show: true,
                                        toY: _triggerUsage.values.reduce((a, b) => a > b ? a : b).toDouble(),
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= _triggerUsage.length) return const Text('');
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _triggerUsage.keys.elementAt(value.toInt()),
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: const Color(0xFF7D6E83),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                    reservedSize: 44,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 35,
                                    interval: 1.0,
                                    getTitlesWidget: (value, meta) {
                                      // Solo mostrar números enteros
                                      if (value == value.roundToDouble()) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            value.toInt().toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: const Color(0xFF7D6E83),
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.15),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}