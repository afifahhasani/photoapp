import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_album/Screens/login_screen.dart';
import 'package:photo_album/theme/theme_bloc.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc,ThemeState>(
          builder: (context,state) {
            return MaterialApp(
              title:'Photo album app',
              theme: state.themeData,
              home: LoginScreen(),

            );
          }
      ),
    );
  }
}