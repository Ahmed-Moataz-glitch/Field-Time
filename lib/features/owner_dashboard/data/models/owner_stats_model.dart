import 'package:equatable/equatable.dart';

class RevenueDataPoint extends Equatable {
  final String month;
  final double revenue;

  const RevenueDataPoint({
    required this.month,
    required this.revenue,
  });

  @override
  List<Object?> get props => [month, revenue];
}

class OwnerStatsModel extends Equatable {
  final double totalEarnings;
  final int totalBookings;
  final int activeFieldsCount;
  final double occupancyRate;
  final List<RevenueDataPoint> monthlyRevenue;

  const OwnerStatsModel({
    required this.totalEarnings,
    required this.totalBookings,
    required this.activeFieldsCount,
    required this.occupancyRate,
    required this.monthlyRevenue,
  });

  factory OwnerStatsModel.fromJson(Map<String, dynamic> json) {
    return OwnerStatsModel(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      totalBookings: json['total_bookings'] as int? ?? 0,
      activeFieldsCount: json['active_fields_count'] as int? ?? 0,
      occupancyRate: (json['occupancy_rate'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthly_revenue'] as List<dynamic>?)
              ?.map((item) => RevenueDataPoint(
                    month: item['month'] as String? ?? '',
                    revenue: (item['revenue'] as num?)?.toDouble() ?? 0.0,
                  ))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        totalEarnings,
        totalBookings,
        activeFieldsCount,
        occupancyRate,
        monthlyRevenue,
      ];
}
