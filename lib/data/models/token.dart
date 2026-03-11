class Token {
  final String token;

  Token({required this.token});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token'] ?? "",
    );
  }

  bool isEmpty() {
    return token.isEmpty;
  }
}
