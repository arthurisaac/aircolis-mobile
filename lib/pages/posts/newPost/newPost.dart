import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/posts/newPost/postForm.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStep.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getUserDoc(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null && snapshot.data['isVerified']) {
            return PostFormScreen();
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                margin: EdgeInsets.all(space),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("images/icons/unverified.svg", width: MediaQuery.of(context).size.height * 0.2,),
                      SizedBox(
                        height: space * 2,
                      ),
                      Text(
                        "${AppLocalizations.of(context).translate("yourAccountHasNotBeenVerified")}",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: space * 2,
                      ),
                      AirButton(
                        text:
                        Text('${AppLocalizations.of(context).translate("confirmAccount").toUpperCase()}'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => VerifyAccountStep(),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: space,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        if (snapshot.hasError) {
          return SomethingWentWrong(description: snapshot.error.toString(),);
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
