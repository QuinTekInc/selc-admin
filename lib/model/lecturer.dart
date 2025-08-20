

class Lecturer {

  String username;
  String name;
  String email;
  String department;
  double rating;

  List<dynamic> coursesHandled = [];

  Lecturer({
    required this.username,
    required this.name,
    required this.email,
    required this.department,
    required this.rating
  });


  factory Lecturer.fromJson(Map<String, dynamic> jsonMap){
    return Lecturer(
      username: jsonMap['username'],
      name: jsonMap['name'],
      email: jsonMap['email'],
      department: jsonMap['department'],
      rating: jsonMap['rating'].toDouble()
    );
  }

}


class LecturerRating{
  
  final Lecturer lecturer;
  final int numberOfCourses;
  final int numberOfStudents;
  final double parameterRating;

  LecturerRating({required this.lecturer, this.numberOfCourses=0, this.numberOfStudents=0, this.parameterRating = 0});

  factory LecturerRating.fromJson(Map<String, dynamic> jsonMap){
    return LecturerRating(  
      lecturer: Lecturer.fromJson(jsonMap),
      numberOfCourses: jsonMap['number_of_courses'],
      numberOfStudents: jsonMap['number_of_students'],
      parameterRating: jsonMap['parameter_rating'].toDouble()
    );
  }
}




