class UserExistsException implements Exception {
  String? message;
  UserExistsException({
    this.message,
  });
}
