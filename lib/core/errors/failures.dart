import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الاتصال بالخادم']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'حدث خطأ في جلب البيانات المحفوظة']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'فشلت عملية المصادقة']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'تأكد من الاتصال بالإنترنت']);
}

class DuplicateBookingFailure extends Failure {
  const DuplicateBookingFailure([super.message = 'هذا الموعد محجوز بالفعل! يرجى اختيار موعد آخر.']);
}
