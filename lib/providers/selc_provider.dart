

import 'dart:convert';

import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/components/preferences_util.dart';
import 'package:selc_admin/components/server_connector.dart' as connector;
import 'package:selc_admin/model/models.dart';



class SelcProvider with ChangeNotifier{

  User? _user;
  User get user => _user!;

  List<Department> departments = [];
  List<Lecturer> lecturers = [];
  List<Questionnaire> questions = [];
  List<Category> categories = [];
  List<Course> courses = [];
  List<LecturerRating> lecturersRatings = [];
  List<ClassCourse> classCourses = [];
  List<CourseRating> coursesRatings = [];
  List<User> users = [];


  GeneralSetting? _generalSetting;
  GeneralSetting get generalSetting => _generalSetting!;

  bool enableEvaluations = false;

  GeneralCurrentStatistics? _generalStat;
  GeneralCurrentStatistics get generalStat =>_generalStat!;


  Future<void> login({required username, required String password}) async {

    Response response = await connector.postRequest(
      endpoint: 'login/',
        body: jsonEncode({
        'username': username,
        'password': password,
      })
    );
    


    if(response.statusCode == 403 || response.statusCode == 401){
      throw Exception(jsonDecode(response.body)['message']);
    }

    if(response.statusCode != 200){
      throw Error();

    }

    Map<String, dynamic> responseBody = jsonDecode(response.body);
    
    _user = User.fromJson(responseBody);
    //save the authorization key to the shared_preference.
    String authToken = responseBody['auth_token'];
    await saveAuthorizationToken(authToken);

    //todo: load the questions and everything when the user logs into his account

    await getGeneralSetting();
    await getGeneralCurrentStatistics();
    await getDepartments();
    await getQuestionsAndCategories();
    await getCourses();
    await getLecturers();

    notifyListeners();

  }


  //todo: request a verification code from the server.
  void requestCode({required String email}) async {

  }


  void resetPassword({required String newPassword, required String password}){

  }


  Future<void> logout() async {

    Response response = await connector.getRequest(endpoint: 'logout/');
    if(response.statusCode != 200){
      throw Exception('Could not logout.');
    }
  }




  Future<void> updateAccountInfo(Map<String, dynamic> updateMap) async{

    final response =  await connector.postRequest(
      endpoint: 'update-account-info/', body: jsonEncode(updateMap));

    
    if(response.statusCode != 200){

      if(response.statusCode == 406){
        throw Exception("The old password you entered was incorrect. please check and try again.");
      }


      throw Error();
    }


    dynamic responseBody = jsonDecode(response.body);

    _user = User.fromJson(responseBody as Map<String, dynamic>);

    notifyListeners();
    
  }



  Future<void> getGeneralSetting() async{
    final response = await connector.getRequest(endpoint: 'get-general-settings/');

    if(response.statusCode  != 200){
      throw Error();
    }

    dynamic responseBody = jsonDecode(response.body);

    _generalSetting = GeneralSetting.fromJson(responseBody as Map<String, dynamic>);

    notifyListeners();
  }




  Future<void> updateGeneralSetting(GeneralSetting generalSetting) async{
    final response = await connector.postRequest(
      endpoint: 'update-general-settings/', 
      body: jsonEncode( generalSetting.toMap())
    );

    if(response.statusCode != 200){
      throw Error();
    }



    _generalSetting = generalSetting;


    notifyListeners();

    getGeneralCurrentStatistics(); //reload the statistics without the await keyword

  }





  Future<void> getGeneralCurrentStatistics() async {

    final response = await connector.getRequest(endpoint: 'general-current-stats/');

    if(response.statusCode != 200){
      throw Error();
    }

    dynamic responseBody = jsonDecode(response.body);

    _generalStat = GeneralCurrentStatistics.fromJson(responseBody as Map<String, dynamic>);

    notifyListeners();
  }
  
  
  //todo: TO BE CONFIGURED FOR WEB SOCKET CONNECTION TO THE BACKEND
  Future<Map<String, dynamic>> getDashboardGraphData() async {
    
    final request = await connector.getRequest(endpoint: 'dashboard-graph-data/');
    
    if(request.statusCode != 200){
      throw Error();
    }


    final responseBody = jsonDecode(request.body);

    return responseBody;
  }


  //todo: all the current ClassCourse being taken in the semester.
  Future<List<ClassCourse>> getCurrentClassCourses() async {
    final response = await connector.getRequest(endpoint: 'get-all-current-class-courses/');

    if(response.statusCode != 200){
      throw Exception('An Unexpected error occurred. Please try again');
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => ClassCourse.fromJson(jsonMap)).toList();
  }


  Future<void> getClassCourses() async {

    final response = await connector.getRequest(endpoint: 'get-class-courses/');

    if(response.statusCode != 200){
      throw Exception('An Unexpected error occurred. Please try again');
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    classCourses = responseBody.map((jsonMap) => ClassCourse.fromJson(jsonMap)).toList();

    notifyListeners();

  }


  Future<void> updateClassCourse(int classCourseId, bool isAcceptingResponse) async {
    final response = await connector.postRequest(
      endpoint: 'update-class-course/$classCourseId',
      body: jsonEncode({'cc_id': classCourseId, 'is_accepting_response': isAcceptingResponse})
    );

    if(response.statusCode !=200){
      throw Error();
    }
  }



  Future<List<DashboardSuggestionSentiment>> getDashSuggestionSentiments() async {

    final response = await connector.getRequest(endpoint: 'get-all-current-class-courses-sentiments/');

    if(response.statusCode != 200){
      throw Error();
    }


    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => DashboardSuggestionSentiment.fromJson(jsonMap)).toList();

  }



  Future<List<DashboardCategoriesSummary>> getDashCategoriesSummary() async {

    final response = await connector.getRequest(endpoint: 'get-all-current-class-courses-categories-summary/');

    if(response.statusCode != 200){
      throw Error();
    }


    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => DashboardCategoriesSummary.fromJson(jsonMap)).toList();
  }



  Future<void> getDepartments() async{
    Response response = await connector.getRequest(endpoint: 'departments/');

    if(response.statusCode != 200){
      throw Exception('An error Occurred.');
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    departments = responseBody.map((jsonMap) => Department.fromJson(jsonMap)).toList();

    notifyListeners();
  }



  Future<List<ClassCourse>> getDepartmentClassCourses(int departmentId) async {

    final response = await connector.getRequest(endpoint: 'get-department-class-courses/$departmentId');

    if(response.statusCode != 200) throw Error();


    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => ClassCourse.fromJson(jsonMap)).toList();
  }


  Future<Map<String, dynamic>> getDepartmentGraph(int departmentId) async {
    final response = await connector.getRequest(endpoint: 'get-department-dashboard-graph/$departmentId');

    if(response.statusCode != 200){
      throw Error();
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }



  Future<void> getLecturers() async {

    Response response = await connector.getRequest(endpoint: 'lecturers/');

    if(response.statusCode != 200){
      throw Exception('An error Occurred.');
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    lecturers = responseBody.map((jsonMap) => Lecturer.fromJson(jsonMap)).toList();

    notifyListeners();
  }



  Future<List<ClassCourse>> getLecturerInfo(String lecturerUsername) async {

    Response response = await connector.getRequest(endpoint: 'lecturer-info/$lecturerUsername');

    if(response.statusCode != 200){
      throw Error();
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => ClassCourse.fromJson(jsonMap)).toList();
  }



  Future<Map<String, dynamic>> getCourseInformation(String courseCode) async {

    final response = await connector.getRequest(endpoint: 'course-info/$courseCode');

    if(response.statusCode != 200){
      throw Error();
    }

    dynamic responseBody = jsonDecode(response.body);

    return Map<String, dynamic>.from(responseBody);
  }




  Future<List<dynamic>> getClassCourseEvaluation(int classCourseId) async {

    Response response = await connector.getRequest(endpoint: 'class-course-eval-summary/$classCourseId');

    if(response.statusCode != 200){
      throw Error();
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    /*
    todo: paste the format of the response here
     */

    return responseBody;
  }




  Future<List<CCProgramInfo>> getCCProgramsInfo(int classCourseId) async{

    final response = await connector.getRequest(endpoint: 'class-course-detail-by-program/$classCourseId');

    if(response.statusCode != 200){
      throw Error();
    }


    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => CCProgramInfo.fromJson(jsonMap)).toList();
  } 



  Future<SuggestionSummaryReport> getEvaluationSuggestions(int classCourseId) async {


    final response =  await connector.getRequest(endpoint: 'eval-suggestions/$classCourseId');

    if(response.statusCode != 200){
      throw Error();
    }

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    print(responseBody);

    SuggestionSummaryReport suggestionsReport = SuggestionSummaryReport.fromJson(responseBody);
    
    return suggestionsReport;
  }


  //this function is called at a lecturer's detail or information page.
  Future<List<dynamic>> getYearlyLecturerRatingSummary(String username) async {
    final response = await connector.getRequest(endpoint: 'yearly-average-lrating-summary/$username');

    if(response.statusCode != 200){
      throw Error();
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => (jsonMap['year'], (jsonMap['average_rating'] as num).toDouble())).toList();
  }


  Future<List<EvalLecturerRatingSummary>> getOverallLecturerRatingSummary(String lecturerUsername) async {
    
    final response = await connector.getRequest(endpoint: 'overall-lrating-summary/$lecturerUsername');

    if(response.statusCode != 200){
      throw Error();
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => EvalLecturerRatingSummary.fromJson(jsonMap)).toList();
  }



  Future<List<EvalLecturerRatingSummary>> getEvalLecturerRatingSummary(int classCourseId) async {

    final response = await connector.getRequest(endpoint: 'eval-lrating-summary/$classCourseId');

    if(response.statusCode != 200){
      throw Error();
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    return responseBody.map((jsonMap) => EvalLecturerRatingSummary.fromJson(jsonMap)).toList();

  }





  Future<void> getQuestionsAndCategories() async{

    Response response = await connector.getRequest(endpoint: 'questions-and-categories/');


    if(response.statusCode != 200) throw Error();


    Map<String, dynamic> responseBody = jsonDecode(response.body);

    List<dynamic> questionsMapList = responseBody['questions'];
    questions = questionsMapList.map((jsonMap) => Questionnaire.fromJson(jsonMap)).toList();
    

    List<dynamic> categoriesMapList = responseBody['categories'];
    categories = categoriesMapList.map((jsonMap) => Category.fromJson(jsonMap)).toList();

    notifyListeners();
  }




  //todo: add question category.
  Future<void> addCategory(String categoryName) async {

    final response = await connector.postRequest(
      endpoint: 'add-category/', body: jsonEncode({'category_name': categoryName})
    );

    if(response.statusCode != 200){
      throw Error();
    }

    dynamic responseBody = jsonDecode(response.body);

    Category category = Category.fromJson(responseBody);

    categories.add(category);

    notifyListeners();
  }




  Future<void> updateCategory(Category category) async {

    final response = await connector.postRequest(
      endpoint: 'update-category/${category.categoryId}', body: jsonEncode({'category_name': category.categoryName})
    );

    if(response.statusCode != 200){
      throw Error();
    }

    categories.where(
      (cat) => cat.categoryId == category.categoryId).toList()[0].categoryName = category.categoryName;

    notifyListeners();
  }



  Future<void> addQuestion(Map<String, dynamic> questionMap) async {
    final response = await connector.postRequest(
      endpoint: 'add-questionnaire/',
      body: jsonEncode(questionMap)
    );

    if(response.statusCode != 200) throw Error();

    dynamic responseBody = jsonDecode(response.body);

    Questionnaire question = Questionnaire.fromJson(responseBody);
    questions.add(question);

    notifyListeners();

  }



  Future<void> getCourses() async {

    final response = await connector.getRequest(endpoint: 'courses/');

    if(response.statusCode != 200){ 
      throw Error();
    }

    List<dynamic> responseBody = jsonDecode(response.body);

    courses = responseBody.map((jsonMap) => Course.fromJson(jsonMap)).toList();

    notifyListeners();
  }



  Future<void> addCourse(Map<String, String> courseMap) async {

    final response = await connector.postRequest(endpoint: 'add-course/', body: jsonEncode(courseMap));

    if(response.statusCode != 200){
      throw Error();
    }

    courses.add(Course(courseCode: courseMap['course_code']!, title: courseMap['course_title']!));

    notifyListeners();
  }





  Future<void> getLecturerRatingsRank({Map<String, dynamic>? filterBody}) async {

    Response response;

    if(filterBody == null){
      response = await connector.getRequest(endpoint: 'lecturers-ratings-rank/');
    }else{
      response = await connector.postRequest(endpoint: 'lecturers-ratings-rank/', body: jsonEncode(filterBody));
    }


    if(response.statusCode != 200){
      throw Error();
    }


    List<dynamic> responseBody = jsonDecode(response.body); 
    
    lecturersRatings = responseBody.map((jsonMap) => LecturerRating.fromJson(jsonMap)).toList();

    notifyListeners();
  }



  Future<void> getCourseRatingsRank({Map<String, dynamic>? filterBody}) async {


    Response response;

    if(filterBody == null){
      response = await connector.getRequest(endpoint: 'courses-ratings-rank/');
    }else{
      response = await connector.postRequest(endpoint: 'courses-ratings-rank/', body: jsonEncode(filterBody));
    }


    if(response.statusCode != 200){
      throw Error();
    }


    List<dynamic> responseBody = jsonDecode(response.body);

    coursesRatings = responseBody.map((jsonMap) => CourseRating.fromJson(jsonMap)).toList();

    notifyListeners();
  }






  //todo: users management functions
  Future<void> getUsers() async {

    final response = await connector.getRequest(endpoint: 'all-users/');

    if(response.statusCode != 200){
      
      debugPrint(response.body);

      throw Error();
    }


    List<dynamic> responseBody = jsonDecode(response.body);

    users = responseBody.map((jsonMap) => User.fromJson(jsonMap)).toList();

    notifyListeners();
  }




  Future<void> createUser(Map<String, String> userMap) async {

    final response = await connector.postRequest(  
      endpoint: 'create-user/',
      body: jsonEncode(userMap)
    );


    if(response.statusCode != 200){
      throw Error();
    }

    notifyListeners();

  }




  Future<void> suUpdateUserAccount({required Map<String, dynamic> updateMap}) async {
    final response = await connector.postRequest(
      endpoint: 'su-update-user/', 
      body: jsonEncode(updateMap)
    );


    if(response.statusCode != 200){
      throw Error();
    }



    notifyListeners();
  }



  Future<List<ReportFile>> getReportFiles() async {

    final response = await connector.getRequest(endpoint: '/report-files');

    if(response.statusCode != 200){
      throw Error();
    }

    final responseBody = jsonDecode(response.body);


    return responseBody.map((jsonMap) => ReportFile.fromJson(jsonMap)).toList();

  }


}



// Stuff that need to be in memory at all times
//departments
//courses
//questionnaire and their categories
//users of the system



