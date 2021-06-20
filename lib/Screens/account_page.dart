import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/Screens/login_screen.dart';
import 'package:photo_album/Screens/settings_page.dart';

import 'camera_page.dart';

class AccountScreen extends StatelessWidget {
  int _selectedIndex = 2;
  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  Future<QuerySnapshot> getImages() {
    return firebase.collection("images").get();
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
              })
        ],
      ),
      body: Container(
        child: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 200,
                ),
                FutureBuilder(
                    future: getImages(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        int amountPhotos = snapshot.data.docs.length;
                        return Column(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 50,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Hello , you have " +
                                "$amountPhotos" +
                                " photos in the app"),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              child: Text("LOGOUT"),
                            ),
                          ],
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
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
          onTap: (_selectedIndex) {
            switch (_selectedIndex) {
              case 0:
                Navigator.pop(
                  context,
                );
                break;

              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPhoto()),
                );
                break;

              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
                break;
            }
          }),
    );
  }
}