

import 'package:equatable/equatable.dart';
import 'package:selc_admin/components/utils.dart';



//todo: general settings model
class GeneralSetting{
  final int currentSemester;
  final bool disableEvaluations;

  GeneralSetting({required this.currentSemester, required this.disableEvaluations});

  factory GeneralSetting.fromJson(Map<String, dynamic> jsonMap){
    return GeneralSetting(
        currentSemester: jsonMap['current_semester'],
        disableEvaluations: jsonMap['disable_evaluations']
    );
  }


  Map<String, dynamic> toMap() =>{
    'current_semester': currentSemester,
    'disable_evaluations': disableEvaluations
  };
}






//todo: general statistics (normally shown on the dashboard)
class GeneralCurrentStatistics{

  final int currentSemester;
  final int coursesCount;
  final int lecturersCount;
  final int questionsCount;
  final int evaluationsCount;
  final int evalSuggestionsCount;


  GeneralCurrentStatistics({
    required this.currentSemester,
    required this.coursesCount,
    required this.lecturersCount,
    required this.questionsCount,
    required this.evaluationsCount,
    required this.evalSuggestionsCount
  });


  factory GeneralCurrentStatistics.fromJson(Map<String, dynamic> jsonMap){
    return GeneralCurrentStatistics(
        currentSemester: jsonMap['current_semester'],
        coursesCount: jsonMap['courses_count'],
        lecturersCount: jsonMap['lecturers_count'],
        questionsCount: jsonMap['questions_count'],
        evaluationsCount: jsonMap['evaluations_count'],
        evalSuggestionsCount: jsonMap['suggestions_count']
    );
  }

}





//todo: department
class Department{
  final int departmentId;
  final String departmentName;


  Department({required this.departmentId, required this.departmentName});


  factory Department.fromJson(Map<String, dynamic> jsonMap){
    return Department(
        departmentId: jsonMap['department_id'],
        departmentName: jsonMap['department_name']
    );
  }


  @override String toString() => departmentName;
}




//todo: the user model which of course include the current user model
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





//todo: questionnaire
class Question{

  int questionId;
  Category category;
  String question;
  QuestionAnswerType? answerType;

  Question({required this.questionId, required this.category, required this.question, required this.answerType});


  factory Question.fromJson(Map<String, dynamic> jsonMap){
    return Question(
        questionId: jsonMap['id'],
        category: Category.fromJson(jsonMap['category']),
        question: jsonMap['question'],
        answerType: QuestionAnswerType.fromString(jsonMap['answer_type'])
    );
  }

}




//todo: category
class Category extends Equatable{

  int categoryId;
  String categoryName;


  Category({required this.categoryId, required this.categoryName});


  factory Category.fromJson(Map<String, dynamic> jsonMap){
    return Category(
        categoryId: jsonMap['category_id'],
        categoryName: jsonMap['category_name']
    );
  }


  Map<String, dynamic> toMap() => {
    'category_name': categoryName!
  };


  @override List<Object> get props => [categoryId!, categoryName!];

  @override
  String toString() {
    return categoryName ?? '';
  }

}





//todo: the lecturer and lecturer rating classes
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




//todo: lecturer rating
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





//todo: course
class Course{

  String courseCode;
  String title;
  double? meanScore;
  String? remark;

  Course({required this.courseCode, required this.title, this.meanScore, this.remark});


  factory Course.fromJson(Map<String, dynamic> jsonMap){
    return Course(
        courseCode: jsonMap['course_code'],
        title: jsonMap['course_title'],
        meanScore: jsonMap['mean_score'].toDouble() ?? 0,
        remark: jsonMap['remark']
    );
  }



  @override
  String toString() {
    return '$title[$courseCode]';
  }

}



//todo: class course
class ClassCourse{

  int classCourseId;
  int semester;
  int year;
  String klass;
  Lecturer lecturer;
  Course course;
  double grandMeanScore;
  double lecturerRating;
  String? remark;

  ClassCourse({
    required this.classCourseId,
    required this.semester,
    required this.year,
    required this.klass,
    required this.course,
    required this.lecturer,
    this.grandMeanScore = 0,
    this.lecturerRating = 0,
    this.remark,
  });


  factory ClassCourse.fromJson(Map<String, dynamic> jsonMap){

    return ClassCourse(
        classCourseId: jsonMap['cc_id'],
        semester: jsonMap['semester'],
        year: jsonMap['year'],
        klass: jsonMap['class'] ?? 'A',
        course: Course.fromJson(jsonMap['course']),
        lecturer: Lecturer.fromJson(jsonMap['lecturer']),
        grandMeanScore: jsonMap['grand_mean_score'].toDouble() ?? 0,
        remark: jsonMap['remark'],
        lecturerRating: jsonMap['lecturer_course_rating'].toDouble() ?? 0
    );
  }

}



//todo: course evaluation summary
class CourseEvaluationSummary{

  String question;
  QuestionAnswerType answerType;
  Map<String, dynamic>? answerSummary;
  double percentageScore; //note: this value is in percentages
  double averageScore;
  String remark;

  CourseEvaluationSummary({
    required this.question,
    required this.answerType,
    this.answerSummary,
    this.percentageScore = 0,
    this.averageScore = 0,
    this.remark = ''
  });



  factory CourseEvaluationSummary.fromJson(Map<String, dynamic> jsonMap){

    QuestionAnswerType answerType = QuestionAnswerType.fromString(jsonMap['answer_type'])!;
    Map<String, dynamic> answerSummary = jsonMap['answer_summary'];

    answerSummary = processOtherPossibleAnswers(answerType, answerSummary);

    return CourseEvaluationSummary(
      question: jsonMap['question'],
      answerType: answerType,
      averageScore: jsonMap['average_score'].toDouble(),
      percentageScore: jsonMap['percentage_score'].toDouble(),
      answerSummary: answerSummary,
      remark: jsonMap['remark']
    );
  }


  static Map<String, dynamic> processOtherPossibleAnswers(QuestionAnswerType answerType, Map<String, dynamic> answerSummary){

    Map<String, dynamic> newAnswerSummary = {};


    for(String possibleValue in answerType.possibleValues){
      newAnswerSummary.addAll({possibleValue: answerSummary[possibleValue] ?? 0});
    }


    if(answerSummary.containsKey("No Answer")){
      newAnswerSummary.addAll({'No Answer': answerSummary['No Answer']});
    }


    answerSummary.clear();


    return newAnswerSummary;

  }


  @override String toString() => '$question -> ${answerType.typeString}';

}




//todo: category remarks for evaluations
class CategoryRemark{

  final String categoryName;
  final double percentageScore;
  final double averageScore;
  final String remark;

  CategoryRemark({
    required this.categoryName,
    this.percentageScore = 0,
    required this.averageScore,
    required this.remark,
  });


  factory CategoryRemark.fromJson(Map<String, dynamic> jsonMap){
    return CategoryRemark(
        categoryName: jsonMap['category'],
        percentageScore: jsonMap['percentage_score'].toDouble() ?? 0,
        averageScore: jsonMap['average_score'].toDouble() ?? 0,
        remark: jsonMap['remark']
    );
  }

}




//todo: course rating  (also normally shown on the desktop)
class CourseRating{

  final Course course;
  final int numberOfStudents;
  final double parameterRating;


  CourseRating({required this.course, required this.numberOfStudents, required this.parameterRating});


  factory CourseRating.fromJson(Map<String, dynamic> jsonMap){
    return CourseRating(
        course: Course.fromJson(jsonMap),
        numberOfStudents: jsonMap['number_of_students'],
        parameterRating: jsonMap['parameter_rating'].toDouble()
    );
  }


}





//todo: evaluation suggestion
class EvaluationSuggestion{

  final double rating;
  final String suggestion;

  EvaluationSuggestion({required this.rating, required this.suggestion});


  factory EvaluationSuggestion.fromJson(Map<String, dynamic> jsonMap){
    return EvaluationSuggestion(
        rating: jsonMap['rating'].toDouble(),
        suggestion: jsonMap['suggestion']
    );
  }

}




