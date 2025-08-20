
// ignore_for_file: must_be_immutable

import 'package:selc_admin/components/utils.dart';
import 'package:equatable/equatable.dart';

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



class Category extends Equatable{

  int? categoryId;
  String? categoryName;


  Category({this.categoryId, this.categoryName});


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




class CategoryRemark{
  
  final String categoryName;
  final double avgScore;
  final String remark;

  CategoryRemark({required this.categoryName, required this.avgScore, required this.remark});


  factory CategoryRemark.fromJson(Map<String, dynamic> jsonMap){
    return CategoryRemark(  
      categoryName: jsonMap['category'],
      avgScore: jsonMap['average_score'].toDouble() ?? 0,
      remark: jsonMap['remark']
    );
  }

}