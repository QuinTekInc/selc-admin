

class User{

  String? username;
  String? firstName;
  String? lastName;
  String? email;
  bool isSuperuser; //the this is set to false, then the user role in this console is admin
  bool isActive;

  User({this.username, this.firstName, this.lastName, this.email, this.isSuperuser=false, this.isActive=true});
  
  factory User.fromJson(Map<String, dynamic> jsonMap){
    return User(
      username: jsonMap['username'],
      firstName: jsonMap['first_name'],
      lastName: jsonMap['last_name'] ?? 'N/A',
      email: jsonMap['email'] ?? 'N/A',
      isSuperuser: jsonMap['is_superuser'] ?? false,
      isActive: jsonMap['is_active'] ?? true
    );
  }


  String fullName() => '${firstName} ${lastName}';



  @override
  bool operator ==(Object other) {
   
    if(other.runtimeType != this.runtimeType) return false;

    User otherUserObject = other as User;

    return  this.username == otherUserObject.username;
  }

}