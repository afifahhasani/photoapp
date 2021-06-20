import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/alert_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'home_screen.dart';

class AddPhoto extends StatefulWidget {
  @override
  _AddPhotoState createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  final _picker = ImagePicker();
  PickedFile image;
  File imageFile;
  var storage = FirebaseStorage.instance;
  TextEditingController descriptionController = new TextEditingController();
  String location="None";
  bool locationAdded=false;

  Future <String> _getCurrentLocation() async {

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String location = position.toString();
    return location;

  }

  _openGallery(BuildContext context) async {
    image = await _picker.getImage(source: ImageSource.gallery);
    imageFile = File(image.path);
    this.setState(() {});
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    image = await _picker.getImage(source: ImageSource.camera);
    imageFile = File(image.path);
    this.setState(() {});
    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Import or take a photo"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Gallery"),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text("Camera"),
                    onTap: () {
                      _openCamera(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future uploadImageToFirebase(String location) async {
    var imageName = DateTime.now().toString();
    TaskSnapshot snapshot = await storage
        .ref()
        .child("Uploads/$imageName")
        .putFile(imageFile);

    if (snapshot.state == TaskState.success) {
      final String downloadUrl =
      await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("images")
          .add({"url": downloadUrl, "name": imageName,"description" : descriptionController.text,"location" : location});

    } else {
      print(
          'Error from image repo ${snapshot.state.toString()}');
      throw ('This file is not an image');
    }

  }

  Widget _determineView() {
    if (image == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0,250,0,250),
        child: Column(children: <Widget>[

          Text("NO IMAGE SELECTED"),
          ElevatedButton(
              onPressed: () {
                _showChoiceDialog(context);
              },
              child: Text("Select Image")),
        ]),
      );
    } else {
      return Column(children: <Widget>[

        SizedBox(height:10),
        Image.file(imageFile, width: 400, height: 400),

        SizedBox(height:10),
        Container(
          width: 200,
          child: TextField(
            controller: descriptionController,
            decoration: InputDecoration(
                labelText: 'Add a description'
            ),
          ),
        ),

        SizedBox(height:10),

        Container(
          width: 200,
          child: GestureDetector(
            onTap: () {
              confirmationDialog(
                context,
                "Add your current location?",
                title: "Tag location?",
                positiveAction: () async{
                  location = await _getCurrentLocation();
                  successDialog(context, "Successfully added current location");
                  locationAdded=true;
                  setState(() {
                  });
                },
                positiveText: "Yes",
              );
            },
            child: locationAdded ? Icon(Icons.add_location_alt,color: Colors.blue,):Icon(Icons.add_location_alt),
          ),
        ),

        SizedBox(height:10),
        ElevatedButton(

          onPressed: () async{
            waitDialog(context);
            await uploadImageToFirebase(location);
            Navigator.push(context,
              MaterialPageRoute(builder: (context)=>HomeScreen()),
            );
          },

          child: Text("Add"),

        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add an image'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _determineView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}