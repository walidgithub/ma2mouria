class MemberReportResponse{
  String receiptId;
  String receiptDate;
  String receiptDetail;
  String receiptMemberId;
  String name;
  String shareValue;
  bool shared;
  String receiptLink;
  MemberReportResponse({required this.receiptId, required this.receiptMemberId, required this.name, required this.shareValue, required this.receiptDate, required this.receiptDetail, required this.receiptLink, required this.shared});
}