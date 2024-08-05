import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class User {
  String? image;
  late String name;
  late String email;
  int? id;

  // Construtor padrão
  User(this.name, this.email, this.image, this.id);

  // Construtor nomeado
  User.fromJson(Map<String, dynamic> json)
      : name = json['username'],
        email = json['email'],
        image = json['image'],
        id = json['userid'];

  static Future<User> login(User user) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/users/login'),
        body: jsonEncode({
          'email': user.email,
          'username': user.name,
          'userid': 0,
          'image': user.image
        }),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load objects');
      }
    } on TimeoutException {
      return user;
    } catch (e) {
      throw user;
    }
  }
}

class UserView {
  late String username;
  String? urlImage;
  late int qtdNota;
  late int qtdComentarios;

  UserView(this.username, this.urlImage, this.qtdComentarios, this.qtdNota);

  UserView.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        qtdNota = json['qtd_notas'],
        urlImage = json['image'],
        qtdComentarios = json['qtd_comentarios'];

  static Future<UserView> getProfile(int id) async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/users/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserView.fromJson(data);
      } else if (response.statusCode == 400) {
        throw 'Perfil inexistente';
      } else {
        throw 'Erro em buscar perfil';
      }
    } catch (e) {
      throw 'Erro em buscar perfil';
    }
  }
}
