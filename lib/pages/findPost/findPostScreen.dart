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
import 'package:flutter/services.dart';
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
  late AirportLookup airportLookup;
  Airport? departure;
  Airport? arrival;
  final _formKey = GlobalKey<FormState>();
  late FocusScopeNode currentFocus;

  @override
  void initState() {
    lookup();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      currentFocus = FocusScope.of(context);
    });
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

    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: space),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                        left: space, top: space, right: space * 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.translate("findATravel")}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline5
                              ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.translate("findPeopleTravelingOnTheRightDate")}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyText1
                              ?.copyWith(color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(space),
                    child: Column(
                      children: [
                        SizedBox(
                          height: space / 2,
                        ),
                        TextFormField(
                          controller: departureCountryController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: "Ville de départ",
                              hintText: AppLocalizations.of(context)!
                                  .translate('departure'),
                              errorText: null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(padding),
                              ),
                              prefixIcon: Icon(Icons.flight_takeoff)),
                          focusNode: FirstDisabledFocusNode(),
                          showCursor: false,
                          readOnly: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                            }
                            return null;
                          },
                          onTap: () async {
                            _selectDeparture(context);
                          },
                        ),
                        SizedBox(
                          height: height / 2,
                        ),
                        TextFormField(
                          controller: countryOfArrivalController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: "Ville d'arrivée",
                              hintText: AppLocalizations.of(context)!
                                  .translate('arrival'),
                              errorText: null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(padding),
                              ),
                              prefixIcon: Icon(Icons.flight_land)),
                          focusNode: FirstDisabledFocusNode(),
                          showCursor: false,
                          readOnly: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                            }
                            return null;
                          },
                          onTap: () async {
                            _selectArrival(context);
                          },
                        ),
                        SizedBox(
                          height: height / 2,
                        ),
                        TextFormField(
                          controller: departureDate,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .translate('departureDate'),
                              hintText: AppLocalizations.of(context)!
                                  .translate('departureDate'),
                              errorText: null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(padding),
                              ),
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
                                        '${AppLocalizations.of(context)!.locale}')
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
                            if (_formKey.currentState!.validate()) {
                              if (arrival != null &&
                                  departure != null &&
                                  departure != departure) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SearchResultScreen(
                                      departure: departure!,
                                      arrival: arrival!,
                                      departureDate: departureDateText,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          text: Text(
                            '${AppLocalizations.of(context)!.translate("search")}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                          ),
                          icon: Icons.search,
                        )
                      ],
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

  _selectDeparture(BuildContext context) async {
    final departureAirport = await _showSearch(context);
    if (departureAirport != null) {
      departureCountryController.text = departureAirport.city;
      departure = departureAirport;
    }
  }

  _selectArrival(BuildContext context) async {
    final arrivalAirport = await _showSearch(context);
    if (arrivalAirport != null) {
      countryOfArrivalController.text = arrivalAirport.city;
      arrival = arrivalAirport;
    }
  }

  Future<Airport?> _showSearch(BuildContext context) async {
    return await showSearch<Airport>(
        context: context,
        delegate: AirportSearchDelegate(
          airportLookup: airportLookup,
        ));
  }
}
