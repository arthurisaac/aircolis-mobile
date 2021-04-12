import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingService {
  static Future<void> updateTracking(String title,
      DocumentSnapshot documentSnapshot) async {

    List<dynamic> tracking = documentSnapshot['tracking'];
    tracking.asMap().entries.map((dataEntry) {
      print(dataEntry.value['title']);
      if (title == dataEntry.value['title']) {
        dataEntry.value['validated'] = true;
        dataEntry.value['creation'] = DateTime.now();
      }
    }).toList();
    var snapshot = FirebaseFirestore.instance.collection('posts').doc(documentSnapshot.id);
    Map<String, dynamic> data = {
      "tracking": tracking,
    };

    return await snapshot.update(data);
  }
    //var snapshot = FirebaseFirestore.instance.collection('posts').doc(documentSnapshot.id);
    /*if (documentSnapshot.exists) {
      snapshot.update(data).then((value) {
        //print('position update');
      }).catchError((onError) {
        print('error position saved');
      });
    } else {
      print('User is null');
    }
  }*/
  }
