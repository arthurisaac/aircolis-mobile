import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:flutter/material.dart';

import 'airportLookup.dart';

class AirportSearchDelegate extends SearchDelegate<Airport> {
  AirportSearchDelegate({@required this.airportLookup});
  final AirportLookup airportLookup;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: '${AppLocalizations.of(context).translate("Retour")}',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildMatchingSuggestions(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildMatchingSuggestions(context);
  }

  Widget buildMatchingSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    final searched = airportLookup.searchString(query);
    if (searched.length == 0) {
      return AirportSearchPlaceholder(title: '${AppLocalizations.of(context).translate("noResult")}');
    }

    return ListView.builder(
      itemCount: searched.length,
      itemBuilder: (context, index) {
        return AirportSearchResultTile(
          airport: searched[index],
          searchDelegate: this,
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isEmpty
        ? []
        : <Widget>[
            IconButton(
              tooltip: 'Effacer',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
          ];
  }

  @override
  String get searchFieldLabel => "Rechercher la ville";
}

class AirportSearchPlaceholder extends StatelessWidget {
  AirportSearchPlaceholder({@required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Text(
        title,
        style: theme.textTheme.headline5,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AirportSearchResultTile extends StatelessWidget {
  const AirportSearchResultTile({@required this.airport, @required this.searchDelegate});

  final Airport airport;
  final SearchDelegate<Airport> searchDelegate;

  @override
  Widget build(BuildContext context) {
    final title = '${airport.name} (${airport.iata})';
    final subtitle = '${airport.city}, ${airport.country}';
    final ThemeData theme = Theme.of(context);
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: theme.textTheme.bodyText1,
        textAlign: TextAlign.start,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyText2,
        textAlign: TextAlign.start,
      ),
      onTap: () => searchDelegate.close(context, airport),
    );
  }
}
