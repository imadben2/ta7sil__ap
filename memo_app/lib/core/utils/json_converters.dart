import 'package:json_annotation/json_annotation.dart';

/// Converts a value to int, handling both String and num types
int? safeIntFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Converts a value to double, handling both String and num types
double? safeDoubleFromJson(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Converts a value to int with a default value
int safeIntFromJsonWithDefault(dynamic value, int defaultValue) {
  return safeIntFromJson(value) ?? defaultValue;
}

/// Converts a value to double with a default value
double safeDoubleFromJsonWithDefault(dynamic value, double defaultValue) {
  return safeDoubleFromJson(value) ?? defaultValue;
}

/// JsonConverter for safely parsing int from string or num
class SafeIntConverter implements JsonConverter<int, dynamic> {
  const SafeIntConverter();

  @override
  int fromJson(dynamic json) {
    if (json == null) return 0;
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json) ?? 0;
    return 0;
  }

  @override
  dynamic toJson(int object) => object;
}

/// JsonConverter for safely parsing nullable int from string or num
class SafeNullableIntConverter implements JsonConverter<int?, dynamic> {
  const SafeNullableIntConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}

/// JsonConverter for safely parsing double from string or num
class SafeDoubleConverter implements JsonConverter<double, dynamic> {
  const SafeDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0.0;
    if (json is double) return json;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0.0;
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

/// JsonConverter for safely parsing nullable double from string or num
class SafeNullableDoubleConverter implements JsonConverter<double?, dynamic> {
  const SafeNullableDoubleConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is double) return json;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(double? object) => object;
}
