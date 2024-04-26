import 'package:aircolis/pages/alertes/alertePost.dart';
import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/auth/loginPopup.dart';
import 'package:aircolis/pages/others/about.dart';
import 'package:aircolis/pages/others/contactez_nous.dart';
import 'package:aircolis/pages/user/updateProfile/updateProfile.dart';
import 'package:aircolis/services/postService.dart';
import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBack;

  const ProfileScreen({Key? key, this.showBack = true}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  late Future future;
  double totalRating = 0.0;
  int totalTrip = 0;
  int totalParcel = 0;

  @override
  void initState() {
    future = userCollection.doc(currentUser!.uid).get();

    getTotalParcel();
    getTotalRating();
    super.initState();
  }

  getTotalRating() async {
    var posts = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: currentUser!.uid)
        .get();

    double totalRate = 0;
    var totalProposal = 0;
    //print("Nombre de posts ${posts.docs.length}");
    setState(() {
      totalTrip = posts.docs.length;
    });

    await Future.wait(posts.docs.map((post) async {
      var proposals = await FirebaseFirestore.instance
          .collection('proposals')
          .where('post', isEqualTo: post.id)
          .get();

      //print("Nombre de colis pris ${proposals.docs.length}");
      await Future.wait(proposals.docs.map((proposal) {
        if (proposal.get("rating") != 0) {
          totalProposal = totalProposal + 1;
        }
        totalRate = totalRate + proposal.get("rating");
        return Future.delayed(const Duration());
      }));
    }));

    if (totalProposal > 0) {
      setState(() {
        totalRating = totalRate / totalProposal;
      });
    }
  }

  void getTotalParcel() {
    PostService().getAcceptedTravelCount().then((value) {
      setState(() {
        totalParcel = value.length;
      });
    });
  }

  Widget profileName(Map<String, dynamic> data) {
    print(data);
    var size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(space),
      child: Row(
        children: [
          widget.showBack ? Container() : SizedBox(height: space),
          Container(
            child: StorageService().getPhoto(
                context,
                (data.containsKey("firstname") && data['firstname'] != null)
                    ? data['firstname'][0]
                    : "!",
                data.containsKey("photo")
                    ? data['photo'].toString()
                    : 'https://ui-avatars.com/api/?name=${data['firstname']}',
                size.width * 0.08,
                size.width * 0.1),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: space),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (data.containsKey("lastname") && data['lastname'] != null)
                      ? Text(
                          '${data['lastname'].toString().toUpperCase()}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline5!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                        )
                      : Text("Non précisé"),
                  SizedBox(
                    height: space / 3,
                  ),
                  (data.containsKey("firstname") && data['firstname'] != null)
                      ? Text(
                          '${data['firstname'].toString().toUpperCase()}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              ?.copyWith(color: Colors.black),
                        )
                      : Text("Non précisé"),
                  SizedBox(
                    height: space / 3,
                  ),
                  data.containsKey("email")
                      ? Text(
                          '${data['email'].toString().toLowerCase()}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyText1
                              ?.copyWith(color: Colors.black),
                        )
                      : Text("Please add an email"),
                  /*Text(
                                '${data['phone']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal
                                ),
                              )*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileStat() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.translate("rating").toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("${totalRating.toStringAsFixed(0)}"),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.translate("trip").toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("$totalTrip"),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.translate("parcel").toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("$totalParcel"),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (currentUser == null || currentUser!.isAnonymous)
        ? LoginPopupScreen(showBack: false)
        : Scaffold(
            appBar: widget.showBack
                ? AppBar(
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
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                  )
                : AppBar(
                    elevation: 0,
                    toolbarHeight: 0,
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                  ),
            backgroundColor: Colors.white,
            body: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data.data();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.showBack
                                  ? Container()
                                  : SizedBox(
                                      height: space,
                                    ),
                              (data.isNotEmpty)
                                  ? profileName(data)
                                  : Container(),
                              SizedBox(
                                height: space,
                              ),
                              profileStat(),
                              SizedBox(
                                height: space,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(space),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => UpdateProfile()));
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(vertical: space),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate("editPersonalInformation")
                                        .toString(),
                                  ),
                                ),
                              ),
                              /*
                              Divider(
                                height: 1,
                                color: Theme.of(context).accentColor,
                              ),
                              InkWell(
                                onTap: () {
                                  showCupertinoModalBottomSheet(
                                    context: context,
                                    builder: (context) => WalletScreen(),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: space),
                                  width: double.infinity,
                                  child: Text(
                                    "${AppLocalizations.of(context)!.translate("requestAWithdrawal")}",
                                  ),
                                ),
                              ),*/
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              InkWell(
                                onTap: () {
                                  showCupertinoModalBottomSheet(
                                    context: context,
                                    builder: (context) => About(),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      EdgeInsets.symmetric(vertical: space),
                                  child: Text(
                                    "${AppLocalizations.of(context)!.translate("aboutTheApp")}",
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              InkWell(
                                onTap: () {
                                  Share.share(
                                      'Une superbe application à te faire découvrir: Aircolis qui met en relation voyageurs et expéditeur de colis. A télécharger sur Google Play et App Store',
                                      subject: 'Aircolis');
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(vertical: space),
                                  child: Container(
                                    width: double.infinity,
                                    child: Text(
                                      "${AppLocalizations.of(context)!.translate("recommendTheApp")}",
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              /*InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => CurrentTasks()));
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(vertical: space),
                                  child: Container(
                                    width: double.infinity,
                                    child: Text(
                                      "${AppLocalizations.of(context)!.translate("trackMyParcels")}",
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).accentColor,
                              ),*/
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AlertePost()));
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(vertical: space),
                                  child: Container(
                                    width: double.infinity,
                                    child: Text(
                                      "Créer une alerte",
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ContactezNousScreen()));
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      vertical: space, horizontal: 5),
                                  child: Text(
                                    "Contactez-nous",
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              InkWell(
                                onTap: () {
                                  FirebaseAuth.instance.signOut().then((value) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      vertical: space, horizontal: 5),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate("logout")
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}'),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          );
  }
}
