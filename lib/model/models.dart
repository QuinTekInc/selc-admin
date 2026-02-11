

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:selc_admin/components/utils.dart';



//todo: general settings model
class GeneralSetting{
  final int currentSemester;
  final int academicYear;
  final bool enableEvaluations;
  final DateTime semesterEndDate;
  
  bool requireUpdateCalendar;
  

  GeneralSetting({
    required this.currentSemester, 
    required this.academicYear, 
    required this.enableEvaluations, 
    required this.semesterEndDate,
    this.requireUpdateCalendar = false
  });

  factory GeneralSetting.fromJson(Map<String, dynamic> jsonMap){
    return GeneralSetting(
      currentSemester: jsonMap['current_semester'],
      academicYear: jsonMap['academic_year'],
      enableEvaluations: jsonMap['enable_evaluations'],
      semesterEndDate: DateTime.parse(jsonMap['semester_end_date']),
      requireUpdateCalendar: jsonMap['require_update_calendar'] ?? false,
    );
  }


  Map<String, dynamic> toMap() =>{
    'current_semester': currentSemester,
    'academic_year': academicYear,
    'enable_evaluations': enableEvaluations
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
  final int numberOfStudents;
  final int numberOfLecturers;


  Department({required this.departmentId, required this.departmentName, this.numberOfStudents = 0, this.numberOfLecturers = 0});


  factory Department.fromJson(Map<String, dynamic> jsonMap){
    return Department(
      departmentId: jsonMap['department_id'],
      departmentName: jsonMap['department_name'],
      numberOfStudents: jsonMap['number_of_students'] ?? 0,
      numberOfLecturers: jsonMap['number_of_lecturers']
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
  UserRole userRole;
  bool isActive;

  User({this.username, this.firstName, this.lastName, this.email, this.isActive=true, required this.userRole});

  factory User.fromJson(Map<String, dynamic> jsonMap){
    return User(
        username: jsonMap['username'],
        firstName: jsonMap['first_name'],
        lastName: jsonMap['last_name'] ?? 'N/A',
        email: jsonMap['email'] ?? 'N/A',
        userRole: UserRole.fromString(jsonMap['role']),
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



enum UserRole{

  SUPERUSER("superuser"),
  ADMIN("admin"),
  LECTURER("lecturer"),
  STUDENT("student");

  final String roleString;

  const UserRole(this.roleString);

  static UserRole fromString(String roleStr){
    for(UserRole role in UserRole.values){
      if(role.roleString == roleStr) return role;
    }

    throw Exception('Role not Found');
  }

  @override String toString() => roleString;

}





//todo: questionnaire
class Questionnaire{

  int questionId;
  Category category;
  String question;
  QuestionAnswerType? answerType;

  Questionnaire({required this.questionId, required this.category, required this.question, required this.answerType});


  factory Questionnaire.fromJson(Map<String, dynamic> jsonMap){
    return Questionnaire(
      questionId: jsonMap['id'],
      category: Category.fromJson(jsonMap['category']),
      question: jsonMap['question'],
      answerType: QuestionAnswerType.fromString(jsonMap['answer_type'])
    );
  }

}




//todo: category
// ignore: must_be_immutable
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
    'category_name': categoryName
  };


  @override List<Object> get props => [categoryId, categoryName];

  @override
  String toString() {
    return categoryName;
  }

}





//todo: the lecturer and lecturer rating classes
class Lecturer {

  String username;
  String name;
  String email;
  String department;
  double rating;
  String remark;

  List<dynamic> coursesHandled = [];

  Lecturer({
    required this.username,
    required this.name,
    required this.email,
    required this.department,
    required this.rating,
    required this.remark
  });


  factory Lecturer.fromJson(Map<String, dynamic> jsonMap){
    return Lecturer(
      username: jsonMap['username'],
      name: jsonMap['name'],
      email: jsonMap['email'],
      department: jsonMap['department'],
      rating: jsonMap['rating'].toDouble(),
      remark: jsonMap['remark']
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
  String level;
  int semester;
  int year;
  int credits;
  Lecturer lecturer;
  Course course;
  bool isAcceptingResponse;
  double grandMeanScore;
  double grandPercentageScore;
  double lecturerRating;
  String? remark;
  int registeredStudentsCount;
  int evaluatedStudentsCount;
  List<String> programs; 

  ClassCourse({
    required this.classCourseId,
    this.level = '',
    required this.semester,
    required this.year,
    required this.course,
    required this.credits,
    required this.lecturer,
    this.isAcceptingResponse = false,
    this.grandMeanScore = 0,
    this.grandPercentageScore = 0,
    this.lecturerRating = 0,
    this.remark,
    this.registeredStudentsCount = 0,
    this.evaluatedStudentsCount = 0,
    this.programs = const []
  });


  factory ClassCourse.fromJson(Map<String, dynamic> jsonMap){

    return ClassCourse(
      classCourseId: jsonMap['cc_id'],
      level: jsonMap['level'] ?? '',
      semester: jsonMap['semester'],
      year: jsonMap['year'],
      credits: jsonMap['credit_hours'],
      course: Course.fromJson(jsonMap['course']),
      lecturer: Lecturer.fromJson(jsonMap['lecturer']),
      isAcceptingResponse: jsonMap['is_accepting_response'],
      grandMeanScore: jsonMap['grand_mean_score'].toDouble() ?? 0,
      grandPercentageScore: jsonMap['grand_percentage'].toDouble() ?? 0,
      remark: jsonMap['remark'],
      lecturerRating: jsonMap['lecturer_course_rating'].toDouble() ?? 0,
      registeredStudentsCount: jsonMap['number_of_registered_students'],
      evaluatedStudentsCount: jsonMap['number_of_evaluated_students'],
      programs: List<String>.from(jsonMap['programs'] ?? [])
    );
  }



  double calculateResponseRate(){
    if(registeredStudentsCount == 0) return 0;

    return (evaluatedStudentsCount / registeredStudentsCount) * 100;
  }




  @override String toString() => '${course.courseCode}[${course.title}] - ${lecturer.name}';

}



//todo: course evaluation summary
class CourseEvaluationSummary{

  String question;
  QuestionAnswerType answerType;
  Map<String, dynamic>? answerSummary;
  double percentageScore; //note: this value is in percentages
  double meanScore;
  String remark;

  CourseEvaluationSummary({
    required this.question,
    required this.answerType,
    this.answerSummary,
    this.percentageScore = 0,
    this.meanScore = 0,
    this.remark = ''
  });



  factory CourseEvaluationSummary.fromJson(Map<String, dynamic> jsonMap){

    QuestionAnswerType answerType = QuestionAnswerType.fromString(jsonMap['answer_type'])!;
    Map<String, dynamic> answerSummary = jsonMap['answer_summary'];

    answerSummary = processOtherPossibleAnswers(answerType, answerSummary);

    return CourseEvaluationSummary(
      question: jsonMap['question'],
      answerType: answerType,
      meanScore: jsonMap['mean_score'].toDouble(),
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



class CCProgramInfo{

  String program; 
  
  int registeredStudentsCount; 
  int evaluatedStudentsCount; 
  double responseRate; 
  double meanScore; 
  double percentageScore; 
  String remark; 
  double lecturerRating;

  CCProgramInfo({
    required this.program,
    this.registeredStudentsCount = 0,
    this.evaluatedStudentsCount = 0,
    this.responseRate = 0,
    this.meanScore = 0,
    this.percentageScore = 0,
    this.remark = '',
    this.lecturerRating = 0
  });


  factory CCProgramInfo.fromJson(Map<String, dynamic> jsonMap){
    return CCProgramInfo(
      program: jsonMap['program'],
      registeredStudentsCount: (jsonMap['number_of_registered_students'] as num).toInt(),
      evaluatedStudentsCount: (jsonMap['number_of_evaluated_students'] as num).toInt(),
      responseRate: (jsonMap['response_rate'] as num).toDouble(),
      meanScore: (jsonMap['mean_score'] as num).toDouble(),
      percentageScore: (jsonMap['percentage_score'] as num).toDouble(),
      remark: jsonMap['remark'],
      lecturerRating: (jsonMap['lecturer_rating'] as num).toDouble()
    );
  }
}




//todo: category remarks for evaluations
//todo: rename this class to "EvaluationCategoryRemark"
class CategoryEvaluation{

  final String categoryName;
  final double percentageScore;
  final double meanScore;
  final String remark;
  final List<String> questions;

  CategoryEvaluation({
    required this.categoryName,
    this.percentageScore = 0,
    required this.meanScore,
    required this.remark,
    required this.questions
  });


  factory CategoryEvaluation.fromJson(Map<String, dynamic> jsonMap){

    List<String> questions = [];

    for(dynamic qMap in List<dynamic>.from(jsonMap['questions'])){
      questions.add(Map<String, dynamic>.from(qMap)['question']);
    }

    return CategoryEvaluation(
      categoryName: jsonMap['category'],
      percentageScore: (jsonMap['percentage_score'] as num).toDouble(),
      meanScore: (jsonMap['mean_score'] as num).toDouble(),
      remark: jsonMap['remark'],
      questions: questions
    );
  }

}




//todo: course rating  (also normally shown on the desktop)
class CourseRating{

  final Course course;
  final int numberOfLecturers;
  final int numberOfStudents;
  final int evaluatedStudents;
  final double parameterMeanScore;
  final double percentageScore;

  final String remark;


  CourseRating({
    required this.course,
    this.numberOfLecturers = 0,
    required this.numberOfStudents,
    this.evaluatedStudents = 0,
    required this.parameterMeanScore,
    this.percentageScore = 0,
    this.remark = ''
  });


  factory CourseRating.fromJson(Map<String, dynamic> jsonMap){
    return CourseRating(
      course: Course.fromJson(jsonMap),
      numberOfLecturers: jsonMap['number_of_lecturers'],
      numberOfStudents: jsonMap['number_of_students'],
      evaluatedStudents: jsonMap['number_of_evaluated_students'],
      parameterMeanScore: jsonMap['parameter_mean_score'].toDouble(),
      percentageScore: jsonMap['percentage_score'].toDouble(),
      remark: jsonMap['remark']
    );
  }



  double calculateResponseRate() {
    if(numberOfStudents == 0 || evaluatedStudents == 0) return 0;

    return (evaluatedStudents/numberOfStudents) * 100;
  } //todo: implement this function later


}





//todo: evaluation suggestion
class EvaluationSuggestion{

  final double rating;
  final String suggestion;
  final String sentiment;
  final String program;

  EvaluationSuggestion({required this.rating, required this.suggestion, required this.sentiment, required this.program});


  factory EvaluationSuggestion.fromJson(Map<String, dynamic> jsonMap){
    return EvaluationSuggestion(
      rating: (jsonMap['rating'] as num).toDouble(),
      suggestion: jsonMap['suggestion'],
      sentiment: jsonMap['sentiment'],
      program: jsonMap['program']
    );
  }

}






class SuggestionSentimentSummary{

  final String sentiment;
  final int sentimentCount;
  final double sentimentPercent;

  SuggestionSentimentSummary({required this.sentiment, required this.sentimentCount, required this.sentimentPercent});


  factory SuggestionSentimentSummary.fromJson(Map<String, dynamic> jsonMap){
    return SuggestionSentimentSummary(
      sentiment: jsonMap['sentiment'],
      sentimentCount: jsonMap['sentiment_count'],
      sentimentPercent: jsonMap['sentiment_percent'].toDouble())
    ;
  }
  
}






class SuggestionSummaryReport{

  final List<SuggestionSentimentSummary> sentimentSummaries;
  final List<EvaluationSuggestion> suggestions;

  SuggestionSummaryReport({required this.sentimentSummaries, required this.suggestions});

  factory SuggestionSummaryReport.fromJson(Map<String, dynamic> jsonMap){
    return SuggestionSummaryReport(
      sentimentSummaries: List<Map<String, dynamic>>.from(jsonMap['sentiment_summary']).map(
        (jsonMap) => SuggestionSentimentSummary.fromJson(jsonMap)
      ).toList(),

      suggestions: List<Map<String, dynamic>>.from(jsonMap['suggestions']).map(
        (jsonMap) => EvaluationSuggestion.fromJson(jsonMap)
      ).toList()
    );
  }
}






//todo: rename this class to "LecturerRatingSummary"
class EvalLecturerRatingSummary{
  final int rating;
  final int ratingCount;
  final double percentage;

  EvalLecturerRatingSummary({required this.rating, required this.ratingCount, required this.percentage});

  factory EvalLecturerRatingSummary.fromJson(Map<String, dynamic> jsonMap){
    return EvalLecturerRatingSummary(
      rating: jsonMap['rating'],
      ratingCount: jsonMap['rating_count'],
      percentage: jsonMap['percentage'].toDouble()
    );
  }
}







//the model for the dashboard evaluation sentiment scores for each lecturer.
class DashboardSuggestionSentiment{
  final String lecturerName;
  final Course course;
  final List<SuggestionSentimentSummary> sentimentSummary;


  DashboardSuggestionSentiment({required this.lecturerName, required this.course, required this.sentimentSummary});

  factory DashboardSuggestionSentiment.fromJson(Map<String, dynamic> jsonMap){
    return DashboardSuggestionSentiment(
      lecturerName: jsonMap['lecturer'],
      course: Course.fromJson(jsonMap['course']),
      sentimentSummary: List<SuggestionSentimentSummary>.from(
          jsonMap['sentiment_summary'].map(
                  (_jsonMap) => SuggestionSentimentSummary.fromJson(_jsonMap)).toList())
    );
  }
}





//the model for the dashboard evaluation categories for each lecturer.
class DashboardCategoriesSummary{
  final String lecturerName;
  final String department;
  final Course course;
  final List<CategoryEvaluation> categoryRemarks;


  DashboardCategoriesSummary({required this.lecturerName, required this.department, required this.course, required this.categoryRemarks});



  factory DashboardCategoriesSummary.fromJson(Map<String, dynamic> jsonMap){

    List<CategoryEvaluation> categoryRemarks = [];

    if(jsonMap['categories_summary'] != null){
      categoryRemarks = List<CategoryEvaluation>.from(jsonMap['categories_summary']!.map(
              (summaryMap) => CategoryEvaluation.fromJson(summaryMap)).toList());
    }

    return DashboardCategoriesSummary(
      lecturerName: jsonMap['lecturer'],
      department: jsonMap['department'],
      course: Course.fromJson(jsonMap['course']), //contains course_code and title.
      categoryRemarks: categoryRemarks
    );
  }

}



//beads of fortune



class ReportFile{

  String fileName;
  String fileType;
  String url;
  String? localFilePath;


  ReportFile({required this.fileName,  required this.fileType, required this.url, this.localFilePath});


  factory ReportFile.fromJson(Map<String, dynamic> jsonMap){
    return ReportFile(
      fileName: jsonMap['file_name'],
      fileType: jsonMap['file_type'],
      url: jsonMap['file_url'],
      localFilePath: jsonMap['local_file_path']
    );
  }



  bool get isFileExistLocally{

    if(localFilePath == null || kIsWeb) return false;

    String fullLocalPath = '$localFilePath/$fileName';

    bool flag1 = File(fullLocalPath).existsSync();

    if(flag1) return true;

    fullLocalPath = '$localFilePath/$fileName';

    bool flag2 = File(fullLocalPath).existsSync();

    return flag2;
  }


  String getFileName() => '$fileName.$fileType';


  Map<String, dynamic> toMap() => {
    'file_name': fileName,
    'file_type': fileType,
    'file_url': url,
    'local_file_path': localFilePath
  };




  @override
  bool operator == (Object other) {

    if(other is! ReportFile) return false;

    ReportFile rFile = other;

    return fileName == rFile.fileName && fileType == rFile.fileType && url == rFile.url; 
  }


}