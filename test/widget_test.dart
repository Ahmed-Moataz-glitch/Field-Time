import 'package:flutter_test/flutter_test.dart';
import 'package:field_time/main.dart';
import 'package:field_time/core/utils/get_it.dart';
import 'package:field_time/app/router/app_router.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:field_time/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await SupabaseService.init();
    await setupGetIt();
    await AppRouter.initializeRouter();
  });

  testWidgets('App renders test', (WidgetTester tester) async {
    await tester.pumpWidget(const FieldTimeApp());
    expect(find.byType(FieldTimeApp), findsOneWidget);
  });
}
