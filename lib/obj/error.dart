class ExpiredToken extends Error {
  final String message;

  ExpiredToken(this.message);

  @override
  String toString() => message;
}
