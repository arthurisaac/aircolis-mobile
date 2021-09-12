import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlertesScreen extends StatefulWidget {
  const AlertesScreen({Key key}) : super(key: key);

  @override
  _AlertesScreenState createState() => _AlertesScreenState();
}

class _AlertesScreenState extends State<AlertesScreen> {
  Future _future;

  @override
  void initState() {
    _future = FirebaseFirestore.instance.collection('alertes').get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alertes"),
      ),
      body: Container(
          child: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> documents = snapshot.data.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                var depart = documents[index].get("depart");
                var arrivee = documents[index].get("arrivee");
                return Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(color: Colors.black),
                              children: [
                            TextSpan(text: "Départ : "),
                            TextSpan(text: "${depart["city"]}, ${depart["country"]}")
                          ],),
                        ),
                        SizedBox(height: 5,),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(color: Colors.black),
                              children: [
                            TextSpan(text: "Arrivée : "),
                            TextSpan(text: "${arrivee["city"]}, ${arrivee["country"]}")
                          ],),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Une erreur s'est produite. Ressayer plustard"),
            );
          }

          return CircularProgressIndicator();
        },
      )),
    );
  }
}
