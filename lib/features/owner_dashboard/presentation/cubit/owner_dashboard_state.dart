import 'package:equatable/equatable.dart';
import 'package:field_time/features/booking/data/models/booking_model.dart';
import 'package:field_time/features/home/data/models/field_model.dart';
import 'package:field_time/features/owner_dashboard/data/models/owner_stats_model.dart';

abstract class OwnerDashboardState extends Equatable {
  const OwnerDashboardState();

  @override
  List<Object?> get props => [];
}

class OwnerDashboardInitial extends OwnerDashboardState {}

class OwnerDashboardLoading extends OwnerDashboardState {}

class OwnerDashboardLoaded extends OwnerDashboardState {
  final List<FieldModel> fields;
  final List<BookingModel> bookings;
  final OwnerStatsModel stats;

  const OwnerDashboardLoaded({
    required this.fields,
    required this.bookings,
    required this.stats,
  });

  OwnerDashboardLoaded copyWith({
    List<FieldModel>? fields,
    List<BookingModel>? bookings,
    OwnerStatsModel? stats,
  }) {
    return OwnerDashboardLoaded(
      fields: fields ?? this.fields,
      bookings: bookings ?? this.bookings,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [fields, bookings, stats];
}

class OwnerDashboardError extends OwnerDashboardState {
  final String message;

  const OwnerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class OwnerOperationSuccess extends OwnerDashboardState {
  final String message;

  const OwnerOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
