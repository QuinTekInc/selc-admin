
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/components/button.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';
import  'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/components/utils.dart' show generatePassword;

class AddUserScreen extends StatefulWidget {

  final User? user;
  final bool inEditMode;

  const AddUserScreen({super.key, this.user, this.inEditMode = false});

  factory AddUserScreen.openEdit({required User user}) => AddUserScreen(user: user, inEditMode: true,);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();

  //the default role assigned to any new user from this panel is 'admin'
  final roleController = DropdownController<String>(value: 'Admin');


  bool hasVerified = false;


  final List<String> roles = ['Superuser', 'Admin'];


  @override
  void initState() {

    if(widget.inEditMode){

      firstNameController.text = widget.user!.firstName!;
      lastNameController.text = widget.user!.lastName!;
      emailController.text = widget.user!.email!;
      usernameController.text = widget.user!.username!;
    }


    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.all(16),
      
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText('Add User', fontSize: 25,),

          NavigationTextButtons(),

          Expanded(  
            child: Center(

              child: Container(  
                width: MediaQuery.of(context).size.width * 0.45,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: PreferencesProvider.getColor(context, 'table-background-color'),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26)
                ),


                child: Column(  
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,

                 

                  children: [

                    Center(
                      child: CustomText(
                        'Fill in the fields below with the necessary data to create a user',
                        textAlignment: TextAlign.center,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12,),

                    CustomTextField(
                      controller: firstNameController,
                      hintText: 'First Name',
                      leadingIcon: CupertinoIcons.person,
                    ),

                    SizedBox(height: 8,),

                    CustomTextField(
                      controller: lastNameController,
                      hintText: 'Last Name',
                      leadingIcon: CupertinoIcons.person,
                    ),

                  

                    SizedBox(height: 8,),

                    CustomText(
                      'Make sure to enter the right email address of the intended user; as created account information is sent to user via  email to the specified address'
                    ),

                    const SizedBox(height: 8,),

                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      leadingIcon: CupertinoIcons.envelope,
                    ),

                    SizedBox(height: 8,),

                    CustomText('NOTE THAT: The username should be unique'),

                    const SizedBox(height: 8,),

                    CustomTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      leadingIcon: CupertinoIcons.person,
                    ),


                    SizedBox(height: 8,),

                    CustomDropdownButton<String>(
                      controller: roleController, 
                      hint: 'User Role',
                      items: roles, 
                      onChanged: (newValue){}
                    ),


                    const SizedBox(height: 8,),

                    Divider(),

                    const SizedBox(height: 8),


                    Center(  
                      child: CustomCheckBox(
                        value: hasVerified, 
                        text: 'I have verified the data provided',
                        onChanged: (newValue) => setState(() => hasVerified = !hasVerified)
                      ),
                    ),


                    CustomButton.withText(
                      'Create User',
                      disable: !hasVerified,
                      width: double.infinity,
                      onPressed: handleCreateUser
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





  void handleCreateUser() async {

    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String email = emailController.text;
    String username = usernameController.text;

    String password = generatePassword();

    String role = roleController.value!.toLowerCase();

    //build a user map
    Map<String, String> userMap = {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'password': password,
      'role': role
    };


    try{

      //todo: function to create the user object.
      await Provider.of<SelcProvider>(context, listen: false).createUser(userMap);

      Provider.of<PageProvider>(context, listen: false).popPage();

    }on SocketException catch (_){

      showNoConnectionAlertDialog(context);
      

    } on Error catch(_){

      showCustomAlertDialog(
        context, 
        title: 'Error', 
        contentText: 'An unexpected error occurred. Please try again!'
      );
    }

  }

}