import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final String id;
  final String fieldId;
  final String fieldName;
  final String fieldAddress;
  final String fieldImage;
  final String date;
  final String startTime;
  final String endTime;
  final double price;
  final String status; // 'confirmed', 'completed', 'cancelled'
  final String bookingCode;

  const BookingModel({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.fieldAddress,
    required this.fieldImage,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    required this.bookingCode,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      fieldName: json['field_name'] as String? ?? '',
      fieldAddress: json['field_address'] as String? ?? '',
      fieldImage: json['field_image'] as String? ?? '',
      date: json['booking_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'confirmed',
      bookingCode: json['booking_code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'field_name': fieldName,
      'field_address': fieldAddress,
      'field_image': fieldImage,
      'booking_date': date,
      'start_time': startTime,
      'end_time': endTime,
      'price': price,
      'status': status,
      'booking_code': bookingCode,
    };
  }

  BookingModel copyWith({
    String? id,
    String? fieldId,
    String? fieldName,
    String? fieldAddress,
    String? fieldImage,
    String? date,
    String? startTime,
    String? endTime,
    double? price,
    String? status,
    String? bookingCode,
  }) {
    return BookingModel(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      fieldAddress: fieldAddress ?? this.fieldAddress,
      fieldImage: fieldImage ?? this.fieldImage,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      status: status ?? this.status,
      bookingCode: bookingCode ?? this.bookingCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        fieldName,
        fieldAddress,
        fieldImage,
        date,
        startTime,
        endTime,
        price,
        status,
        bookingCode,
      ];
}
