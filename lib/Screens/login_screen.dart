import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';

import 'package:photo_album/Screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final LocalAuthentication localAuth = LocalAuthentication();

  _authenticate(String pin, BuildContext context) {
    if (pin == '0000') {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    } else {
      setState(() {});
    }
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(20.0),
    );
  }

  Future<Widget> _determineView() async {
    bool canCheckBiometric = await localAuth.canCheckBiometrics;

    if (canCheckBiometric) {
      return GestureDetector(
        onTap: () async {
          bool authenticated = await localAuth.authenticate(
              localizedReason: "Scan finger to authenticate");

          if (authenticated) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(
              Icons.fingerprint,
              size: 124.0,
            ),
            Text(
              'Touch to login',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Builder(builder: (context) {
        return Container(
          color: Colors.grey[100],
          child: Center(
              child: SingleChildScrollView(
                  child:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                        color: Colors.grey[100],
                        margin: const EdgeInsets.all(20.0),
                        padding: const EdgeInsets.all(20.0),
                        child: PinPut(
                            fieldsCount: 4,
                            onSubmit: (String pin) => _authenticate(pin, context),
                            focusNode: _pinPutFocusNode,
                            controller: _pinPutController,
                            submittedFieldDecoration: _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            selectedFieldDecoration: _pinPutDecoration,
                            followingFieldDecoration: _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(
                                color: Colors.deepPurpleAccent.withOpacity(1.0),
                              ),
                            ))),
                    const SizedBox(height: 30.0),
                    const Divider(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            onPressed: () => _pinPutController.text = '',
                            child: const Text('Clear All'),
                          ),
                        ])
                  ]))),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _determineView(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading....');
            default:
              if (snapshot.hasError)
                return Text("ERROR");
              else
                return snapshot.data;
          }
        },
      ),
    );
  }
}