import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test Amount Conversion in German Locale ...', () async {
    String amountToTest = "12,3";

    double doubleAmount = Tour.toLocalDecimalAmount(
        amountToTest, const Locale.fromSubtags(languageCode: "de"));
    expect(doubleAmount, 12.3);

    Tour tour = Tour(
        amount: doubleAmount, polyline: [], duration: const Duration(days: 1));

    String actualAmount =
        tour.getLocalAmountString(const Locale.fromSubtags(languageCode: "de"));
    expect(actualAmount, amountToTest);

    Map<String, dynamic> tourJson = tour.toJson();
    expect(tourJson['amount'], doubleAmount);
  });

  test('Test Amount Conversion in English Locale ...', () async {
    String amountToTest = "12.3";

    double doubleAmount = Tour.toLocalDecimalAmount(
        amountToTest, const Locale.fromSubtags(languageCode: "en"));
    expect(doubleAmount, 12.3);

    Tour tour = Tour(
        amount: doubleAmount, polyline: [], duration: const Duration(days: 1));

    String actualAmount =
        tour.getLocalAmountString(const Locale.fromSubtags(languageCode: "en"));
    expect(actualAmount, amountToTest);

    Map<String, dynamic> tourJson = tour.toJson();
    expect(tourJson['amount'], doubleAmount);
  });

  test('Throw Exception on invalid Amount Conversion ...', () async {
    String amountToTest = "12,a3";

    expect(
        () => Tour.toLocalDecimalAmount(
            amountToTest, const Locale.fromSubtags(languageCode: "en")),
        throwsA(const TypeMatcher<FormatException>()));
  });
}
