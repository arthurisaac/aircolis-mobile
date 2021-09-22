import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProposalItem extends StatefulWidget {
  const ProposalItem({Key key, @required this.doc}) : super(key: key);
  final DocumentSnapshot doc;

  @override
  _ProposalItemState createState() => _ProposalItemState();
}

class _ProposalItemState extends State<ProposalItem> {
  DocumentSnapshot documentSnapshot;

  @override
  void initState() {
    documentSnapshot = widget.doc;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: space / 2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(padding),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 16, offset: Offset(0, 5))
          ]),
      child: getUser(),
    );
  }

  Widget getUser() {
    String uid = documentSnapshot.get('uid');
    final CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');

    return Container(
      padding: EdgeInsets.symmetric(vertical: space, horizontal: space),
      child: FutureBuilder<DocumentSnapshot>(
        future: userCollection.doc(uid).get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data.data();
            var photo = (data != null && data.containsKey("photo"))
                ? snapshot.data["photo"]
                : "";
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StorageService().getPhoto(
                        context,
                        (data != null && data.containsKey("firstname"))
                            ? snapshot.data['firstname'][0]
                            : "?",
                        photo,
                        20,
                        30.0),
                    SizedBox(width: space),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(data != null && data.containsKey("firstname")) ? snapshot.data['firstname'] : "Inconnu"} ',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${documentSnapshot.get('height')} x ${documentSnapshot.get('length')} cm',
                          ),
                          Text(
                            '${documentSnapshot.get('weight')} Kg',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                /*Text(
                  '${documentSnapshot.get('description')}',
                ),*/
              ],
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error.toString());
          }
          return Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
