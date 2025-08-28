
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [

          HeaderText('My Profile', fontSize: 25,),

          NavigationTextButtons(),


          const SizedBox(height: 12,),

          Expanded(
            child: SingleChildScrollView(
              child: Center(

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    //showing some personal information of the current user.

                    Container(

                      padding: EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 12),
                      width: MediaQuery.of(context).size.width * 0.4,

                      decoration: BoxDecoration(
                        //Colors.grey.shade200
                        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                        borderRadius: BorderRadius.circular(12)
                      ),


                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.green.shade400,
                              radius: 80,
                              child: Icon(CupertinoIcons.person, color: Colors.white, size: 80,),
                            ),
                          ),


                          const SizedBox(height: 24,),

                          DetailContainer(
                            title: 'Full Name',
                            detail: Provider.of<SelcProvider>(context).user.fullName()
                          ),

                          const SizedBox(height: 12,),

                          DetailContainer(
                            title: 'Username',
                            detail: Provider.of<SelcProvider>(context).user.username!
                          ),

                          const SizedBox(height: 12,),

                          DetailContainer(
                            title: 'Email',
                            detail: Provider.of<SelcProvider>(context).user.email!
                          ),


                          const SizedBox(height: 12,),

                          DetailContainer(
                            title: 'Role',
                            detail: Provider.of<SelcProvider>(context).user.isSuperuser ? "Superuser" : "Admin"
                          ),

                        ],
                      ),
                    ),


                    const SizedBox(height: 12,),

                    //todo: stuff to contain information
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        //Colors.grey.shade200
                        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                        borderRadius: BorderRadius.circular(12)
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,

                        children: [

                          HeaderText(
                            'Edit Personal Information',
                            fontSize: 16,
                          ),


                          const SizedBox(height: 16,),

                          ClickableMenuItem(
                            title: 'Edit Full Name',
                            icon: CupertinoIcons.person,
                            onPressed: () => showCustomModalBottomSheet(context: context, child: EditNameSheet())
                          ),

                          const SizedBox(height: 8,),


                          ClickableMenuItem(
                            title: 'Change E-mail',
                            icon: CupertinoIcons.envelope_badge,
                            iconBackgroundColor: Colors.deepOrangeAccent,
                            onPressed: () => showCustomModalBottomSheet(context: context, child: EditEmailSheet())
                          ),


                          const SizedBox(height: 8,),


                          ClickableMenuItem(
                            title: 'Change Password',
                            icon: CupertinoIcons.lock,
                            iconBackgroundColor: Colors.deepPurpleAccent,
                            onPressed: () => showCustomModalBottomSheet(context: context, child: ChangePasswordSheet())
                          ),


                        ],
                      ),
                    ),


                    const SizedBox(height: 12,),



                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        //Colors.grey.shade200
                        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
                        borderRadius: BorderRadius.circular(12)
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,

                        children: [

                          HeaderText(
                            'Logout',
                            fontSize: 16,
                          ),


                          const SizedBox(height: 16,),

                          ClickableMenuItem(
                            title: 'Logout',
                            icon: Icons.power_settings_new,
                            iconBackgroundColor: Colors.red.shade400,
                            onPressed: () => handleLogout(context)
                          ),

                        ],
                      ),
                    )


                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }



  //todo: implement the logging out.
  void handleLogout(BuildContext context){

  }



}







class EditNameSheet extends StatefulWidget {
  const EditNameSheet({super.key});

  @override
  State<EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<EditNameSheet> {

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();


  bool disableButton = true;


  @override
  void initState() {
    super.initState();
    
    firstNameController.text = Provider.of<SelcProvider>(context, listen: false).user.firstName!;
    lastNameController.text = Provider.of<SelcProvider>(context, listen: false).user.lastName!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 470,
      margin: const EdgeInsets.only(bottom: 12, right: 12),
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(  
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Row(
            children: [
              HeaderText('Edit Name'),

              Spacer(),

              IconButton(
                onPressed: () => Navigator.of(context).pop(), 
                icon: Icon(CupertinoIcons.clear, size: 25, color: Colors.red.shade400,)
              )
            ],
          ),

          const SizedBox(height: 12,),


          CustomText('Change your account\'s name'),


          const SizedBox(height: 8,),

          CustomTextField(  
            controller: firstNameController,
            leadingIcon: CupertinoIcons.person,
            hintText: 'Enter new first name',
            useLabel: true,
            onChanged: (newValue) => checkFields(),
          ),

          const SizedBox(height: 12,),

          CustomTextField(  
            controller: lastNameController,
            leadingIcon: CupertinoIcons.person,
            hintText: 'Enter new last name(s)',
            useLabel: true,
            onChanged: (newValue) => checkFields(),
          ),


          const SizedBox(height: 12,),


          CustomButton.withText(
            'Update', 
            disable: disableButton,
            width: double.infinity,
            onPressed: handleUpdate,
          )
        ],
      ),
    );
  }


  void checkFields(){

    bool isFieldsEmpty = firstNameController.text.isEmpty || lastNameController.text.isEmpty;
      bool hasValuesChanged = firstNameController.text == Provider.of<SelcProvider>(context, listen: false).user.firstName! 
                              && lastNameController.text == Provider.of<SelcProvider>(context, listen: false).user.lastName!;
    setState(() {
      disableButton = isFieldsEmpty || hasValuesChanged;
    });
  }


  //todo: implement updating the user's account name.
  void handleUpdate() async {

    showDialog(  
      context: context,
      builder: (_) => LoadingDialog()
    );


    try{

      await Provider.of<SelcProvider>(context, listen:false).updateAccountInfo({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text
      });
     
      Navigator.pop(context); //close the alert dialog.
      Navigator.pop(context); //close the current model sheet itself.

    }on SocketException{
      Navigator.pop(context); //close the alert dialog.
      showNoConnectionAlertDialog(context);
    }on Error{
      Navigator.pop(context); //close the alert dialog
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred');
    }

  }
}








class EditEmailSheet extends StatefulWidget {
  const EditEmailSheet({super.key});

  @override
  State<EditEmailSheet> createState() => _EditEmailSheetState();
}

class _EditEmailSheetState extends State<EditEmailSheet> {

  final emailController = TextEditingController();


  bool disableButton = true;


  @override
  void initState() {
    super.initState();
    
    emailController.text = Provider.of<SelcProvider>(context, listen: false).user.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 470,
      margin: const EdgeInsets.only(bottom: 12, right: 12),
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(  
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Row(
            children: [
              HeaderText('Edit Email'),

              Spacer(),

              IconButton(
                onPressed: () => Navigator.of(context).pop(), 
                icon: Icon(CupertinoIcons.clear, size: 25, color: Colors.red.shade400,)
              )
            ],
          ),

          const SizedBox(height: 12,),


          CustomText('Change your account\'s email with a new and valid email address.'),


          const SizedBox(height: 8,),

          CustomTextField(  
            controller: emailController,
            leadingIcon: CupertinoIcons.envelope,
            hintText: 'New email',
            useLabel: true,
            onChanged: (newValue) => checkFields(),
          ),

          

          const SizedBox(height: 12,),


          CustomButton.withText(
            'Update', 
            disable: disableButton,
            width: double.infinity,
            onPressed: handleUpdate,
          )
        ],
      ),
    );
  }


  void checkFields(){

    bool isFieldsEmpty = emailController.text.isEmpty;
    bool hasValuesChanged = emailController.text == Provider.of<SelcProvider>(context, listen: false).user.email!;
    setState(() {
      disableButton = isFieldsEmpty || hasValuesChanged;
    });
  }



  //todo: implement updating email
  void handleUpdate() async {

    showDialog(  
      context: context,
      builder: (_) => LoadingDialog()
    );

    try{

      await Provider.of<SelcProvider>(context, listen:false).updateAccountInfo({
        'email': emailController.text,
      });
     
      Navigator.pop(context); //close the alert dialog.
      Navigator.pop(context); //close the current model sheet itself.

    }on SocketException{
      Navigator.pop(context); //close the alert dialog.
      showNoConnectionAlertDialog(context);
    }on Error{
      Navigator.pop(context); //close the alert dialog
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred');
    }

  }
}












class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  bool disableButton = true;
  bool isPasswordsNotMatch = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 470,
      margin: const EdgeInsets.only(bottom: 12, right: 12),
      decoration: BoxDecoration(
        color: PreferencesProvider.getColor(context, 'primary-color'),
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(  
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Row(
            children: [
              HeaderText('Change Password'),

              Spacer(),

              IconButton(
                onPressed: () => Navigator.of(context).pop(), 
                icon: Icon(CupertinoIcons.clear, size: 25, color: Colors.red.shade400,)
              )
            ],
          ),

          const SizedBox(height: 12,),


          CustomText('Change your account\'s password by entering your old password.'),


          const SizedBox(height: 8,),

          CustomTextField(  
            controller: oldPasswordController,
            leadingIcon: CupertinoIcons.lock,
            obscureText: true,
            hintText: 'Old Password',
            useLabel: true,
            onChanged: (newValue) => checkFields(),
          ),


          const SizedBox(height: 8,),

          CustomText('Enter a new strong password'),
  

          const SizedBox(height: 12,),

          CustomTextField(  
            controller: newPasswordController,
            leadingIcon: CupertinoIcons.lock,
            obscureText: true,
            hintText: 'New Password',
            useLabel: true,
            onChanged: (newValue) => checkFields(),
          ),


          const SizedBox(height: 12,),


          CustomTextField(  
            controller: confirmPasswordController,
            leadingIcon: CupertinoIcons.lock,
            obscureText: true,
            hintText: 'Confirm New Password',
            useLabel: true,
            onChanged: (newValue) => checkFields(),
          ),


          if(isPasswordsNotMatch)Column(  
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8,),

              CustomText(
                'The new passwords do not match.',
                textColor: Colors.red.shade400,
              )
            ],
          ),


          const SizedBox(height: 12,),


          CustomButton.withText(
            'Update', 
            disable: disableButton,
            width: double.infinity,
            onPressed: handleUpdate,
          )
        ],
      ),
    );
  }


  void checkFields(){

    bool isFieldsEmpty = oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty;
    isPasswordsNotMatch = confirmPasswordController.text != newPasswordController.text;
                             
    setState(() {
      disableButton = isFieldsEmpty || isPasswordsNotMatch;
    });
  }




  //todo: implement updating password.
  void handleUpdate() async {

    showDialog(  
      context: context, 
      builder: (_) => LoadingDialog()
    );

    try{
      await Provider.of<SelcProvider>(context, listen: false).updateAccountInfo(
        {
          'old_password': oldPasswordController.text,
          'new_password': newPasswordController.text,
        }
      );

      Navigator.pop(context); //closes the alert dialog
      Navigator.pop(context); //closes the bottom sheet.
    }on Socket{
      Navigator.pop(context); //close te loading dialog
      showNoConnectionAlertDialog(context);
    }on Error{
      Navigator.pop(context); //also cloeses
      showCustomAlertDialog(
        context, 
        title: 'Error', 
        contentText: 'An Unexpected Error occured.'
      );
    }on Exception catch(e){
      Navigator.pop(context); //closes the loading dialog
      showCustomAlertDialog(
        context, 
        title: 'Error', 
        contentText: e.toString()
      );
    }

  }
}

