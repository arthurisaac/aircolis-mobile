import 'dart:io';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/VerificationRequest.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountFinish.dart';
import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class VerifyAccountStepTwo extends StatefulWidget {
  final String documentType;

  const VerifyAccountStepTwo({Key key, this.documentType}) : super(key: key);

  @override
  _VerifyAccountStepStateTwo createState() => _VerifyAccountStepStateTwo();
}

class _VerifyAccountStepStateTwo extends State<VerifyAccountStepTwo> {
  final ImagePicker _picker = ImagePicker();
  PickedFile _imageFile;
  String photo;
  int progress = 0;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    double height = space;

    var message = "uploadYourIDDocument";
    if (widget.documentType == "passport") {
      message = "uploadYourPassportDocument";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(height),
        child: Column(
          children: [
            SizedBox(height: height),
            Container(
              width: double.infinity,
              child: Text(
                '${AppLocalizations.of(context).translate(
                    widget.documentType)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.06,
                ),
              ),
            ),
            SizedBox(
              height: height / 2,
            ),
            Container(
              width: double.infinity,
              child: Text('${AppLocalizations.of(context).translate(message)}'),
            ),
            SizedBox(
              height: height * 2,
            ),
            GestureDetector(
              onTap: () {
                _takePicture(ImageSource.gallery);
              },
              child: Container(
                width: size.width,
                child: DottedBorder(
                  dashPattern: [6, 3, 2, 3],
                  color: Colors.black,
                  strokeWidth: 1,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(height / 2),
                      child: _imageFile == null
                          ? SvgPicture.asset(
                        'images/albums.svg',
                        height: size.width * 0.7,
                      )
                          : Container(
                        width: double.infinity,
                        height: size.width * 0.7,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(
                              File(_imageFile.path),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 2,
            ),
            AirButton(
              text:
              Text(loading ? '${AppLocalizations.of(context).translate("loading")}' :'${AppLocalizations.of(context).translate("verify")}',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize:
                      MediaQuery
                          .of(context)
                          .size
                          .width *
                          0.04)),
              onPressed: !loading ? () {
                if (_imageFile == null) {
                  //Utils().showMyDialog(context);
                  // TODO: Custom alert or snackbar
                } else {
                  _uploadDocument();
                }
              } : null,
            ),
            SizedBox(
              height: height,
            ),
            progress > 0.0 ? Text('$progress %') : Container()
          ],
        ),
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
      // _uploadPhoto();
    }
  }

  _uploadDocument() async {
    setState(() {
      loading = true;
    });
    File file = File(_imageFile.path);
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('documents/${_imageFile.path
        .split("/")
        .last}')
        .putFile(file);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      setState(() {
        progress = num.parse((snapshot.bytesTransferred / snapshot.totalBytes)
            .toStringAsFixed(0)) *
            100;
      });
      print(progress);
    }, onError: (e) {
      print(task.snapshot);
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      setState(() {
        loading = false;
      });
    });

    try {
      firebase_storage.TaskSnapshot snapshot = await task;
      print('Uploaded ${snapshot.bytesTransferred} bytes.');
      _sendToServer();
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  _sendToServer() async {
    final String uid = FirebaseAuth.instance.currentUser.uid;
    var requestCollection =
    FirebaseFirestore.instance.collection('verification').doc(uid);

    var path = await StorageService().getDocument(_imageFile.path
        .split("/")
        .last);
    VerificationRequest verificationRequest = VerificationRequest(
      uid: uid,
      documentRecto: path,
      documentType: widget.documentType,
    );
    var data = verificationRequest.toJson();
    await requestCollection.set(data).then((value) {
      setState(() {
        loading = false;
      });
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => VerifyAccountFinish()));
    }).catchError(
            (error) {
          print("Failed to add request verification: $error");
          setState(() {
            loading = false;
          });
        });
  }
}
