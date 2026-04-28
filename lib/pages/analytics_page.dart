import 'package:flutter/material.dart';
import 'package:roam_and_report/helpers/handle_reports.dart';
import 'package:roam_and_report/layout/main_layout.dart';
import 'package:roam_and_report/models/graphs/report_dates.dart';
import 'package:roam_and_report/models/graphs/report_descriptions.dart';
import 'package:roam_and_report/models/graphs/report_severities.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  "Report Analytics",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 12),
              const Text(
                "All of these analytics are across the previous 30 days",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              const Text(
                "Daily Found Reports:",
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 5),
              const Text(
                "The following line graph shows the number of reports being found each day across the whole country.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              FutureBuilder<List<ReportDates>>(
                future: HandleReports().getReportsLast30Days(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return showReportDateLineChart(snapshot.data!);
                },
              ),
              SizedBox(height: 10),
              const Text(
                "Total severities:",
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 5),
              const Text(
                "The following bar chart shows the number of active reports for each severity level (1-10).",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              FutureBuilder<List<ReportSeverities>>(
                future: HandleReports().getReportSeverityCounts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return showSeverityBarChart(snapshot.data!);
                },
              ),
              SizedBox(height: 10),
              const Text(
                "Description count:",
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                ),
              ),

              SizedBox(height: 5),
              const Text(
                "The following pie chart shows the number of reports for each problem description.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              SizedBox(
                height: 550,
                child: FutureBuilder<List<ReportDescriptions>>(
                  future: HandleReports().getReportDescriptions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return showDescriptionPieChart(snapshot.data!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ReportSeverities> getReportDates() {
    List<ReportSeverities> data = [
      ReportSeverities(severity: 1, totalReports: 12),
      ReportSeverities(severity: 2, totalReports: 18),
      ReportSeverities(severity: 3, totalReports: 9),
      ReportSeverities(severity: 4, totalReports: 15),
    ];

    return data;
  }

  SfCartesianChart showReportDateLineChart(List<ReportDates> data) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Total Reports Per Day'),
      tooltipBehavior: TooltipBehavior(enable: true),

      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        interval: 5,
        title: AxisTitle(text: 'Date'),
      ),
      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Number of Reports')),

      series: <CartesianSeries>[
        LineSeries<ReportDates, DateTime>(
          name: 'Total Reports',
          dataSource: data,
          xValueMapper: (ReportDates d, _) => d.date,
          yValueMapper: (ReportDates d, _) => d.totalReports,
        ),
      ],
    );
  }

  SfCartesianChart showSeverityBarChart(List<ReportSeverities> data) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Reports by Severity'),
      tooltipBehavior: TooltipBehavior(enable: true),

      primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Severity')),
      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Number of Reports')),

      series: <CartesianSeries>[
        ColumnSeries<ReportSeverities, int>(
          name: 'Severity',
          dataSource: data,
          xValueMapper: (ReportSeverities d, _) => d.severity,
          yValueMapper: (ReportSeverities d, _) => d.totalReports,

          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  SfCircularChart showDescriptionPieChart(List<ReportDescriptions> data) {
    return SfCircularChart(
      title: ChartTitle(text: 'Reports by Description'),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
      ),

      series: <CircularSeries>[
        PieSeries<ReportDescriptions, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.description,
          yValueMapper: (d, _) => d.totalReports,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          explode: true,
          explodeIndex: 0,
        ),
      ],
    );
  }
}
