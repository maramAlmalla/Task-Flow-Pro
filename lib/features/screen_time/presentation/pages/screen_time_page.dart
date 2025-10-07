import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class ScreenTimePage extends StatefulWidget {
  const ScreenTimePage({super.key});

  @override
  State<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends State<ScreenTimePage> with WidgetsBindingObserver {
  Duration _todayDuration = Duration.zero;
  DateTime? _sessionStart;
  Timer? _updateTimer;
  Map<int, Duration> _weeklyData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startSession();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateSession());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _endSession();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _endSession();
    } else if (state == AppLifecycleState.resumed) {
      _startSession();
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = _getDateKey(today);
    
    final todaySeconds = prefs.getInt('screen_time_$todayKey') ?? 0;
    
    final weeklyData = <int, Duration>{};
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = _getDateKey(date);
      final seconds = prefs.getInt('screen_time_$key') ?? 0;
      weeklyData[6 - i] = Duration(seconds: seconds);
    }
    
    setState(() {
      _todayDuration = Duration(seconds: todaySeconds);
      _weeklyData = weeklyData;
    });
  }

  String _getDateKey(DateTime date) {
    return '${date.year}_${date.month}_${date.day}';
  }

  void _startSession() {
    _sessionStart = DateTime.now();
  }

  void _endSession() async {
    if (_sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!);
      _todayDuration += duration;
      await _saveData();
      _sessionStart = null;
    }
  }

  void _updateSession() {
    if (_sessionStart != null) {
      setState(() {});
    }
  }

  Duration get _currentSessionDuration {
    if (_sessionStart == null) return Duration.zero;
    return DateTime.now().difference(_sessionStart!);
  }

  Duration get _totalToday => _todayDuration + _currentSessionDuration;

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getDateKey(DateTime.now());
    await prefs.setInt('screen_time_$todayKey', _todayDuration.inSeconds);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Time'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.phone_android, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_totalToday),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last 7 Days',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(),
                        barGroups: _weeklyData.entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.inMinutes.toDouble(),
                                color: Colors.blue,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}m',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: true),
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
    );
  }

  double _getMaxY() {
    if (_weeklyData.isEmpty) return 60;
    final max = _weeklyData.values.map((d) => d.inMinutes).reduce((a, b) => a > b ? a : b);
    return (max + 10).toDouble();
  }
}
