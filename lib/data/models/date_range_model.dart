// Date Range Model
class DateRangeModel {
  final DateTime startDate;
  final DateTime endDate;

  DateRangeModel({required this.startDate, required this.endDate});

  // Get current month date range
  static DateRangeModel currentMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return DateRangeModel(startDate: firstDay, endDate: lastDay);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeModel &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
