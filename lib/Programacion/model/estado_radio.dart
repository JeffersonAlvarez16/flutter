import 'package:flutter/material.dart';

class EstadoRadio {
  final bool initial_play;
  final bool playandpause;
  final String deviceId;

  EstadoRadio(
      {Key key, @required this.initial_play, @required this.playandpause, @required this.deviceId});
}
