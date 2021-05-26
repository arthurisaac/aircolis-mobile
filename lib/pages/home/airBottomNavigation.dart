import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';

class AirBottomNavigation extends StatefulWidget {
  const AirBottomNavigation({Key key}) : super(key: key);

  @override
  _AirBottomNavigationState createState() => _AirBottomNavigationState();
}

class _AirBottomNavigationState extends State<AirBottomNavigation> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final rootWidgetsState = MyInheritedWidget.of(context).myState;
    //var size = MediaQuery.of(context).size;

    return FFNavigationBar(
      theme: FFNavigationBarTheme(
        barBackgroundColor: Colors.white,
        selectedItemBorderColor: Colors.white,
        selectedItemBackgroundColor: Theme.of(context).primaryColor,
        selectedItemIconColor: Colors.white,
        selectedItemLabelColor: Colors.black,
        showSelectedItemShadow: true,
        barHeight: 70,
        //unselectedItemTextStyle: TextStyle(fontSize: fontSize),
        selectedItemTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      selectedIndex: selectedIndex,
      onSelectTab: (index) {
        setState(() {
          rootWidgetsState.setScreen(index);
          selectedIndex = index;
        });
      },
      items: [
        FFNavigationBarItem(
          iconData: Icons.home,
          label: AppLocalizations.of(context).translate("home"),
        ),
        FFNavigationBarItem(
          iconData: Icons.search,
          label: AppLocalizations.of(context).translate("find"),
        ),
        FFNavigationBarItem(
          iconData: Icons.add,
          label: AppLocalizations.of(context).translate("post"),
        ),
        FFNavigationBarItem(
          iconData: Icons.padding,
          label: AppLocalizations.of(context).translate("parcel"),
        ),
        FFNavigationBarItem(
          iconData: Icons.person,
          label: AppLocalizations.of(context).translate("profile"),
        ),
      ],
    );
  }
}
