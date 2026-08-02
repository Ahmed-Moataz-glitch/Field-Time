import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final String id;
  final String fieldId;
  final String? userId;
  final String fieldName;
  final String fieldAddress;
  final String fieldImage;
  final String date;
  final String startTime;
  final String endTime;
  final double price; // Final total price after discounts
  final double originalPrice;
  final double discountAmount;
  final String? couponCode;
  final String status; // 'confirmed', 'completed', 'cancelled'
  final String bookingCode;

  const BookingModel({
    required this.id,
    required this.fieldId,
    this.userId,
    required this.fieldName,
    required this.fieldAddress,
    required this.fieldImage,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    double? originalPrice,
    this.discountAmount = 0.0,
    this.couponCode,
    required this.status,
    required this.bookingCode,
  }) : originalPrice = originalPrice ?? price;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final fieldMap = json['football_fields'] as Map<String, dynamic>?;
    final double totalPrice = (json['total_price'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final double origPrice = (json['original_price'] as num?)?.toDouble() ?? totalPrice;

    return BookingModel(
      id: json['id'] as String? ?? '',
      fieldId: json['field_id'] as String? ?? '',
      userId: json['user_id'] as String?,
      fieldName: fieldMap?['name'] as String? ?? json['field_name'] as String? ?? '',
      fieldAddress: fieldMap?['address'] as String? ?? json['field_address'] as String? ?? '',
      fieldImage: fieldMap?['main_image'] as String? ?? json['field_image'] as String? ?? '',
      date: json['booking_date'] as String? ?? json['date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      price: totalPrice,
      originalPrice: origPrice,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['coupon_code'] as String?,
      status: json['status'] as String? ?? 'confirmed',
      bookingCode: json['booking_code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      if (userId != null) 'user_id': userId,
      'booking_date': date,
      'start_time': startTime,
      'end_time': endTime,
      'total_price': price,
      'original_price': originalPrice,
      'discount_amount': discountAmount,
      if (couponCode != null && couponCode!.isNotEmpty) 'coupon_code': couponCode,
      'status': status,
      'booking_code': bookingCode,
    };
  }

  BookingModel copyWith({
    String? id,
    String? fieldId,
    String? userId,
    String? fieldName,
    String? fieldAddress,
    String? fieldImage,
    String? date,
    String? startTime,
    String? endTime,
    double? price,
    double? originalPrice,
    double? discountAmount,
    String? couponCode,
    String? status,
    String? bookingCode,
  }) {
    return BookingModel(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      userId: userId ?? this.userId,
      fieldName: fieldName ?? this.fieldName,
      fieldAddress: fieldAddress ?? this.fieldAddress,
      fieldImage: fieldImage ?? this.fieldImage,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      couponCode: couponCode ?? this.couponCode,
      status: status ?? this.status,
      bookingCode: bookingCode ?? this.bookingCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        userId,
        fieldName,
        fieldAddress,
        fieldImage,
        date,
        startTime,
        endTime,
        price,
        originalPrice,
        discountAmount,
        couponCode,
        status,
        bookingCode,
      ];
}
