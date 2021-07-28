import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/confirmation.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool loading = false;
  bool errorState = false;
  String errorDescription;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print(size.height);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: space, right: space, bottom: space),
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).translate("phoneNumber")}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline4
                            .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          '${AppLocalizations.of(context).translate("enterYourPhoneNumberToContinue")}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .copyWith(color: Colors.black38)),
                    ],
                  ),
                ),
                SizedBox(
                  height: space * 2,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (size.height < 680.0)
                          ? Container()
                          : SvgPicture.asset("images/enter_mobile.svg"),
                      (size.height < 680.0)
                          ? SizedBox(height: space)
                          : SizedBox(height: space * 3),
                      Container(
                        //padding: EdgeInsets.all(8),
                        //decoration: BoxDecoration(
                            // border: Border.all(color: Colors.black45, width: 1),
                            // borderRadius: BorderRadius.circular(padding),
                            //),
                        child: IntlPhoneField(
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('phoneNumber'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(padding),
                            ),
                            counterText: "",
                          ),
                          searchText: "Nom du pays",
                          initialCountryCode: initCountry,
                          showDropdownIcon: false,
                          onChanged: (phone) {
                            completeNumber = phone.completeNumber;
                            setState(() {
                              errorState = true;
                              errorDescription = "";
                            });
                          },
                        ),
                      ),
                      SizedBox(height: space),
                      AirButton(
                        onPressed: !loading
                            ? () {
                                if (completeNumber != null &&
                                    completeNumber.isNotEmpty) {
                                  verifyPhoneNumberExistInDB();
                                } else {
                                  Utils.showSnack(context,
                                      "${AppLocalizations.of(context).translate("thePhoneNumberIsRequired")}");
                                }
                              }
                            : null,
                        text: Text(
                          !loading
                              ? '${AppLocalizations.of(context).translate("continue")}'
                              : '${AppLocalizations.of(context).translate("loading")}',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04),
                        ),
                        iconColor: !loading
                            ? Theme.of(context).primaryColorLight
                            : Colors.black45,
                      ),
                      errorState
                          ? Container(
                              margin: EdgeInsets.only(top: space),
                              child: Text(
                                '$errorDescription',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  verifyPhoneNumberExistInDB() async {
    setState(() {
      loading = true;
      errorState = false;
      errorDescription = "";
    });

    await FirebaseAuth.instance.signInAnonymously();
    AuthService().checkPhoneExistInDB(completeNumber).then((value) async {
      print(value.docs.length);
      setState(() {
        loading = false;
      });
      await FirebaseAuth.instance.signOut();
      if (value.docs.length > 0) {
        setState(() {
          errorState = true;
          errorDescription =
              "${AppLocalizations.of(context).translate("thisPhoneNumberExistsInTheDatabase")}";
        });
      } else {
        setState(() {
          errorState = false;
          errorDescription = "";
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CodeConfirmationScreen(
              phoneNumber: '$completeNumber',
            ),
          ),
        );
      }
    }).catchError((onError) {
      print(onError.toString());
      Utils.showSnack(context, onError.toString());
      setState(() {
        loading = false;
        errorState = true;
        errorDescription = onError.toString();
      });
    });
  }
}
