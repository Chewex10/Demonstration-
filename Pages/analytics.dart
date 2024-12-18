import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../components/service_request_provider.dart';

class AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final serviceRequests = Provider.of<ServiceRequestProvider>(context).serviceRequests;

    // Calculate statistics
    final completedRequests = serviceRequests.where((request) => request.status == 'Completed').length;
    final totalRequests = serviceRequests.length;
    final averageResponseTime = _calculateAverageResponseTime(serviceRequests);
    final categoryCounts = _calculateCategoryCounts(serviceRequests);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Analytics Dashboard",
          style: TextStyle(
            color: Color(0xFF64c2c4),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset(
            'lib/images/toolbox.png',  // Your custom image here
            height: 30,
            width: 30,
            color: Color(0xFF64c2c4),
          ),
          onPressed: () {
            print('Tools icon pressed');
          },
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              // Statistics Grid
              _buildStatisticCard(
                label: 'Total \nRequests',
                value: '$totalRequests',
                color: Colors.white,
                backgroundColor: Color(0xFF4CAF50),
              ),
              _buildStatisticCard(
                label: 'Completed Requests',
                value: '$completedRequests',
                color: Colors.white,
                backgroundColor: Color(0xFF2196F3),
              ),
              _buildStatisticCard(
                label: 'Avg Response Time',
                value: '${averageResponseTime.toStringAsFixed(2)} min',
                color: Colors.white,
                backgroundColor: Color(0xFFF57C00),
              ),

              // Categories Distribution Pie Chart
              StaggeredGridTile.fit(
                crossAxisCellCount: 2,
                child: _buildChartContainer(
                  title: 'Categories Distribution',
                  child: _buildPieChart(categoryCounts),
                  height: 200,
                ),
              ),

              // Requests Over Time Bar Chart
              StaggeredGridTile.fit(
                crossAxisCellCount: 2,
                child: _buildChartContainer(
                  title: 'Requests Over Time',
                  child: _buildBarChart(serviceRequests),
                  height: 300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String label,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer({
    required String title,
    required Widget child,
    required double height,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: height,
            child: child,
          ),
        ],
      ),
    );
  }

  double _calculateAverageResponseTime(List<ServiceRequest> requests) {
    if (requests.isEmpty) return 0;
    final now = DateTime.now();
    final totalMinutes = requests.fold<double>(0, (sum, request) {
      final requestTime = DateTime.parse(request.date);
      return sum + now.difference(requestTime).inMinutes.toDouble();
    });
    return totalMinutes / requests.length;
  }

  Map<String, int> _calculateCategoryCounts(List<ServiceRequest> requests) {
    final counts = <String, int>{};
    for (var request in requests) {
      counts[request.category] = (counts[request.category] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildPieChart(Map<String, int> categoryCounts) {
    final data = categoryCounts.entries.map((entry) {
      return PieChartData(
        category: entry.key,
        value: entry.value.toDouble(),
        color: _getColor(entry.key),
      );
    }).toList();

    return charts.PieChart(
      [
        charts.Series<PieChartData, String>(
          id: 'Categories',
          domainFn: (PieChartData data, _) => data.category,
          measureFn: (PieChartData data, _) => data.value,
          colorFn: (PieChartData data, _) => charts.ColorUtil.fromDartColor(data.color),
          data: data,
          labelAccessorFn: (PieChartData data, _) {
            final percentage = (data.value / categoryCounts.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1);
            return '${data.category}: $percentage%';
          },
        )
      ],
      animate: true,
      defaultRenderer: charts.ArcRendererConfig<String>(
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            insideLabelStyleSpec: charts.TextStyleSpec(fontSize: 8, color: charts.MaterialPalette.white),
            labelPosition: charts.ArcLabelPosition.inside,
          ),
        ],
        arcWidth: 60,
      ),
    );
  }

  Widget _buildBarChart(List<ServiceRequest> requests) {
    final requestCounts = <String, int>{};
    for (var request in requests) {
      final dateStr = request.date;
      requestCounts[dateStr] = (requestCounts[dateStr] ?? 0) + 1;
    }

    final data = requestCounts.entries.map((entry) {
      return BarChartData(
        date: entry.key,
        count: entry.value.toDouble(),
      );
    }).toList();

    return charts.BarChart(
      [
        charts.Series<BarChartData, String>(
          id: 'Requests',
          domainFn: (BarChartData data, _) => data.date,
          measureFn: (BarChartData data, _) => data.count,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Color(0xFF4CAF50)),
          data: data,
          labelAccessorFn: (BarChartData data, _) => data.count.toString(),
        )
      ],
      animate: true,
      defaultRenderer: charts.BarRendererConfig<String>(
        barRendererDecorator: charts.BarLabelDecorator<String>(
          insideLabelStyleSpec: charts.TextStyleSpec(color: charts.MaterialPalette.white),
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: charts.MaterialPalette.gray.shade200,
          ),
        ),
      ),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: charts.MaterialPalette.gray.shade700,
          ),
          labelStyle: charts.TextStyleSpec(
            color: charts.MaterialPalette.gray.shade700,
          ),
        ),
      ),
    );
  }

  Color _getColor(String category) {
    switch (category) {
      case 'Electrical':
        return Color(0xFF4CAF50);
      case 'Plumbing':
        return Colors.blueAccent;
      case 'IT Support':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class PieChartData {
  final String category;
  final double value;
  final Color color;

  PieChartData({
    required this.category,
    required this.value,
    required this.color,
  });
}

class BarChartData {
  final String date;
  final double count;

  BarChartData({
    required this.date,
    required this.count,
  });
}
