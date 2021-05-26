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
        borderRadius: BorderRadius.circular(padding),
        color: Theme.of(context).primaryColorDark,
      ),
      child: getUser(),
    );
  }

  Widget getUser() {
    String uid = documentSnapshot.get('uid');
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

    return Container(
      padding: EdgeInsets.all(space / 2),
      child: FutureBuilder(
        future: userCollection.doc(uid).get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Row(
              children: [
                StorageService().getPhoto(context, snapshot.data['firstname'][0], snapshot.data['photo'], 20, 30.0),
                SizedBox(width: space),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${snapshot.data['firstname']}', style: Theme.of(context).primaryTextTheme.headline6.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
                      Text('${documentSnapshot.get('height').toInt()} x ${documentSnapshot.get('length').toInt()} cm', style: TextStyle(color: Colors.white),),
                      Text('${documentSnapshot.get('weight').toInt()} Kg', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                    ],
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error.toString());
          }
        return CircularProgressIndicator();
      },),
    );
  }
}
