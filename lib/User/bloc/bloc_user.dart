import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:just_audio/just_audio.dart';
import "package:radioklais/User/repository/auth_repository.dart";
import "package:firebase_auth/firebase_auth.dart";

class UserBloc implements Bloc {
  final _aut_repository = AuthRepository();
  AudioPlayer player= AudioPlayer();
  final assetsAudioPlayer = AssetsAudioPlayer();
  int tiempo;
  String titulo="";
  String horario="";
  AudioPlaybackState estadoRadioPlayer=null;
  AudioPlaybackState estado=null;

  AudioPlaybackState get estadoPlayer {
    return estadoRadioPlayer;
  }

  void set estadoPlayer(AudioPlaybackState estadoRadio) {
    estadoRadioPlayer = estadoRadio;
  }

  AudioPlaybackState get estadoRadio {
    return estado;
  }

  void set estadoRadio(AudioPlaybackState estadoR) {
    estado = estadoR;
  }

  int get age {
    return tiempo;
  }

  void set radio(AudioPlayer radio) {
    player = radio;
  }

  String get title {
    return titulo;
  }

  void set title(String titulos) {
    titulo = titulos;
  }

  String get horas {
    return horario;
  }

  void set horas(String hora) {
    horario = hora;
  }

  AudioPlayer get radio {
    return player;
  }

  void set age(int tiempos) {
    tiempo = tiempos;
  }
  retornarRadio()async{
    try {
     return await assetsAudioPlayer;
    } catch (t) {
      return "Error";
    }
  }

  Stream<FirebaseUser> streamFirebase=FirebaseAuth.instance.onAuthStateChanged;





  Future<FirebaseUser> signIn() {
    return _aut_repository.signInFirebase();
  }

  signOut(){
    return _aut_repository.signOut();
  }



  Stream<FirebaseUser> get authStatus=>streamFirebase;
  @override
  void dispose() {}
}
