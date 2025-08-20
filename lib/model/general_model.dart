

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



//model for showing the general statistics