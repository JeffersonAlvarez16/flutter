import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:just_audio/just_audio.dart';
import "package:radioklais/User/repository/auth_repository.dart";
import "package:firebase_auth/firebase_auth.dart";

class UserBloc implements Bloc {
  final autRepository = AuthRepository();
  AudioPlayer player = AudioPlayer();
  final assetsAudioPlayer = AssetsAudioPlayer();
  int tiempo;
  String titulo = "";
  String horario = "";
  AudioPlaybackState estadoRadioPlayer;
  AudioPlaybackState estado;

  AudioPlaybackState get estadoPlayer {
    return estadoRadioPlayer;
  }

  set estadoPlayer(AudioPlaybackState estadoRadio) {
    estadoRadioPlayer = estadoRadio;
  }

  AudioPlaybackState get estadoRadio {
    return estado;
  }

  set estadoRadio(AudioPlaybackState estadoR) {
    estado = estadoR;
  }

  int get age {
    return tiempo;
  }

  set radio(AudioPlayer radio) {
    player = radio;
  }

  String get title {
    return titulo;
  }

  set title(String titulos) {
    titulo = titulos;
  }

  String get horas {
    return horario;
  }

  set horas(String hora) {
    horario = hora;
  }

  Stream<FirebaseUser> streamFirebase =
      FirebaseAuth.instance.onAuthStateChanged;

  Future<FirebaseUser> signIn() {
    return autRepository.signInFirebase();
  }

  signOut() {
    return autRepository.signOut();
  }

  Stream<FirebaseUser> get authStatus => streamFirebase;
  @override
  void dispose() {}
}
