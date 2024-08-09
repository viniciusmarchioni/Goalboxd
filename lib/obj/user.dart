import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String? urlimage;
  late String username;
  late String email;
  late int id;
  late int qtdNota;
  late int qtdComentarios;

  User.fromJsonToProfile(Map<String, dynamic> json)
      : username = json['username'],
        qtdNota = json['qtd_notas'],
        urlimage = json['image'],
        qtdComentarios = json['qtd_comentarios'];

  User.fromJsonToLogin(Map<String, dynamic> json)
      : username = json['username'],
        urlimage = json['image'],
        id = json['userid'];

  Future<void> getProfile(int? id) async {
    try {
      if (id == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        id = prefs.getInt('id') ?? 1;
      }
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/users/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        User user = User.fromJsonToProfile(data);
        this.id = id;
        username = user.username;
        urlimage = user.urlimage;
        qtdComentarios = user.qtdComentarios;
        qtdNota = user.qtdNota;
      } else if (response.statusCode == 400) {
        throw 'Perfil inexistente';
      } else {
        throw 'Erro em buscar perfil';
      }
    } catch (e) {
      throw 'Erro em buscar perfil';
    }
  }

  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/users/login'),
        body: jsonEncode({
          'email': email,
          'username': username,
          'userid': 0,
          'image': urlimage
        }),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        User user = User.fromJsonToLogin(jsonResponse);
        username = user.username;
        urlimage = user.urlimage;
        id = user.id;
        prefs.setInt('id', id);
        prefs.setString('username', username);
        prefs.setString(
            'image',
            urlimage ??
                'https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png');
      } else {
        throw Exception('Erro response');
      }
    } on TimeoutException {
      throw Exception('Timeout');
    } catch (e) {
      throw Exception('Erro Catch: $e');
    }
  }

  User.toLogin(this.username, this.email, this.urlimage);
  User();
}
