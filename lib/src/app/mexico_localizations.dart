import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

const appLocale = Locale('es', 'MX');

class MexicoMaterialLocalizations extends MaterialLocalizationEsMx {
  MexicoMaterialLocalizations({
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  static const delegate = _MexicoMaterialLocalizationsDelegate();

  static const delegates = <LocalizationsDelegate<Object>>[
    delegate,
    GlobalWidgetsLocalizations.delegate,
    MexicoCupertinoLocalizations.delegate,
  ];

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.h_colon_mm_space_a;

  @override
  String get anteMeridiemAbbreviation => 'a. m.';

  @override
  String get postMeridiemAbbreviation => 'p. m.';

  @override
  String get okButtonLabel => 'Aceptar';
}

class _MexicoMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MexicoMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'es';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    await GlobalMaterialLocalizations.delegate.load(appLocale);
    const name = 'es_MX';
    return MexicoMaterialLocalizations(
      fullYearFormat: intl.DateFormat.y(name),
      compactDateFormat: intl.DateFormat.yMd(name),
      shortDateFormat: intl.DateFormat.yMMMd(name),
      mediumDateFormat: intl.DateFormat.MMMEd(name),
      longDateFormat: intl.DateFormat.yMMMMEEEEd(name),
      yearMonthFormat: intl.DateFormat.yMMMM(name),
      shortMonthDayFormat: intl.DateFormat.MMMd(name),
      decimalFormat: intl.NumberFormat.decimalPattern(name),
      twoDigitZeroPaddedFormat: intl.NumberFormat('00', name),
    );
  }

  @override
  bool shouldReload(_MexicoMaterialLocalizationsDelegate old) => false;
}

class MexicoCupertinoLocalizations extends CupertinoLocalizationEsMx {
  MexicoCupertinoLocalizations({
    required super.fullYearFormat,
    required super.dayFormat,
    required super.weekdayFormat,
    required super.mediumDateFormat,
    required super.singleDigitHourFormat,
    required super.singleDigitMinuteFormat,
    required super.doubleDigitMinuteFormat,
    required super.singleDigitSecondFormat,
    required super.decimalFormat,
  });

  static const delegate = _MexicoCupertinoLocalizationsDelegate();

  @override
  String get anteMeridiemAbbreviation => 'a. m.';

  @override
  String get postMeridiemAbbreviation => 'p. m.';
}

class _MexicoCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _MexicoCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'es';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    await GlobalCupertinoLocalizations.delegate.load(appLocale);
    const name = 'es_MX';
    return MexicoCupertinoLocalizations(
      fullYearFormat: intl.DateFormat.y(name),
      dayFormat: intl.DateFormat.d(name),
      weekdayFormat: intl.DateFormat.E(name),
      mediumDateFormat: intl.DateFormat.MMMEd(name),
      singleDigitHourFormat: intl.DateFormat('HH', name),
      singleDigitMinuteFormat: intl.DateFormat.m(name),
      doubleDigitMinuteFormat: intl.DateFormat('mm', name),
      singleDigitSecondFormat: intl.DateFormat.s(name),
      decimalFormat: intl.NumberFormat.decimalPattern(name),
    );
  }

  @override
  bool shouldReload(_MexicoCupertinoLocalizationsDelegate old) => false;
}
