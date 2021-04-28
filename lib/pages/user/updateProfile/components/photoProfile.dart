import 'dart:io';

import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoProfile extends StatefulWidget {
  final String photo;
  final String avatar;

  const PhotoProfile({
    Key key,
    this.photo,
    this.avatar,
  }) : super(key: key);

  @override
  _PhotoProfileState createState() => _PhotoProfileState();
}

class _PhotoProfileState extends State<PhotoProfile> {
  final ImagePicker _picker = ImagePicker();
  PickedFile _imageFile;
  String photo;
  bool loading = false;

  @override
  void initState() {
    photo = widget.photo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _takePicture(ImageSource.gallery);
            },
            child: StorageService().getPhoto(context, widget.avatar, photo, MediaQuery.of(context).size.width * 0.2, MediaQuery.of(context).size.width * 0.2),
          ),
          SizedBox(
            height: space,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              elevation: 0.0,
            ),
            child: Text("${AppLocalizations.of(context)
                .translate("clickHereToChangeYourProfilePicture")}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            onPressed:  () {},
          )
        ],
      ),
    );
  }

  _takePicture(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);
    setState(() {
      _imageFile = pickedFile;
      photo = null;
    });
    if (_imageFile != null) {
      // uploadPhoto();
      _uploadPhoto();
    }
  }

  _uploadPhoto() async {
    File file = File(_imageFile.path);

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('users/${_imageFile.path.split("/").last}')
          .putFile(file);
      var path = await StorageService().getImage(_imageFile.path.split("/").last);
      _updateUser(path);
    } on FirebaseException catch (e) {
      print(e);
      Utils.showSnack(context,
          AppLocalizations.of(context).translate("anErrorHasOccurred"));
    }
  }

  _updateUser(String photo) {
    final String uid = FirebaseAuth.instance.currentUser.uid;
    var snapshot = FirebaseFirestore.instance.collection('users').doc(uid);

    Map<String, dynamic> data = {"photo": photo};

    snapshot.update(data).then((value) {
      Utils.showSnack(context, AppLocalizations.of(context).translate("profileUpdated"));
    }).catchError((onError) {
      Utils.showSnack(context, AppLocalizations.of(context).translate("anErrorHasOccurred"));
    });
  }
}
