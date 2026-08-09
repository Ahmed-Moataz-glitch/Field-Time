import 'package:field_time/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pay_with_paymob/pay_with_paymob.dart';

abstract class PaymobService {
  static const String apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRFNU5qWTJOU3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5wbXNnX3FXaFVidzQ2WENvWlB5YW5STFctRXBnUkc1bkVVSGVsYXh1bk5YaDFrRFU4N1BVaGN5RGp1SmFaQjNuT29MM0k4OXUyN2h6VWE3bVFtMUJYdw==';
  static const String iframeId = '1060054';
  static const String integrationCardId = '5775400';
  static const String integrationWalletId = '5807371';

  static void initializePayment() async {
    PaymentData.initialize(
      apiKey:
          apiKey, // Required: Found under Dashboard -> Settings -> Account Info -> API Key
      iframeId: iframeId, // Required: Found under Developers -> iframes
      integrationCardId:
          integrationCardId, // Required: Found under Developers -> Payment Integrations -> Online Card ID
      integrationMobileWalletId:
          integrationWalletId, // Required: Found under Developers -> Payment Integrations -> Mobile Wallet ID
      // Optional User Data
      userData: UserData(
        email: "NA", // Optional: Defaults to 'NA'
        phone: "NA", // Optional: Defaults to 'NA'
        name: "NA", // Optional: Defaults to 'NA'
        lastName: "NA", // Optional: Defaults to 'NA'
      ),

      // Optional Style Customizations
      style: Style(
        primaryColor: AppColors.primary, // Default: Colors.blue
        scaffoldColor: AppColors.backgroundLight, // Default: Colors.white
        appBarBackgroundColor: AppColors.primary, // Default: Colors.blue
        appBarForegroundColor: AppColors.backgroundLight, // Default: Colors.white
        textStyle: TextStyle(), // Default: TextStyle()
        buttonStyle:
            ElevatedButton.styleFrom(), // Default: ElevatedButton.styleFrom()
        circleProgressColor: AppColors.primary, // Default: Colors.blue
        unselectedColor: AppColors.greyBorder, // Default: Colors.grey
      ),
    );
  }
}
