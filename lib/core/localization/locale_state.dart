import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState(this.locale);

  factory LocaleState.initial() => const LocaleState(Locale('ar'));

  bool get isArabic => locale.languageCode == 'ar';

  @override
  List<Object?> get props => [locale];
}
