import "package:flutter/material.dart";
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import "package:radioklais/Programacion/bloc/bloc_programacion.dart";
import 'package:radioklais/Programacion/ui/widget/programacion_diaria.dart';

class HomeRadioReproductor extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeRadio();
  }
}

class _HomeRadio extends State<HomeRadioReproductor> {
@override
  Widget build(BuildContext context) {
    // TODO: implement build
  return BlocProvider(
      child:ReproductoRadio(),
      bloc: ProgramacionBloc());
  }
}
