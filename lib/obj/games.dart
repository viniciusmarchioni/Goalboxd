class Games {
  late GameType type;
  late String team1name;
  late String team2name;
  late int? team1score;
  late int? team2score;
  late int id;
  late String? country1;
  late String? country2;
  late DateTime date;
  late String championship;
  late double rate;

  Games(
      this.type,
      this.id,
      this.team1name,
      this.team2name,
      this.team1score,
      this.team2score,
      this.country1,
      this.country2,
      this.date,
      this.championship,
      this.rate);

  String scorebord() {
    return "${team1score ?? ''} x ${team2score ?? ''}";
  }

  Games.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        team1name = json['team1'],
        team2name = json['team2'],
        team1score = json['score1'],
        team2score = json['score2'],
        country1 = json['country1'],
        country2 = json['country2'],
        date = DateTime.parse(json['date']),
        championship = json['championship'],
        rate = double.parse(json['rate']),
        type = _toGameType(json['type']);

  Games.forProfile(Map<String, dynamic> json)
      : id = json['id'],
        team1name = json['team1'],
        team2name = json['team2'],
        team1score = json['score1'],
        team2score = json['score2'],
        country1 = json['country1'],
        country2 = json['country2'],
        date = DateTime.parse(json['date']),
        championship = json['championship'],
        rate = 0,
        type = _toGameType(json['type']);
}

class ProfileGameComment {
  late Games game;
  late String comment;

  ProfileGameComment.fromJson(Map<String, dynamic> json)
      : game = Games.forProfile(json),
        comment = json['comment'];
}

class ProfileGameReview {
  late Games game;
  late int review;

  ProfileGameReview.fromJson(Map<String, dynamic> json)
      : game = Games.forProfile(json),
        review = json['nota'];
}

class Complements {
  late String? urlImage;
  late String? colorTeam;

  Complements(this.urlImage, this.colorTeam);

  Complements.fromJson(Map<String, dynamic> json)
      : colorTeam = json['color'],
        urlImage = json['url_image'];
}

GameType _toGameType(String type) {
  if (type == 'futebol') {
    return GameType.football;
  }
  return GameType.basquete;
}

enum GameType { football, basquete }
