import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_album/Screens/account_page.dart';
import 'package:photo_album/Screens/camera_page.dart';
import 'package:photo_album/Screens/settings_page.dart';
import 'package:commons/alert_dialogs.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FirebaseFirestore firebase = FirebaseFirestore.instance;
  int _selectedIndex =0;

  Future<String> getDocID(int index) async {

    List<String> idList = [];
    var collection = FirebaseFirestore.instance.collection('images');
    var querySnapshots = await collection.get();
    for (var snapshot in querySnapshots.docs) {
      var documentID = snapshot.id; // <-- Document ID
      idList.add(documentID);
    }
    return idList[index];
  }

  Future<QuerySnapshot> getImages() {
    return firebase.collection("images").get();
  }

  void deletePhoto(int index) async{
    String id = await getDocID(index);
    confirmationDialog(
        context,
        "This action cannot be reversed",
        title: "Would you like to delete this photo ?",
        positiveText: "Delete",
        positiveAction: () {
          final collection = FirebaseFirestore.instance.collection('images');
          collection
              .doc('$id') // <-- Doc ID to be deleted.
              .delete() // <-- Delete
              .then((_) => print('Deleted'))
              .catchError((error) => print('Delete failed: $error'));

          setState(() {

          });

        }
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Album App'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ));
              }
          )
        ],
      ),
      body: Container(

        padding: EdgeInsets.all(10.0),

        child:  FutureBuilder(
          future: getImages(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: StaggeredGridView.countBuilder(
                  crossAxisCount: 4,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) => Container (
                    color: Colors.white,
                    child: FittedBox(
                      child: GestureDetector(
                        onLongPress: () {
                          deletePhoto(index);
                        },
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              content: Container(
                                width: 300,
                                height: 300,
                                child: Image.network(
                                  snapshot.data.docs[index]["url"],
                                ),
                              ),
                            ),
                          );
                        },
                        onDoubleTap: () {
                          infoDialog(
                            context,
                            "Description : "+snapshot.data.docs[index]["description"]+"\nDate taken: "+snapshot.data.docs[index]["name"]+"\nLocation tagged: "+snapshot.data.docs[index]["location"],
                            title: "Photo Information",
                          );
                        },

                        child: Image.network(
                          snapshot.data.docs[index]["url"],
                        ),
                      ),
                    ),

                  ),
                  staggeredTileBuilder: (int index) => StaggeredTile.count(2,2),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),

              );
            } else if (snapshot.connectionState == ConnectionState.none) {
              return Text("No data");
            }
            return CircularProgressIndicator();

          },
        ),



      ),

      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem> [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',

            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.add_a_photo),
              label: 'Add',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.badge),
              label: 'Profile',
            ),

          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          onTap : (_selectedIndex) {
            switch(_selectedIndex) {
              case 1: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPhoto()),
              );
              break;
              case 2: Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>AccountScreen()),
              );
              break;
            }
          }
      ),

    );
  }
}
