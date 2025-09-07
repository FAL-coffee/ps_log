import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'record.dart';

/// 集計ページ
class StatisticsPage extends StatefulWidget {
  final List<Record> records;

  const StatisticsPage({super.key, required this.records});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('集計'),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'グラフ'),
            Tab(text: 'ランキング'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _GraphTab(records: widget.records),
          _RankingTab(records: widget.records),
        ],
      ),
    );
  }
}

enum Period { day, week, month, year }

class _GraphTab extends StatefulWidget {
  final List<Record> records;

  const _GraphTab({required this.records});

  @override
  State<_GraphTab> createState() => _GraphTabState();
}

class _GraphTabState extends State<_GraphTab> {
  Period _period = Period.day;

  Map<String, int> _aggregate(List<Record> records, Period p) {
    final Map<String, int> totals = {};
    for (final r in records) {
      final d = r.date;
      late String key;
      switch (p) {
        case Period.day:
          key = '${d.year}/${d.month}/${d.day}';
          break;
        case Period.week:
          final w = _weekNumber(d);
          key = '${d.year}-W$w';
          break;
        case Period.month:
          key = '${d.year}/${d.month}';
          break;
        case Period.year:
          key = d.year.toString();
          break;
      }
      totals[key] = (totals[key] ?? 0) + r.profit;
    }
    return totals;
  }

  int _weekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final firstMonday =
        firstDay.subtract(Duration(days: firstDay.weekday - DateTime.monday));
    final diff = date.difference(firstMonday).inDays;
    return diff ~/ 7 + 1;
  }

  @override
  Widget build(BuildContext context) {
    final totals = _aggregate(widget.records, _period);
    final keys = totals.keys.toList()..sort();

    Widget chart;
    if (keys.isEmpty) {
      chart = const Center(child: Text('データがありません'));
    } else {
      chart = BarChart(
        BarChartData(
          barGroups: List.generate(keys.length, (i) {
            final v = totals[keys[i]]!.toDouble();
            return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: v)]);
          }),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < keys.length) {
                    return Text(keys[idx]);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      );
    }

    String _label(Period p) {
      switch (p) {
        case Period.day:
          return '日';
        case Period.week:
          return '週';
        case Period.month:
          return '月';
        case Period.year:
          return '年';
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButton<Period>(
            value: _period,
            onChanged: (p) => setState(() => _period = p!),
            items: Period.values
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(_label(p)),
                    ))
                .toList(),
          ),
        ),
        Expanded(child: Padding(padding: const EdgeInsets.all(16), child: chart))
      ],
    );
  }
}

class _RankingTab extends StatelessWidget {
  final List<Record> records;

  const _RankingTab({required this.records});

  List<MapEntry<String, int>> _buildRanking(
      List<Record> list, String Function(Record) keySelector) {
    final Map<String, int> totals = {};
    for (final r in list) {
      final k = keySelector(r);
      totals[k] = (totals[k] ?? 0) + r.profit;
    }
    final entries = totals.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final hallRanking = _buildRanking(records, (r) => r.hall);
    final machineRanking = _buildRanking(records, (r) => r.machine);

    Widget _rankingList(List<MapEntry<String, int>> list) {
      return Column(
        children: List.generate(list.length, (i) {
          final e = list[i];
          return ListTile(
            leading: Text('${i + 1}'),
            title: Text(e.key),
            trailing: Text('${e.value}円'),
          );
        }),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('ホール別収支ランキング',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _rankingList(hallRanking),
        const SizedBox(height: 24),
        const Text('機種別収支ランキング',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _rankingList(machineRanking),
      ],
    );
  }
}

