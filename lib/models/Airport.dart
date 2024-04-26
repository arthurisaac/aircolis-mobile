class LocationCoordinate2D {
  LocationCoordinate2D({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;

  @override
  String toString() {
    return "($latitude, $longitude)";
  }
}

class Airport {
  Airport({
    required this.name,
    required this.city,
    required this.country,
    required this.iata,
    required this.icao,
    this.location,
  });
  //int airportID
  final String name;
  final String city;
  final String country;
  final String iata;
  final String icao;
  final LocationCoordinate2D? location;
  //final double altitude;
  //final double timezone;
  //final String dst;
  //final String tzDatabaseTimeZone;
  //final String type; // = "airport"
  //final String source; // = "OurAirports"

  factory Airport.fromLine(String line) {
    final components = line.split(",");
    if (components.length < 8) {
      return Airport(city: '', country: '', iata: '', icao: '', name: '');
    }
    String name = unescapeString(components[1]).toString();
    String city = unescapeString(components[2]).toString();
    String country = unescapeString(components[3]).toString();
    String iata = unescapeString(components[4]).toString();
    if (iata == '\\N') {
      // placeholder for missing iata code
      iata = "..";
    }
    String icao = unescapeString(components[5]).toString();
    try {
      double latitude = double.parse(unescapeString(components[6]).toString());
      double longitude = double.parse(unescapeString(components[7]).toString());
      final location =
          LocationCoordinate2D(latitude: latitude, longitude: longitude);
      return Airport(
        name: name,
        city: city,
        country: country,
        iata: iata,
        icao: icao,
        location: location,
      );
    } catch (e) {
      // sometimes, components[6] is a String and the lat-long are stored
      // at index 7 and 8
      double latitude = double.parse(unescapeString(components[7]).toString());
      double longitude = double.parse(unescapeString(components[8]).toString());
      final location =
          LocationCoordinate2D(latitude: latitude, longitude: longitude);
      return Airport(
        name: name,
        city: city,
        country: country,
        iata: iata,
        location: location,
        icao: icao,
      );
    }
  }
  // All fields are escaped with double quotes. This method deals with them
  static String? unescapeString(dynamic value) {
    if (value is String) {
      return value.replaceAll('"', '');
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['city'] = this.city;
    data['country'] = this.country;
    data['iata'] = this.iata;
    data['location'] = this.location.toString();
    return data;
  }

  @override
  String toString() {
    return "($iata, $icao) -> $name, $city, $country, ${location.toString()}";
  }
}
