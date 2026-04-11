
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/utils.dart';
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


  SelcProvider? _selcProvider;
  SelcProvider get selcProvider => _selcProvider!;

  final semesterController = DropdownController<int>();
  final academicYearController = TextEditingController();

  final dateTextController = TextEditingController();

  bool isDisableEvaluations = false;
  bool isSuperuser = false;

  bool isCalendarFieldEnabled = false;


  DateTime? semesterEndDate;

  @override
  void initState() {

    _selcProvider = Provider.of<SelcProvider>(context, listen: false);

    isSuperuser  = selcProvider.user.userRole == UserRole.SUPERUSER;

    isDisableEvaluations = selcProvider.enableEvaluations;

    semesterController.value = selcProvider.generalSetting.currentSemester;

    academicYearController.text = selcProvider.generalSetting.academicYear.toString();

    semesterEndDate = selcProvider.generalSetting.semesterEndDate;
  
    dateTextController.text = semesterEndDate != null ? formatDate(semesterEndDate!) : 'Not Set';

  
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

                  if(isSuperuser) buildAcademicCalendarSection(),


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


                  buildAppearanceSection(),


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




  Widget buildAcademicCalendarSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [

        Row(
          children: [
            buildSettingsTitle(icon: Icons.calendar_month, title: 'Academic Calendar'),

            Spacer(), 


            TextButton.icon(

              icon: Icon(Icons.update, color: Colors.green.shade400,),

              label: CustomText(
                'Update Academic Calendar',
                textColor: Colors.green.shade400,
                fontSize: 15,
              ),

              onPressed: () => setState(() {
                //INFO: when the academic year changes to use the two-year system, changes semester, we'll have to use the start-end date to update the academic calendar info.
                
                //set the academic year to the current academic year.
                // if(semesterController.value == 2){
                //   academicYearController.text = DateTime.now().year.toString();
                // }

                semesterController.value = semesterController.value == 2 ? 1 : 2;
                
                showCustomAlertDialog(  
                  context, 
                  title: 'Update Calendar',
                  contentText: 'You will have to update the "Semester End Date" before you save. \n'
                    'You can update the Semester End Date by clicking on the green text button blow the semester entry'
                );

              }),
            ),
          ],
        ),


        
        CustomText(
          'Helps to retrieve information related to the current academic calendar (the academic year and semester)'
        ),


        RichText(
          text: TextSpan( 
            text: 'Note: ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: PreferencesProvider.getColor(context, 'text-color')
            ),
            children: [
              TextSpan(
                text: 'Only superusers can edit these fields.',
                style: TextStyle( 
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  color: Colors.red.shade400,
                  fontSize: 13
                )
              )
            ]
          )
        ),


        CustomCheckBox(
            value: isCalendarFieldEnabled,
            text: 'Enable Editing',
            onChanged: (newValue) => setState(() => isCalendarFieldEnabled = newValue!)
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            CustomText(
              'Current Academic Year',
              fontWeight: FontWeight.w600,
            ),


            Expanded(
              child: CustomTextField(
                controller: academicYearController,
                enabled: isCalendarFieldEnabled,
                hintText: 'Current Academic year',
              ),
            ),



            CustomText(
              'Current Semester',
              fontWeight: FontWeight.w600,
            ),


            //todo: the dropdown button for selecting the current academic semester
            //this field only editable for only superusers.
            Expanded(
              child: IgnorePointer(
                ignoring: !isCalendarFieldEnabled,
                child: CustomDropdownButton<int>(
                  controller: semesterController,
                  hint: 'Select academic semester',
                  items: [1, 2],
                  onChanged: (newValue) => setState((){}) //todo: just update the semester visually
                ),
              ),
            ),
          ],
        ),



        //tood: widget to send the date for a semester


        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,

          children: [

            CustomText(
              'Semester End Date: ',
              fontWeight: FontWeight.w600,
            ),

            SizedBox(  
              width: MediaQuery.of(context).size.width * 0.2,
              child: CustomTextField(  
                controller: dateTextController,
                enabled: false,
                hintText: 'Semester End date',
              )
            ),
            
            
            IgnorePointer(  
              ignoring: !isCalendarFieldEnabled,
              child: IconButton(
                icon: Icon(Icons.calendar_month_outlined, color: Colors.green.shade400,),
                tooltip: 'Click to change date',
                onPressed: () async {
                  semesterEndDate = await showDatePicker(
                    context: context, 
                    initialDate: semesterEndDate ?? DateTime.now(), 
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)), 
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    helpText: 'Select the date the current semester will end.'
                  );
            
                  setState((){
                    dateTextController.text = formatDate(semesterEndDate!);
                  });
                }, //show time start date
              ),
            ),
          ],
        ),


        //todo: button to update the academic calendar settings
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton.withText(
            'Update Calendar Settings',
            onPressed: handleUpdateCalendarSetting,
          ),
        )
      ],
    );
  }



  Widget buildDownloadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        
        buildSettingsTitle(icon: Icons.download, title: 'Download Settings'),
        
        CustomText('Change the download destination for files'),
        
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
    
        //todo: the change button.
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton.withText(
            'Change Destination',
            onPressed: handleChangeDestinationPressed
          )
        ),

      ],
    );
  }



  Widget buildAppearanceSection(){
    return Column(   
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [   

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

      ]
    );
  }


  //todo: build about section
  Column buildAboutSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [

        buildSettingsTitle(icon: Icons.info, title: 'About'),
        
        CustomText('SELC ADMIN is an part of a software suite for analytics of Students evaluation of lecturers and courses a the University of Science and Technology.'),

        CustomText(
          'For technical support and assistance contact: ',
          fontWeight: FontWeight.w600,
        ),
        
        //todo: the information should come from a .env file
        buildContactText(icon: Icons.email, detail: 'quinsefalloyd@gmail.com'),
        
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
  // Widget buildStartEndDate(){
  //
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     spacing: 8,
  //     children: [
  //
  //       CustomText('Start Date: '),
  //
  //       TextButton(
  //         onPressed: (){}, //show time start date
  //         child: CustomText(DateTime.now().toString(), textColor: Colors.green.shade400, fontWeight: FontWeight.w600,),
  //       ),
  //
  //
  //       CustomText('End Date: '),
  //
  //       TextButton(
  //         onPressed: (){}, //show time start date
  //         child: CustomText(DateTime.now().toString(), textColor: Colors.green.shade400, fontWeight: FontWeight.w600,),
  //       ),
  //
  //     ]
  //   );
  // }
  //




  void handleUpdateCalendarSetting() async {

    try{

      final generalSetting = GeneralSetting( 
        currentSemester: semesterController.value!,
        academicYear: academicYearController.text,
        enableEvaluations: isDisableEvaluations,
        semesterEndDate: semesterEndDate
      );
    
      await Provider.of<SelcProvider>(context, listen:false).updateGeneralSetting(generalSetting);
      
      showCustomAlertDialog( 
        context, 
        alertType: AlertType.success,
        title: 'Success',
        contentText: 'Calendar parameters has been updated to the database'
      );
      
      setState(() => isCalendarFieldEnabled = false);

    }catch(e){

      debugPrint(e.toString());

      showCustomAlertDialog(
        context,
        alertType: AlertType.warning,
        title: 'Update Error',
        contentText: 'Could not update general setting to the database. please try again.'
      );
    }
  
  }



  void handleChangeDestinationPressed() async {

    final directory = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select Directory', lockParentWindow: true);

    if(directory == null) return;

    //todo: update the default file directory
    Provider.of<PreferencesProvider>(context, listen: false).setDefaultDownloadPath(directory);

  }
}