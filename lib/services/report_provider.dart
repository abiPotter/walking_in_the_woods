import 'package:flutter/material.dart';
import 'package:roam_and_report/enums/report_status.dart';
import 'package:roam_and_report/enums/vote_status.dart';
import 'package:roam_and_report/helpers/handle_reports.dart';
import 'package:roam_and_report/models/report_model.dart';
import 'package:roam_and_report/models/vote_result.dart';

class ReportProvider extends ChangeNotifier {
  List<ReportModel> _reports = [];
  List<ReportModel> get reports => _reports;

  //streams
  Stream<List<ReportModel>> getAllReports() {
    return HandleReports.getAllReportsStream(null, false, 'Date', null);
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

  //vote on report
  Future<VoteResult> voteReport(
    ReportModel report,
    String voteChoice,
    String userId,
  ) async {
    final votes = Map<String, String>.from(report.votes);

    VoteStatus canVote = VoteResult.canUserVote(votes, voteChoice, userId);

    // Pure logic decisions: cannot vote → return immediately
    if (canVote == VoteStatus.cannotVote) return VoteResult(false, false);

    // If needs confirmation, ViewModel returns a flag that UI should ask
    if (canVote == VoteStatus.needsConfirmation) {
      return VoteResult.needsConfirmation();
    }
    // Normal vote
    return voteOnReport(report, votes, voteChoice, userId);
  }

  Future<VoteResult> voteOnReportWithDifferentVote(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) {
    return HandleReports.voteOnReportWithDifferentVote(
      report,
      votes,
      voteChoice,
      userid,
    );
  }

  Future<VoteResult> voteOnReport(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) {
    return HandleReports.voteOnReport(report, votes, voteChoice, userid);
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
  static Color getReportColour(ReportModel report) {
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
}
