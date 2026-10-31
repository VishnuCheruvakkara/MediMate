import 'package:flutter/material.dart';

String formatFeverDateTime(BuildContext context, DateTime date) {
  final time = TimeOfDay.fromDateTime(date).format(context);
  return '${date.day}/${date.month}/${date.year} · $time';
}

String formatMeasurementMethod(String method) => switch (method) {
  'oral' => 'Oral measurement',
  'axillary' => 'Underarm measurement',
  'tympanic' => 'Ear measurement',
  'temporal' => 'Forehead measurement',
  'rectal' => 'Rectal measurement',
  _ => 'Other measurement',
};
