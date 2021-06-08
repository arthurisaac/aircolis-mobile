import 'dart:io';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/VerificationRequest.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountFinish.dart';
import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class VerifyAccountStepTwo extends StatefulWidget {
  final String documentType;

  const VerifyAccountStepTwo({Key key, this.documentType}) : super(key: key);

  @override
  _VerifyAccountStepStateTwo createState() => _VerifyAccountStepStateTwo();
}

class _VerifyAccountStepStateTwo extends State<VerifyAccountStepTwo> {
  //final ImagePicker _picker = ImagePicker();
  //PickedFile _imageFile;
  PlatformFile file;
  String photo;
  int progress = 0;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
                '${AppLocalizations.of(context).translate(widget.documentType)}',
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
                //_takePicture(ImageSource.gallery);
                _pickDocument();
              },
              child: (file != null && file.extension == "jpg")
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(padding),
                      child: Image.file(
                        File(file.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: size.width,
                      padding: EdgeInsets.all(space),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(padding),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 65,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Prendre un document ou une photo'),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(
              height: height,
            ),
            AirButton(
              text: Text(
                  loading
                      ? '${AppLocalizations.of(context).translate("loading")}'
                      : '${AppLocalizations.of(context).translate("verify")}',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.04)),
              onPressed: !loading
                  ? () {
                      if (file == null) {
                        Utils.showSnack(context, "Choisir d'abord un document");
                      } else {
                        _uploadDocument();
                      }
                    }
                  : null,
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

  _pickDocument() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'doc'],
    );
    if (result != null) {
      file = result.files.first;
      setState(() {
        file = result.files.first;
      });

      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
    } else {
      // User canceled the picker
    }
  }

  _uploadDocument() async {
    setState(() {
      loading = true;
    });
    File _file = File(file.path);
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('documents/${file.path.split("/").last}')
        .putFile(_file);

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

    var path = await StorageService().getDocument(file.path.split("/").last);
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
    }).catchError((error) {
      print("Failed to add request verification: $error");
      setState(() {
        loading = false;
      });
    });
  }

/*
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
  }*/
}
