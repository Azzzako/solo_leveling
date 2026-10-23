import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../utils/dates.dart';

bool usesCupertino(BuildContext context) =>
    Theme.of(context).platform == TargetPlatform.iOS;

Future<TimeOfDay?> pickTime(
  BuildContext context, {
  required TimeOfDay initial,
  required String title,
}) async {
  if (!usesCupertino(context)) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      helpText: title,
    );
  }
  final picked = await _showWheel(
    context,
    title: title,
    initial: DateTime(2000, 1, 1, initial.hour, initial.minute),
    mode: CupertinoDatePickerMode.time,
  );
  return picked == null
      ? null
      : TimeOfDay(hour: picked.hour, minute: picked.minute);
}

Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
  required String title,
}) async {
  final start = dateOnly(first);
  final end = dateOnly(last);
  var value = dateOnly(initial);
  if (value.isBefore(start)) value = start;
  if (value.isAfter(end)) value = end;
  if (!usesCupertino(context)) {
    return showDatePicker(
      context: context,
      initialDate: value,
      firstDate: start,
      lastDate: end,
      helpText: title,
    );
  }
  final picked = await _showWheel(
    context,
    title: title,
    initial: value,
    mode: CupertinoDatePickerMode.date,
    minimum: start,
    maximum: end,
  );
  return picked == null ? null : dateOnly(picked);
}

Future<DateTime?> _showWheel(
  BuildContext context, {
  required String title,
  required DateTime initial,
  required CupertinoDatePickerMode mode,
  DateTime? minimum,
  DateTime? maximum,
}) {
  var selected = initial;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => Material(
      color: AppColors.panel,
      child: SizedBox(
        height: 320,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context, selected),
                    child: Text(
                      'Listo',
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.systemGlow,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: AppTypography.body.copyWith(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: mode,
                    use24hFormat: false,
                    initialDateTime: initial,
                    minimumDate: minimum,
                    maximumDate: maximum,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
