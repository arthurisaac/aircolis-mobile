import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/pages/posts/newPost/summaryPost.dart';
import 'package:aircolis/utils/airportDataReader.dart';
import 'package:aircolis/utils/airportLookup.dart';
import 'package:aircolis/utils/airport_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/firstDisabledFocusNode.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostFormScreen extends StatefulWidget {
  @override
  _PostFormScreenState createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  AirportLookup airportLookup;
  int _currentStep = 0;

  lookup() async {
    List<Airport> airports =
        await AirportDataReader.load('assets/airports.dat');
    airportLookup = AirportLookup(airports: airports);
    setState(() {
      airportLookup = AirportLookup(airports: airports);
    });
  }

  Future<Airport> _showSearch(BuildContext context) async {
    return await showSearch<Airport>(
      context: context,
      delegate: AirportSearchDelegate(
        airportLookup: airportLookup,
      ),
    );
  }

  @override
  void initState() {
    lookup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).translate("postAnAd"), style: TextStyle(color: Colors.black),),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: Stepper(
          steps: _stepper(),
          currentStep: _currentStep,
          physics: ClampingScrollPhysics(),
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          onStepContinue: () {
            setState(() {
              if (_currentStep < _stepper().length - 1) {
                if (_formKey[_currentStep].currentState.validate()) {
                  _currentStep = _currentStep + 1;
                }
              } else {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => SummaryPost(
                      departureDate: departureDateText,
                      departureTime: departureTime.text,
                      arrivingDate: arrivingDateText,
                      arrivingTime: arrivingTime.text,
                      departure: departure,
                      arrival: arrival,
                      notice: notice.text,
                      parcelHeight: parcelHeight.text,
                      parcelLength: parcelLength.text,
                      parcelWeight: parcelWeight.text,
                      price: price.text,
                      currency: dropdownValue,
                      paymentMethod: paymentMethod.text),
                );
              }
            });
          },
          onStepCancel: () {
            setState(() {
              if (_currentStep > 0) {
                _currentStep = _currentStep - 1;
              } else {
                _currentStep = 0;
              }
            });
          },
        ),
      ),
    );
  }

  List<Step> _stepper() {
    List<Step> _steps = [
      Step(
          title: Text('1'),
          content: Form(
            //key: _departureFormKey,
            key: _formKey[0],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: space),
                TextFormField(
                  controller: departureController,
                  keyboardType: TextInputType.text,
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('start'),
                    hintText: AppLocalizations.of(context).translate('start'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                  onTap: () {
                    _selectDeparture(context);
                  },
                ),
                SizedBox(
                  height: space / 2,
                ),
                TextFormField(
                  controller: departureDate,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('departureDate'),
                    hintText:
                        AppLocalizations.of(context).translate('departureDate'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                  onTap: () {
                    var today = DateTime.now();
                    var initialDate = today.add(const Duration(days: 2));
                    showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: initialDate,
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
                  height: space / 2,
                ),
                TextFormField(
                  controller: departureTime,
                  keyboardType: TextInputType.text,
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('departureTime'),
                    hintText:
                        AppLocalizations.of(context).translate('departureTime'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                  onTap: () {
                    final DateTime now = DateTime.now();
                    showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay(hour: now.hour, minute: now.minute),
                    ).then((value) {
                      if (value != null) {
                        departureTime.text = value.format(context);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 0,
          state: StepState.complete),
      Step(
          title: Text('2'),
          content: Form(
            //key: _arrivalFormKey,
            key: _formKey[1],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: arrivalController,
                  keyboardType: TextInputType.text,
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('arrival'),
                    hintText: AppLocalizations.of(context).translate('arrival'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                  onTap: () {
                    _selectArrival(context);
                  },
                ),
                SizedBox(
                  height: space / 2,
                ),
                SizedBox(
                  height: space / 2,
                ),
                TextFormField(
                  controller: arrivingDate,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('arrivingDate'),
                    hintText:
                        AppLocalizations.of(context).translate('arrivingDate'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                  onTap: () {
                    var today = DateTime.now();
                    var initialDate = today.add(const Duration(days: 2));
                    showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: initialDate,
                            lastDate: DateTime(2025))
                        .then((value) {
                      if (value != null) {
                        DateTime _fromDate = DateTime.now();
                        _fromDate = value;
                        final String date = DateFormat.yMMMd(
                                '${AppLocalizations.of(context).locale}')
                            .format(_fromDate);
                        arrivingDate.text = date;
                        arrivingDateText =
                            DateFormat('yyyy-MM-dd').format(_fromDate);
                      }
                    });
                  },
                ),
                SizedBox(
                  height: space / 2,
                ),
                TextFormField(
                  controller: arrivingTime,
                  keyboardType: TextInputType.text,
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('arrivingTime'),
                    hintText:
                        AppLocalizations.of(context).translate('arrivingTime'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                  onTap: () {
                    final DateTime now = DateTime.now();
                    showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay(hour: now.hour, minute: now.minute),
                    ).then((value) {
                      if (value != null) {
                        arrivingTime.text = value.format(context);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 1,
          state: StepState.editing),
      Step(
          title: Text('3'),
          content: Form(
            //key: _infoFormKey,
            key: _formKey[2],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: parcelLength,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('parcelLength'),
                    hintText:
                        AppLocalizations.of(context).translate('parcelLength'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Valeur incorrecte'; // TODO
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: space / 2,
                ),
                TextFormField(
                  controller: parcelHeight,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('parcelHeight'),
                    hintText:
                        AppLocalizations.of(context).translate('parcelHeight'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Valeur incorrecte';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: space / 2,
                ),
                TextFormField(
                  controller: parcelWeight,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('parcelWeight'),
                    hintText:
                        AppLocalizations.of(context).translate('parcelWeight'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Valeur incorrecte'; // TODO
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: space / 2,
                ),
                TextFormField(
                  controller: notice,
                  keyboardType: TextInputType.multiline,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('notice'),
                    hintText: AppLocalizations.of(context).translate('notice'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 2,
          state: StepState.disabled),
      Step(
          title: Text('4'),
          content: Form(
            //key: _paymentFormKey,
            key: _formKey[3],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: space),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: price,
                        style: TextStyle(fontSize: space),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).translate('price'),
                          hintText:
                              AppLocalizations.of(context).translate('price'),
                          errorText: null,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                          }
                          if (double.parse(value) < 0) {
                            return 'Valeur incorrecte'; // TODO
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(4)),
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        //style: TextStyle(color: Theme.of(context).primaryColor),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                        items: <String>['euro', 'dollar', 'CFA']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: space,
                ),
                TextFormField(
                  controller: paymentMethod,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('paymentMethod'),
                    hintText:
                        AppLocalizations.of(context).translate('paymentMethod'),
                    errorText: null,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 3,
          state: StepState.disabled),
    ];
    return _steps;
  }

  /// ------------
  /// Departure
  /// --------------
  final List<GlobalKey<FormState>> _formKey = [
    GlobalKey<FormState>(debugLabel: '_departureFormKey'),
    GlobalKey<FormState>(debugLabel: '_arrivalFormKey'),
    GlobalKey<FormState>(debugLabel: '_infoFormKey'),
    GlobalKey<FormState>(debugLabel: '_paymentFormKey')
  ];

  //List<GlobalKey<FormState>> _formKey = List.generate(4, (index) => GlobalObjectKey<FormState>(index));

  // Controllers departure
  TextEditingController departureController = TextEditingController();
  TextEditingController departureDate = TextEditingController();
  TextEditingController departureTime = TextEditingController();

  // Departure
  String departureDateText;
  Airport departure;

  _selectDeparture(BuildContext context) async {
    if (airportLookup != null) {
      final departureAirport = await _showSearch(context);
      departureController.text = departureAirport.city;
      departure = departureAirport;
    } else {
      print(airportLookup);
    }

  }

  /// ---------------
  /// Arrival
  /// ---------------

  // Controllers arrival
  TextEditingController arrivingDate = TextEditingController();
  TextEditingController arrivingTime = TextEditingController();
  TextEditingController arrivalController = TextEditingController();

  //final _formKey = GlobalKey<FormState>();
  Airport arrival;
  String arrivingDateText;

  // arrival
  _selectArrival(BuildContext context) async {
    final departureAirport = await _showSearch(context);
    arrivalController.text = departureAirport.city;
    arrival = departureAirport;
  }

  /// ---------------
  /// Additional Info
  /// ---------------

  // Controllers info
  TextEditingController notice = TextEditingController();
  TextEditingController parcelLength = TextEditingController();
  TextEditingController parcelWeight = TextEditingController();
  TextEditingController parcelHeight = TextEditingController();

  /// ---------------
  /// Additional Info
  /// ---------------

  // Controllers info
  final TextEditingController price = TextEditingController();
  final TextEditingController paymentMethod = TextEditingController();

  // payment
  String dropdownValue = 'euro';
}
