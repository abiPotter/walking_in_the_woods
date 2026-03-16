import 'package:roam_and_report/enums/report_status.dart';

class ReportStatusConverter {
  static String reportStatusToString(ReportStatus status) {
    if (status == ReportStatus.Submitted) {
      return "Submitted";
    } else if (status == ReportStatus.InProgress) {
      return "In Progress";
    } else if (status == ReportStatus.Resolved) {
      return "Resolved";
    }
    return "";
  }

  static ReportStatus enumStringToReportStatus(String status) {
    if (status == "ReportStatus.Submitted") {
      return ReportStatus.Submitted;
    } else if (status == "ReportStatus.InProgress") {
      return ReportStatus.InProgress;
    } else if (status == "ReportStatus.Resolved") {
      return ReportStatus.Resolved;
    }
    return ReportStatus.Unknown;
  }

  static ReportStatus stringToReportStatus(String status) {
    if (status == "Submitted") {
      return ReportStatus.Submitted;
    } else if (status == "In Progress") {
      return ReportStatus.InProgress;
    } else if (status == "Resolved") {
      return ReportStatus.Resolved;
    }
    return ReportStatus.Unknown;
  }
}
