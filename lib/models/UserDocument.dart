class UserDocument {
  String? firstname;
  String? lastname;
  String? photo;

  UserDocument();

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'photo': photo,
    };
  }
}
