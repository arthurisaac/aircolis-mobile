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
        boxShadow: [
          BoxShadow(color: defaultColor, blurRadius: 10, offset: Offset(0, 0))
        ],
        color: Theme.of(context).primaryColor,
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
                      Text('${documentSnapshot.get('weight').toInt()} Kg', style: TextStyle(fontWeight: FontWeight.bold,),),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(space)),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                )
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

  /*_approve() {
    var snapshot =
        FirebaseFirestore.instance.collection('proposals').doc(widget.doc.id);

    Map<String, dynamic> data = {
      "isApproved": true,
    };

    snapshot.update(data).then((value) {

    }).catchError((onError) {
      // TODO
      print('Une erreur lors de l\'approbation: ${onError.toString()}');
    });
  }*/
}
