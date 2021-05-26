import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:flutter/material.dart';

class AirIOSBottomNavigation extends StatefulWidget {
  const AirIOSBottomNavigation({Key key}) : super(key: key);

  @override
  _AirIOSBottomNavigationState createState() => _AirIOSBottomNavigationState();
}

class _AirIOSBottomNavigationState extends State<AirIOSBottomNavigation> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final rootWidgetsState = MyInheritedWidget.of(context).myState;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context).translate("home"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: AppLocalizations.of(context).translate("find"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: AppLocalizations.of(context).translate("post"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.padding),
          label: AppLocalizations.of(context).translate("parcel"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppLocalizations.of(context).translate("profile"),
        ),
      ],
      unselectedItemColor: Colors.black,
      unselectedLabelStyle: TextStyle(color: Colors.black),
      currentIndex: selectedIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      showUnselectedLabels: true,
      onTap: (index) {
          setState(() {
            selectedIndex = index;
            rootWidgetsState.setScreen(index);
          });
      },
    );
  }
}
