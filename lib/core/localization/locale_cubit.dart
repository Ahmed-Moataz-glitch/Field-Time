import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_time/core/localization/locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState.initial());

  void setLocale(Locale locale) {
    if (state.locale != locale) {
      emit(LocaleState(locale));
    }
  }

  void changeLanguage(String languageCode) {
    setLocale(Locale(languageCode));
  }

  void toggleLanguage() {
    if (state.isArabic) {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ar'));
    }
  }
}
