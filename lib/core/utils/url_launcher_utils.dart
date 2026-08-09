import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:field_time/core/constants/app_colors.dart';

class UrlLauncherUtils {
  /// Opens Google Maps with a location search query (e.g. stadium name & address).
  static Future<void> openGoogleMaps(BuildContext context, String query) async {
    if (query.trim().isEmpty) return;

    final encodedQuery = Uri.encodeComponent(query.trim());

    // Standard Google Maps web query URL
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
    );

    // Native geo scheme for mobile
    final geoUrl = Uri.parse('geo:0,0?q=$encodedQuery');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(geoUrl)) {
        await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      } else {
        final launched = await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && context.mounted) {
          _showFallbackSnackBar(context, query);
        }
      }
    } catch (_) {
      try {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      } catch (_) {
        if (context.mounted) {
          _showFallbackSnackBar(context, query);
        }
      }
    }
  }

  /// Initiates a phone call to the provided phone number.
  static Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('رقم الهاتف: $phoneNumber'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  static void _showFallbackSnackBar(BuildContext context, String query) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('موقع الملعب: $query'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
