import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/confirmation.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneValidationScreen extends StatefulWidget {
  @override
  _PhoneValidationScreenState createState() => _PhoneValidationScreenState();
}

class _PhoneValidationScreenState extends State<PhoneValidationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var phoneNumberController = TextEditingController();
  var countryCodeController = TextEditingController();
  String completeNumber;
  String initCountry = 'FR';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${AppLocalizations.of(context).translate("confirmation")}'),
      ),
      body: Container(
        margin: EdgeInsets.all(space),
        padding: EdgeInsets.all(8),
        child: Stack(
          children: [
            SvgPicture.asset("images/bg.svg"),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 0.5,
              child: SvgPicture.asset(
                "images/enter_mobile.svg",
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.center,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: space),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: IntlPhoneField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)
                            .translate('phoneNumber'),
                        suffixIcon: Icon(
                          Icons.phone,
                        ),
                        border: InputBorder.none
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                        }
                        return null;
                      },
                      initialCountryCode: initCountry,
                      onChanged: (phone) {
                        completeNumber = phone.completeNumber;
                      },
                    ),
                  ),
                  SizedBox(height: space * 2),
                  AirButton(
                    onPressed: () {
                      if (completeNumber.isNotEmpty) {
                        Utils().showAlertDialog(context, "Confirmer",
                            "Nous enverrons un code unique à ce numéro", () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CodeConfirmationScreen(
                                    phoneNumber:
                                    '$completeNumber',
                                  )));
                            });
                      }
                    },
                    text: Text(
                      '${AppLocalizations.of(context).translate("continue").toUpperCase()}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
