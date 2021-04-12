import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/pages/findPost/resultScreen.dart';
import 'package:aircolis/utils/airportDataReader.dart';
import 'package:aircolis/utils/airportLookup.dart';
import 'package:aircolis/utils/airport_search_delegate.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/firstDisabledFocusNode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FindPostScreen extends StatefulWidget {
  @override
  _FindPostScreenState createState() => _FindPostScreenState();
}

class _FindPostScreenState extends State<FindPostScreen> {
  var departureCountryController = TextEditingController();
  var countryOfArrivalController = TextEditingController();
  var departureDate = TextEditingController();
  var departureDateText;
  AirportLookup airportLookup;
  Airport departure;
  Airport arrival;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    lookup();
    super.initState();
  }

  lookup() async {
    List<Airport> airports =
        await AirportDataReader.load('assets/airports.dat');
    airportLookup = AirportLookup(airports: airports);
  }

  @override
  Widget build(BuildContext context) {
    double height = space;

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context).translate("findATravel")}'),
      ),
      body: Container(
        margin: EdgeInsets.all(height),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: departureCountryController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('departure'),
                        hintText: AppLocalizations.of(context)
                            .translate('departure'),
                        errorText: null,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flight_takeoff)),
                    focusNode: FirstDisabledFocusNode(),
                    showCursor: false,
                    readOnly: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                      }
                      return null;
                    },
                    onTap: () async {
                      _selectDeparture(context);
                    },
                  ),
                  SizedBox(
                    height: height,
                  ),
                  TextFormField(
                    controller: countryOfArrivalController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('arrival'),
                        hintText: AppLocalizations.of(context)
                            .translate('arrival'),
                        errorText: null,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flight_land)),
                    focusNode: FirstDisabledFocusNode(),
                    showCursor: false,
                    readOnly: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                      }
                      return null;
                    },
                    onTap: () async {
                      _selectArrival(context);
                    },
                  ),
                  SizedBox(
                    height: height,
                  ),
                  TextFormField(
                    controller: departureDate,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('departureDate'),
                        hintText: AppLocalizations.of(context)
                            .translate('departureDate'),
                        errorText: null,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event)),
                    focusNode: FirstDisabledFocusNode(),
                    showCursor: false,
                    readOnly: true,
                    onTap: () {
                      var today = DateTime.now();
                      //var initialDate = today.add(const Duration(days: 2));
                      showDatePicker(
                              context: context,
                              initialDate: today,
                              firstDate: today,
                              lastDate: DateTime(2025))
                          .then((value) {
                        if (value != null) {
                          DateTime _fromDate = DateTime.now();
                          _fromDate = value;
                          final String date = DateFormat.yMMMd(
                                  '${AppLocalizations.of(context).locale}')
                              .format(_fromDate);
                          departureDate.text = date;
                          departureDateText =
                              DateFormat('yyyy-MM-dd').format(_fromDate);
                        }
                      });
                    },
                  ),
                  SizedBox(
                    height: height * 2,
                  ),
                  AirButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              departure: departure,
                              arrival: arrival,
                              departureDate: departureDateText,
                            ),
                          ),
                        );
                      }
                    },
                    text:
                        Text('${AppLocalizations.of(context).translate("search").toUpperCase()}'),
                    icon: Icons.search,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _selectDeparture(BuildContext context) async {
    final departureAirport = await _showSearch(context);
    departureCountryController.text = departureAirport.city;
    departure = departureAirport;
    //flightDetailsBloc.updateWith(departure: departure);
  }

  _selectArrival(BuildContext context) async {
    final arrivalAirport = await _showSearch(context);
    countryOfArrivalController.text = arrivalAirport.city;
    arrival = arrivalAirport;
    //flightDetailsBloc.updateWith(departure: departure);
  }

  Future<Airport> _showSearch(BuildContext context) async {
    return await showSearch<Airport>(
        context: context,
        delegate: AirportSearchDelegate(
          airportLookup: airportLookup,
        ));
  }
}
