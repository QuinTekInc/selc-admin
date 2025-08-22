

// ignore_for_file: prefer_conditional_assignment

import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/model/lecturer.dart';

class Course{

  String? courseCode;
  String? title;
  double? meanScore;
  String? remark;

  Course({this.courseCode, this.title, this.meanScore, this.remark});


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



class ClassCourse{

  int? classCourseId;
  int? semester;
  int? year;
  String? klass;
  Lecturer? lecturer;
  Course? course;
  double grandMeanScore;
  double lecturerRating;
  String? remark;

  ClassCourse({
    this.classCourseId, 
    this.semester, 
    this.year, 
    this.klass, 
    this.course, 
    this.lecturer, 
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






class CourseEvaluationSummary{

  String question;
  QuestionAnswerType answerType;
  Map<String, dynamic>? answerSummary;

  CourseEvaluationSummary({required this.question, required this.answerType, this.answerSummary});

  factory CourseEvaluationSummary.fromJson(Map<String, dynamic> jsonMap){

    return CourseEvaluationSummary(
      question: jsonMap['question'],
      answerType: QuestionAnswerType.fromString(jsonMap['answer_type'])!,
      answerSummary: jsonMap['answer_summary']
    );
  }

  @override String toString() => '$question -> ${answerType.typeString}';

}




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






//model for displaying stuff on the desktop.
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




