
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:radioklais/User/bloc/bloc_user.dart';
import 'package:radioklais/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  Widget build(BuildContext context) {

    return BlocProvider(
        child: MaterialApp(
          title: 'Klais Radio',
          home: HomeKlais(),
        ),
        bloc: UserBloc());
  }
}
