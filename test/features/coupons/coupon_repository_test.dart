import 'package:flutter_test/flutter_test.dart';
import 'package:field_time/features/coupons/data/repositories/coupon_repository.dart';
import 'package:field_time/core/errors/failures.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:field_time/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.init();
  });

  late CouponRepository repository;

  setUp(() {
    repository = CouponRepository();
  });

  group('CouponRepository Unit Tests', () {
    test('getAllCoupons returns initial list of coupons', () async {
      final coupons = await repository.getAllCoupons();
      expect(coupons, isNotEmpty);
      expect(coupons.any((c) => c.code == 'FIELD20'), isTrue);
    });

    test('validateCoupon succeeds with valid code FIELD20', () async {
      final coupon = await repository.validateCoupon(
        code: 'FIELD20',
        bookingAmount: 350.0,
      );

      expect(coupon.code, equals('FIELD20'));
      expect(coupon.discountType, equals('percentage'));
      expect(coupon.discountValue, equals(20.0));
      expect(coupon.calculateDiscount(350.0), equals(70.0));
    });

    test('validateCoupon throws CouponFailure for non-existent coupon code', () async {
      expect(
        () async => await repository.validateCoupon(
          code: 'INVALID_CODE_99',
          bookingAmount: 300.0,
        ),
        throwsA(isA<CouponFailure>()),
      );
    });

    test('validateCoupon throws CouponFailure if booking amount is below minBookingAmount', () async {
      expect(
        () async => await repository.validateCoupon(
          code: 'OFFER50', // minBookingAmount: 200.0
          bookingAmount: 100.0,
        ),
        throwsA(isA<CouponFailure>()),
      );
    });

    test('createCoupon adds a new coupon and prevents duplicate codes', () async {
      final created = await repository.createCoupon(
        code: 'NEWTEST30',
        discountType: 'percentage',
        discountValue: 30.0,
        minBookingAmount: 150.0,
      );

      expect(created.code, equals('NEWTEST30'));
      expect(created.isActive, isTrue);

      expect(
        () async => await repository.createCoupon(
          code: 'NEWTEST30',
          discountType: 'percentage',
          discountValue: 30.0,
        ),
        throwsA(isA<CouponFailure>()),
      );
    });
  });
}
