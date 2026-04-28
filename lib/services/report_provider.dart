import 'package:flutter/material.dart';
import 'package:roam_and_report/enums/report_status.dart';
import 'package:roam_and_report/helpers/handle_reports.dart';
import 'package:roam_and_report/models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  List<ReportModel> _reports = [];
  List<ReportModel> get reports => _reports;

  //streams
  Stream<List<ReportModel>> getAllReports() {
    return HandleReports.getAllReportsStream(null, false, 'All', null);
  }

  Stream<List<ReportModel>> getSpecificReports(
    String? userId,
    bool filterByStatus,
    String? filter,
    String? location,
  ) {
    return HandleReports.getAllReportsStream(
      userId,
      filterByStatus,
      filter,
      location,
    );
  }

  void voteOnReportWithDifferentVote(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) {
    HandleReports.voteOnReportWithDifferentVote(
      report,
      votes,
      voteChoice,
      userid,
    );
  }

  void voteOnReport(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) {
    return HandleReports.voteOnReport(report, votes, voteChoice, userid);
  }

  void removeVoteOnReport(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) {
    HandleReports.removeVoteOnReport(report, votes, voteChoice, userid);
  }

  //Change status
  static void updateReportStatus(ReportModel report, String newStatus) {
    HandleReports.updateStatus(report, newStatus);
  }

  //Delete report
  static void deleteReport(String id) {
    HandleReports.deleteReport(id);
  }

  //Utility
  static Color getReportColour1(ReportModel report) {
    ReportStatus status = report.status;
    if (status == ReportStatus.Submitted) {
      return Colors.red.shade200;
    } else if (status == ReportStatus.InProgress) {
      return Colors.amber.shade200;
    } else if (status == ReportStatus.Resolved) {
      return Colors.green.shade200;
    }
    return Colors.white;
  }

  static Color getReportColour(ReportModel report) {
    if (report.severity.length > 2 || int.parse(report.severity) == 0) {
      return Colors.purple.shade200;
    }

    List<Color> severityColours = [
      Colors.green.shade300,
      Colors.lightGreen.shade300,
      Colors.lime.shade300,
      Colors.yellow.shade300,
      Colors.amber.shade300,
      Colors.orange.shade300,
      Colors.deepOrange.shade300,
      Colors.red.shade300,
      Colors.red.shade400,
      Colors.red.shade500,
    ];

    return severityColours[int.parse(report.severity) - 1];
  }
}
