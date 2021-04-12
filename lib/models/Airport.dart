import 'package:flutter/material.dart';

class LocationCoordinate2D {
  LocationCoordinate2D({this.latitude, this.longitude});
  final double latitude;
  final double longitude;

  @override
  String toString() {
    return "($latitude, $longitude)";
  }
}

class Airport{
  Airport({
    @required this.name,
    @required this.city,
    @required this.country,
    this.iata,
    this.icao,
    @required this.location,
  });
  //int airportID
  final String name;
  final String city;
  final String country;
  final String iata;
  final String icao;
  final LocationCoordinate2D location;
  //final double altitude;
  //final double timezone;
  //final String dst;
  //final String tzDatabaseTimeZone;
  //final String type; // = "airport"
  //final String source; // = "OurAirports"

  factory Airport.fromLine(String line) {
    final components = line.split(",");
    if (components.length < 8) {
      return null;
    }
    String name = unescapeString(components[1]);
    String city = unescapeString(components[2]);
    String country = unescapeString(components[3]);
    String iata = unescapeString(components[4]);
    if (iata == '\\N') { // placeholder for missing iata code
      iata = null;
    }
    String icao = unescapeString(components[5]);
    try {
      double latitude = double.parse(unescapeString(components[6]));
      double longitude = double.parse(unescapeString(components[7]));
      final location = LocationCoordinate2D(
          latitude: latitude, longitude: longitude);
      return Airport(
        name: name,
        city: city,
        country: country,
        iata: iata,
        icao: icao,
        location: location,
      );
    } catch (e) {
      try {
        // sometimes, components[6] is a String and the lat-long are stored
        // at index 7 and 8
        double latitude = double.parse(unescapeString(components[7]));
        double longitude = double.parse(unescapeString(components[8]));
        final location = LocationCoordinate2D(
            latitude: latitude, longitude: longitude);
        return Airport(
          name: name,
          city: city,
          country: country,
          iata: iata,
          location: location,
        );
      } catch (e) {
        print(e);
        return null;
      }
    }
  }
  // All fields are escaped with double quotes. This method deals with them
  static String unescapeString(dynamic value) {
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
