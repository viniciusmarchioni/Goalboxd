class Comments {
  String? urlImage;
  final String username;
  final int userid;
  final String comment;

  Comments(
      {required this.userid,
      required this.username,
      required this.comment,
      this.urlImage});

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
        userid: json['userid'],
        comment: json['comment'],
        username: json['name'],
        urlImage: json['image']);
  }
}
