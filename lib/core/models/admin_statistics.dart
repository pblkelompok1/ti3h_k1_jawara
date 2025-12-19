class AdminStatistics {
  final int totalResidents;
  final int activeUsers;
  final int pendingRegistrations;
  final int newReportsToday;
  final int pendingLetters;

  AdminStatistics({
    required this.totalResidents,
    required this.activeUsers,
    required this.pendingRegistrations,
    required this.newReportsToday,
    required this.pendingLetters,
  });

  factory AdminStatistics.fromJson(Map<String, dynamic> json) {
    return AdminStatistics(
      totalResidents: json['totalResidents'] as int,
      activeUsers: json['activeUsers'] as int,
      pendingRegistrations: json['pendingRegistrations'] as int,
      newReportsToday: json['newReportsToday'] as int,
      pendingLetters: json['pendingLetters'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalResidents': totalResidents,
      'activeUsers': activeUsers,
      'pendingRegistrations': pendingRegistrations,
      'newReportsToday': newReportsToday,
      'pendingLetters': pendingLetters,
    };
  }
}
