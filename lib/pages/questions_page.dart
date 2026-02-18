
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';
import 'package:selc_admin/model/models.dart';


class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {

  //controllers for the textfields.
  final searchController = TextEditingController();
  
  final qIdController = TextEditingController();
  final categoryController = DropdownController<Category>();
  final answerTypeController = DropdownController<QuestionAnswerType>();
  final questionController = TextEditingController();


  SelcProvider? selcProvider;

  bool isLoading = false;

  List<Questionnaire> filteredQuestions = [];
  List<Category> filteredCategories = [];
  
  bool isSuperuser = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selcProvider = Provider.of<SelcProvider>(context, listen: false);
    loadData();

    isSuperuser = selcProvider!.user.userRole == UserRole.SUPERUSER;
  }


  void loadData() async {

    setState(() => isLoading=true);

    await selcProvider!.getQuestionsAndCategories();

    setState((){
      isLoading = false;
      filteredQuestions = selcProvider!.questions;
      filteredCategories = selcProvider!.categories;
    });

  }


  @override
  Widget build(BuildContext context) {

    //debugPrint(selcProvider!.categories.toString());

    bool isQuestionsEmpty = selcProvider!.questions.isEmpty;
    bool isFilteredQuestionsEmpty = filteredQuestions.isEmpty;


    bool isCategoriesEmpty = selcProvider!.categories.isEmpty;
    bool isFilteredCategoriesEmpty = filteredCategories.isEmpty;


    return Container(
      padding: const EdgeInsets.all(16),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          //title of the current page.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              HeaderText(
                'Question Categories and Questionnaires',
                fontSize: 25,
              ),


              TextButton(
                onPressed: () => loadData(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.green.shade300,),
                    const SizedBox(width: 8,),

                    CustomText(
                      'Refresh',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.green.shade300,
                    )
                  ],
                )
              )
            ],
          ),


          const SizedBox(height: 16,),


          //todo: search text field
          Row(
            children: [

              Expanded(
                child: CustomTextField(
                  controller: searchController,
                  hintText: 'Search Questions And Categories',
                  leadingIcon: CupertinoIcons.search,

                  onChanged: handleSearch
                ),
              ),



              //todo: add category button
              if(isSuperuser) CustomButton.withIcon(
                'Add Category',
                icon: CupertinoIcons.add,
                //width: 143,
                forceIconLeading: true,
                backgroundColor: Colors.blue.shade400,
                onPressed: () => handleCategoryModalSheet(),
              ),



              //todo: add question button
              if(isSuperuser) CustomButton.withIcon(
                'Add Question',
                icon: CupertinoIcons.add,
                //width: 140,
                forceIconLeading: true,
                onPressed: () => handleQuestionModalSheet(),
              )
            ],
          ),


          const SizedBox(height: 16,),


          if(isLoading) Expanded(

            child: Center(
              child: CircularProgressIndicator(),
            ),

          )else Expanded(

            child: Row(

              children: [

                //todo: the half showing the categories
                Expanded(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.fromLTRB(8, 16, 8, 8),

                    decoration: BoxDecoration(
                      //Colors.white
                      color: PreferencesProvider.getColor(context, 'table-background-color'),
                      borderRadius: BorderRadius.circular(8)
                    ),


                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,

                      children: [

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: HeaderText(
                            'Categories',
                            textAlignment: TextAlign.left,
                          ),
                        ),

                        const SizedBox(height: 8,),


                        if(isCategoriesEmpty) Expanded(
                          child: CollectionPlaceholder(
                            title: 'No Data',
                            detail: 'Questionnaire Categories appear here.',
                          ),
                        )
                        else if(isFilteredCategoriesEmpty && !isCategoriesEmpty) Expanded(
                          child: CollectionPlaceholder(
                            title: 'No Match',
                            detail: 'Could not find any category the matches \'${searchController.text}\''
                          )
                        )
                        else Expanded(
                          flex: 2,
                          child: ListView.separated(
                            itemCount: filteredCategories.length,
                            separatorBuilder: (_, __) => SizedBox(height: 8,),
                            itemBuilder: (_, index){
                              Category category = filteredCategories[index];

                              return CategoryCell(
                                category: category,
                                onEditPressed: () => handleCategoryModalSheet(category: category, inEditMode: true),
                                onDeletePressed: (){} //todo: implement the onDelete function
                              );
                            }
                          ),
                        )

                      ],

                    ),


                  ),
                ),


                const SizedBox(width: 16,),

                //todo: part the showing th questions  for showing the questions.

                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,

                    decoration: BoxDecoration(
                      //Colors.white
                      color: PreferencesProvider.getColor(context, 'table-background-color'),
                      borderRadius: BorderRadius.circular(8)
                    ),

                    padding: EdgeInsets.fromLTRB(8, 16, 8, 8),

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,

                      children: [

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: HeaderText('Questions'),
                        ),

                        const SizedBox(height: 12,),


                        //show a placeholder when the questions are empty
                        if(isQuestionsEmpty) Expanded(
                          child: CollectionPlaceholder(
                            title: 'No Data',
                            detail: 'There are no questions. Press on the add button to add some to the database'
                          ),
                        )
                        else if(isFilteredQuestionsEmpty && !isQuestionsEmpty) Expanded(
                          child: CollectionPlaceholder(
                            title: 'No Match Found',
                            detail: 'Could not find any questions by the name category or phrase, "${searchController.text}"',
                          )
                        )
                        else Expanded(

                          child: ListView.builder(
                            itemCount: filteredQuestions.length,
                            itemBuilder: (_, index){

                              Questionnaire question = filteredQuestions[index];

                              return QuestionCell(
                                question: question,
                                onEditPressed: () => handleQuestionModalSheet(question: question),
                                onDeletePressed: (){},
                              );
                            }
                          ),
                        )

                      ],
                    ),
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }



  void handleSearch(String? newValue){

    if(searchController.text.isEmpty) {

      setState(() {
        filteredQuestions = selcProvider!.questions;
        filteredCategories = selcProvider!.categories; 
        
        debugPrint('Motherfucker');
      });

      return;
    }


    setState(() {

      filteredQuestions = selcProvider!.questions.where((question) {
        return question.question.contains(searchController.text) || question.category.categoryName.contains(searchController.text);
      }).toList();

      filteredCategories = selcProvider!.categories.where(
        (category) => category.categoryName.contains(searchController.text))
        .toList();
    });

  }



  void handleQuestionModalSheet({Questionnaire? question})=> showCustomModalBottomSheet(
    context: context, 
    isDismissible: false,
    isScrollControlled: true,
    child:  question == null ? AddQuestionPage() : AddQuestionPage.openEdit(question: question)
  );


  void handleCategoryModalSheet({Category? category, bool inEditMode = false})=> showCustomModalBottomSheet(
    context: context, 
    isDismissible: false,
    child: inEditMode ? AddCategoryPage.openEdit(category!) : AddCategoryPage()
  );


}







//todo: for adding a question to the database.
class AddQuestionPage extends StatefulWidget {

  final bool inEditMode;
  final Questionnaire? question;

  const AddQuestionPage({super.key, this.inEditMode = false, this.question});

  factory AddQuestionPage.openEdit({required Questionnaire question}){
    return AddQuestionPage(
      inEditMode: true,
      question: question,
    );
  }

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}


class _AddQuestionPageState extends State<AddQuestionPage> {

  final categoryController = DropdownController<Category>();
  final answerTypeController = DropdownController<QuestionAnswerType>();
  final questionController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState

    if(widget.inEditMode){
      categoryController.value = widget.question!.category;
      answerTypeController.value = widget.question!.answerType;
      questionController.text = widget.question!.question;
    }

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(

      width: 470,
      margin: const EdgeInsets.only(bottom: 12, right: 16),
      padding: EdgeInsets.all(16),
      
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1.5
        )
      ),

      child: Column(
      
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
      
        children: [
      
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeaderText(widget.inEditMode ? 'Update Question' : 'Add Question'),

              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: Icon(CupertinoIcons.xmark, color: Colors.red.shade400,),
                tooltip: 'Close',
              )
            ],
          ),
      
          const SizedBox(height: 8,),



          if(widget.inEditMode) Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CustomText( 
              'Question Id', 
              fontWeight: FontWeight.w600,
            ),
          ),


          if(widget.inEditMode) CustomTextField(  
            enabled: false, 
            controller: TextEditingController(text: widget.question!.questionId.toString()),
          ),
    


          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomText(
              'Question Category: ',
              fontWeight: FontWeight.w600,
            ),
          ),
      


          CustomDropdownButton<Category>(
            controller: categoryController, 
            hint: 'Select the Category the question falls under',
            items: Provider.of<SelcProvider>(context).categories, 
            onChanged: (newValue){}
          ),



          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomText(
              'Answer Type: ',
              fontWeight: FontWeight.w600,
            ),
          ),
                      


          CustomDropdownButton<QuestionAnswerType>(
            controller: answerTypeController, 
            hint: 'Select Answer Type',
            items: QuestionAnswerType.values, 
            onChanged: (newValue){}
          ),
      
      
      
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomText(
              'Question',
              fontWeight: FontWeight.w600,
            ),
          ),
      
      
          CustomTextField(
            controller: questionController,
            maxLines: 4,
            hintText: 'The actual question',
          ),


          const SizedBox(height: 16,),
      
      
          //todo: buttons containing the detail control buttons.
          if(!widget.inEditMode)CustomButton.withText(
            'Add', 
            width: double.infinity,
            onPressed: handleAddQuestion
          )
          else CustomButton.withText(
            'Update', 
            width: double.infinity,
            backgroundColor: Colors.blue.shade400,
            onPressed: handleUpdateQuestion
          )
        ]
      )
    );

  }

  

  void handleAddQuestion() async {


    Map<String, dynamic> questionMap = {
      'question': questionController.text,
      'answer_type': answerTypeController.value!.typeString,
      'category': categoryController.value!.categoryId
    };

    try{

      await Provider.of<SelcProvider>(context, listen: false).addQuestion(questionMap);


      Navigator.pop(context);

    }on SocketException catch(_){
      showNoConnectionAlertDialog(context);
    }
    
  }


  //todo: implement this later.
  void handleUpdateQuestion() async {

  }


}









//todo: for adding and viewing category
class AddCategoryPage extends StatefulWidget {

  final Category? category;
  final bool inEditMode;

  const AddCategoryPage({super.key, this.category, this.inEditMode = false});

  factory AddCategoryPage.openEdit(Category category){
    return AddCategoryPage(
      category: category,
      inEditMode: true,
    );
  }

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}


class _AddCategoryPageState extends State<AddCategoryPage> {

  bool disableButton = false;
  final catNameController = TextEditingController();

  String titleText = 'Add new Category';
  String buttonText = 'Add';

  @override
  void initState() {
    // TODO: implement initState

    if(widget.inEditMode) {
      titleText = 'Update Category';
      buttonText = 'update';
      catNameController.text = widget.category!.categoryName;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: 470,
      margin: const EdgeInsets.only(bottom: 12, right: 16),
      padding: EdgeInsets.all(16),
      
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1.5
        )
      ),


      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              HeaderText(titleText),

              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: Icon(CupertinoIcons.xmark, color: Colors.red.shade400,),
                tooltip: 'Close',
              )
            ],
          ),


          if(widget.inEditMode) Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CustomText(
              'Category Id:',
              fontWeight: FontWeight.w600,
            ),
          ),

          if(widget.inEditMode) IgnorePointer(
            ignoring: true,
            child: CustomTextField(
              enabled: false,
              controller: TextEditingController(text: widget.category!.categoryId.toString()),
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomText(
              'Category Name',
              fontWeight: FontWeight.w600,
            ),
          ),


          CustomText(
            'NB: New category name must be unique.'
          ),


          const SizedBox(height: 8,),


          CustomTextField(
            controller: catNameController,
            hintText: 'Enter new category name',
            onChanged: (newValue)=> setState((){
              disableButton = catNameController.text.isEmpty || 
                    (widget.inEditMode && widget.category!.categoryName == catNameController.text);
            }),
          ),


          const SizedBox(height: 12,),

          
          //todo: buttons containing the detail control buttons.
          CustomButton.withText(
            buttonText, 
            disable: disableButton,
            width: double.infinity,
            onPressed: widget.inEditMode ? handleUpdate : handleAdd
          )

        ],
      ),
    );
  }



  void handleAdd() async {

    try{
      await Provider.of<SelcProvider>(context, listen: false).addCategory(catNameController.text);

      Navigator.pop(context);

    }on SocketException catch(_){
      showNoConnectionAlertDialog(context);
    }on Error catch (_){
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred.....Please try again');
    }

  }


  void handleUpdate() async {


    try{

      //todo: put update here. that is to update the question category
      await Provider.of<SelcProvider>(context, listen: false).updateCategory(
        Category(categoryId: widget.category!.categoryId, categoryName: catNameController.text));

      Navigator.pop(context);
      
    }on SocketException catch(_){
      showNoConnectionAlertDialog(context);
    }on Error catch (_){
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred.....Please try again');
    }


  }
}
