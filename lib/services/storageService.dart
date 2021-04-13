import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService {

  Future<String> getImage(String filePath) async {
    var _urlImage = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('/users')
        .child(filePath)
        .getDownloadURL();

    return _urlImage;
  }
  Future<String> getDocument(String filePath) async {
    var _urlImage = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('/documents')
        .child(filePath)
        .getDownloadURL();

    return _urlImage;
  }

  Widget getPhoto(BuildContext context,String initials, String photo, double size, double radius) {
    if (photo == null || photo.isEmpty || photo == 'null') {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).accentColor,
        child: Text(
          "${initials.toUpperCase()}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: size * 1.5,
            color: Colors.white,
          ),
        ),
      );
    } else {
      /*return FutureBuilder<String>(
        future: getImage(photo),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasError) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                "${initials.toUpperCase()}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 1.5,
                  color: Colors.white,
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(snapshot.data.toString()),
            );
          }
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
          );
        },
      );*/
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photo),
      );
    }
  }
}