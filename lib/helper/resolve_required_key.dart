
class ResolveRequiredKey {
  /// Generate a function that resolves keys for the enclosed map and throws [MappingError] if the map does not contain the key
  static Function getClosure(Map<String, dynamic> data) {
    dynamic resolver(String key) {
      dynamic val = data[key];
      if (val == null) throw MappingError(key);
      return val;
    }

    return resolver;
  }

  /// Firebase stores "5.0" as "int 5" -> Need to convert to double
  static double dynamicToDouble(dynamic value) {
    switch (value.runtimeType) {
      case double:
        return value;
      case int:
        return value.toDouble();
      case String:
        return double.parse(value);
      default:
        throw ("${value.runtimeType} cant be converted to double");
    }
  }
}

class MappingError extends Error implements ArgumentError {
  final String key;

  MappingError(this.key);

  String toString() => (this.message);

  @override
  String get message => "MappingError: <$key> can not be null!";

  @override
  get invalidValue => null;

  @override
  String get name => key;
}
