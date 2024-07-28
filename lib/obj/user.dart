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
}
