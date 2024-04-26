import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PostService {
  var user = FirebaseAuth.instance.currentUser;
  DateTime today = DateTime.now();
  DateFormat dateDepartFormat = DateFormat("yyyy-MM-dd");

  Future<List<QuerySnapshot>> getTravels() async {
    var posts = await FirebaseFirestore.instance
        .collection('posts')
        .where('visible', isEqualTo: true)
        .get();

    return getProposals(posts);
  }

  Future<List<QuerySnapshot>> getTravelTasks() async {
    var posts = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user!.uid)
        .where('visible', isEqualTo: true)
        .where('dateDepart', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .get();

    return getProposals(posts);
  }

  Future<List<QuerySnapshot>> getProposals(QuerySnapshot posts) async {
    List<QuerySnapshot> proposals = [];
    await Future.wait(posts.docs.map((post) async {
      var e = await FirebaseFirestore.instance
          .collection('proposals')
          .where('post', isEqualTo: post.id)
          .get();
      if (e.docs.length > 0) {
        proposals.add(e);
      }
    }));
    return proposals;
  }

  Future<List<QuerySnapshot>> getAcceptedTravelTasks() async {
    var posts = await FirebaseFirestore.instance
        .collection('posts')
        .where('visible', isEqualTo: true)
        .where('dateDepart', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .get();

    return getAcceptedProposals(posts);
  }

  Future<List<QuerySnapshot>> getAcceptedTravelCount() async {
    var posts = await FirebaseFirestore.instance.collection('posts').get();

    return getAcceptedProposals(posts);
  }

  Future<List<QuerySnapshot>> getAcceptedProposals(QuerySnapshot posts) async {
    List<QuerySnapshot> proposals = [];
    await Future.wait(posts.docs.map((post) async {
      var e = await FirebaseFirestore.instance
          .collection('proposals')
          .where('post', isEqualTo: post.id)
          .where('uid', isEqualTo: user!.uid)
          .where('isApproved', isEqualTo: true)
          .get();
      if (e.docs.length > 0) {
        proposals.add(e);
      }
    }));
    return proposals;
  }

  Future<DocumentSnapshot> getOnePost(id) async {
    return await FirebaseFirestore.instance.collection('posts').doc(id).get();
  }

  Stream<QuerySnapshot<Object?>>? streamCurrentPost() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user!.uid)
        .where('visible', isEqualTo: true)
        .where('dateDepart', isGreaterThanOrEqualTo: today)
        .snapshots();
  }

  Future<QuerySnapshot> getProposal() {
    return FirebaseFirestore.instance
        .collection('proposals')
        .where('uid', isEqualTo: user!.uid)
        .where('isApproved', isEqualTo: true)
        .get();
  }

  Future<QuerySnapshot> userPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user!.uid)
        .where('visible', isEqualTo: true)
        .get();
  }

  /*Stream<QuerySnapshot> userPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }*/
}
