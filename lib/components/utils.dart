

// ignore_for_file: constant_identifier_names


import 'package:intl/intl.dart';
import 'dart:math';



String formatDate(DateTime dateTime){
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String formatTime(DateTime dateTime){
  return DateFormat('HH:mm').format(dateTime);
}


String concatDateTime(DateTime dateTime){
  return '${formatDate(dateTime)}, ${formatTime(dateTime)}';
}



String generatePassword() {
  const String chars = 
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';

  final Random rand = Random.secure();

    String generated = List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();

    return generated;
  }


enum QuestionAnswerType{

  yes_no('yes_no', ['Yes', 'No']),
  performance('performance', ['Poor', 'Average', 'Good', 'Very Good', 'Excellent']),
  time('time', ['Never', 'Rarely', 'Often', 'Very Often', 'Always']);


  final String typeString;
  final List<String> possibleValues;

  const QuestionAnswerType(this.typeString, this.possibleValues);

  static QuestionAnswerType? fromString(String typeString){
    return QuestionAnswerType.values.where((value) => typeString == value.typeString).first;
  }


  @override String toString() => typeString;
  
}



String formatDecimal(double number){

  int numberInt = number.toInt();

  if((number - numberInt).abs() == 0){
    return numberInt.toString();
  }

  return number.toStringAsFixed(2);
}
