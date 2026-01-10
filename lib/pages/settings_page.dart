
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';
import 'package:file_picker/file_picker.dart';


class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {


  PreferencesProvider? _preferencesProvider;
  PreferencesProvider get preferencesProvider => _preferencesProvider!;


 //just don't mind this instanciation
  final semesterController = DropdownController<int>();
  final academicYearController = TextEditingController();

  bool isDisableEvaluations = false;
  bool isSuperuser = false;

  @override
  void initState() {

    isSuperuser  = Provider.of<SelcProvider>(context, listen: false).user.userRole == UserRole.SUPERUSER;


    isDisableEvaluations = Provider.of<SelcProvider>(context, listen:false).enableEvaluations;
    semesterController.value = Provider.of<SelcProvider>(context, listen:false).currentSemester;
    academicYearController.text = Provider.of<SelcProvider>(context, listen: false).currentAcademicYear.toString();

    _preferencesProvider = Provider.of<PreferencesProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(

      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16),
          child: HeaderText(
            'Settings',
            fontSize: 25,
          ),
        ),


        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: EdgeInsets.all(16),

            decoration: BoxDecoration( 
              color: PreferencesProvider.getColor(context, 'table-background-color'),
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(color: Colors.grey.shade300)
            ),


            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,

              child: Column(  
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
            
                children: [
            
                  buildSettingsTitle(icon: Icons.calendar_month, title: 'Academic Calendar'),
                  const SizedBox(height: 8,),


                  CustomText(
                    'Helps to retrieve information related to the current academic calendar (the academic year and semester)'
                  ),


                  const SizedBox(height: 8,),


                  CustomText(
                    'Current Year',
                    fontWeight: FontWeight.w600,
                  ),

                  const SizedBox(height: 8,),

                  CustomTextField(
                    controller: academicYearController,
                    enabled: false,
                    hintText: 'Current Academic year',
                  ),

                  const SizedBox(height: 8),
                  
                  
                  if(Provider.of<SelcProvider>(context).currentAcademicYear < DateTime.now().year) CustomButton.withText(
                    'Update Year',
                    onPressed: () => setState(() {


                      //INFO: when the academic year changes to use the two-year system, changes semester, we'll have to use the start-end date to update the academic calendar info.
                      
                      //set the academic year to the current academic year.
                      academicYearController.text = DateTime.now().year.toString();

                      //change the semester to one.
                      semesterController.value = 1;

                    }),
                  ),


                  const SizedBox(height: 8,),


                  CustomText(
                    'Current Semester',
                    fontWeight: FontWeight.w600,
                  ),


                  if(Provider.of<SelcProvider>(context).user.userRole != UserRole.SUPERUSER) const SizedBox(height: 8),

                  if(Provider.of<SelcProvider>(context).user.userRole != UserRole.SUPERUSER) CustomText(
                    'NB: These fields are editable by superusers only'
                  ),

                  const SizedBox(height: 8,),

                  //todo: the dropdown button for selecting the current academic semester
                  //this field only editable for only superusers.
                  IgnorePointer(
                    ignoring: Provider.of<SelcProvider>(context).user.userRole != UserRole.SUPERUSER,
                    child: CustomDropdownButton<int>(
                      controller: semesterController,
                      hint: 'Select academic semester',
                      items: [1, 2],
                      onChanged: (newValue) => setState((){}) //todo: just update the semester visually 
                    ),
                  ),





                  const SizedBox(height: 8),

                  //todo: administrator should be able to set start and end date for every semester.
                  buildStartEndDate(),




                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),



                  ListTile(  

                    title: CustomText(
                      'Accept Evaluations',
                      fontWeight: FontWeight.w600,
                    ), 

                    subtitle: CustomText(  
                      'Choose whether to open or lock the students\' evaluations portal.'
                      '\nWhen disabled, evaluation is locked.'
                    ),


                    trailing: IgnorePointer(  
                      ignoring: Provider.of<SelcProvider>(context).user.userRole != UserRole.SUPERUSER,
                      child: Switch(  
                        value: Provider.of<SelcProvider>(context).enableEvaluations,
                        activeTrackColor: Colors.green.shade400,
                        onChanged: (newValue){
                          isDisableEvaluations = newValue;
                          handleUpdateSetting();
                        }, 
                      )
                    ),

                  ),
                  


                  if(!kIsWeb)Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),


                  //todo: data download path.
                  //show this widget when running in a native linux or windows
                  if(!kIsWeb) buildDownloadSection(),



                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),



                  buildSettingsTitle(icon: Icons.brightness_4_outlined, title: 'Appearance'),


                  const SizedBox(height: 8,),

                  CustomText(  
                    'Font Scaling',
                    fontWeight: FontWeight.w600,
                  ),


                  CustomText(
                    'Drag the slider below to increase or decrease the font size of the application'
                  ),

                  const SizedBox(height: 8,),

                  Slider(
                    value: Provider.of<PreferencesProvider>(context).preferences.fontScale / 0.5,
                    thumbColor: Colors.green.shade400,
                    activeColor: Colors.green.shade300,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    onChanged: (newValue) => preferencesProvider.setFontScale(newValue.toInt() * 0.5)
                  ),

                  const SizedBox(height: 8),


                  ListTile(
                    leading: Icon(CupertinoIcons.moon, size: 25, color: Colors.green.shade400,),
                    title: CustomText('Dark Mode', fontWeight: FontWeight.w600,),
                    subtitle: CustomText('Toggle dark mode on or off....Dark mode helps to reduce eye strain while using the application in dark conditions'),
                    trailing: Switch(  
                      value: Provider.of<PreferencesProvider>(context).preferences.darkMode,
                      onChanged: (newValue) => preferencesProvider.setDarkMode(newValue),
                      activeTrackColor: Colors.green.shade400,
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),


                  buildAboutSection()
            
                ],
              ),
            ),
          ),
        ),



        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomText(
            'Powered by: Quality Assurance And Academic Planning Directorate'
          ),
        )

      ],

    );
  }



  Column buildDownloadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        
        buildSettingsTitle(icon: Icons.download, title: 'Download Settings'),
        
        const SizedBox(height: 8),
        
        CustomText('Change the download destination for files'),
        
        const SizedBox(height: 8,),
        
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: RichText(
            text: TextSpan(
              text: 'Current Destination:  ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: PreferencesProvider.getColor(context, 'text-color')
              ),
          
              children: [
                TextSpan(
                  text: Provider.of<PreferencesProvider>(context).preferences.defaultDownloadDirectory,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                    color: Colors.green.shade400,
                    fontSize: 15
                  )
                )
              ]
            )
          ),
        ),


        const SizedBox(height: 8),
    
        //todo: the change button.
        CustomButton.withText('Change Destinations', onPressed: handleChangeDestinationPressed),

      ],
    );
  }



  //todo: build about section
  Column buildAboutSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSettingsTitle(icon: Icons.info, title: 'About'),
        
        const SizedBox(height: 8,),
        
        CustomText('SELC ADMIN is an part of a software suite for analytics of Students evaluation of lecturers and courses a the University of Science and Technology.'),
        
        const SizedBox(height: 8,),
        
        
        CustomText(
          'For technical support and assistance contact: ',
          fontWeight: FontWeight.w600,
        ),
        
        const SizedBox(height: 8,),
        
        buildContactText(icon: Icons.email, detail: 'quinsefalloyd@gmail.com'),
        
        const SizedBox(height: 8,),
        
        
        buildContactText(icon: Icons.chat_bubble, detail: '+233 50 072 1537'),
      ],
    );
  }



  Widget buildSettingsTitle({required IconData icon, required String title}){
    return Row(   
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Icon(icon, color: Colors.green.shade400,),


        const SizedBox(width: 5,),

        CustomText(  
          title, 
          fontWeight: FontWeight.w700,
          fontSize: 16,
          textColor: Colors.green.shade400,
        )
      ],
    );
  }


  Widget buildContactText({required IconData icon, required String detail}){
    return Row(  
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.green.shade400, size: 20,),

        const SizedBox(width: 8,),

        CustomText(
          detail
        )
      ],
    );
  }



  //TODO: fix this later.
  Widget buildStartEndDate(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [


        CustomText('Start Date: '),


        TextButton(
          onPressed: (){}, //show time start date
          child: CustomText(DateTime.now().toString(), textColor: Colors.green.shade400, fontWeight: FontWeight.w600,),
        ),



        CustomText('End Date: '),

        TextButton(
          onPressed: (){}, //show time start date
          child: CustomText(DateTime.now().toString(), textColor: Colors.green.shade400, fontWeight: FontWeight.w600,),
        ),

      ]
    );
  }





  void handleUpdateSetting() async {

    try{

      final generalSetting = GeneralSetting( 
        currentSemester: semesterController.value!,
        academicYear: DateTime.now().year,
        disableEvaluations: isDisableEvaluations
      );
    
      await Provider.of<SelcProvider>(context, listen:false).updateGeneralSetting(generalSetting);

    }catch(e){
      showToastMessage(context, 'Could not update general setting to the database. please try again.');
    }
    

  }




  void handleChangeDestinationPressed() async {

    final directory = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select Directory', lockParentWindow: true);

    if(directory == null) return;

    //todo: update the default file directory
    Provider.of<PreferencesProvider>(context, listen: false).setDefaultDownloadPath(directory);

  }
}