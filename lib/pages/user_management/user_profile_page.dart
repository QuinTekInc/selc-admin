

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/cells.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class UserProfilePage extends StatefulWidget {

  final User user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  
  final roleController = DropdownController<String>();
  bool isUserActive = true;

  @override
  void initState() {
    super.initState();
    roleController.value = widget.user.isSuperuser ? "Superuser" : "Admin";
    isUserActive = widget.user.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          HeaderText('${widget.user.username}\'s Profile'),

          NavigationTextButtons(),

          const SizedBox(height: 12,),


          Expanded(  
            child: Center(
              child: SingleChildScrollView(
                child: Column(  
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
              
                  children: [
              
                    //todo: a pane showing the user's details.
                    builderUserDetailSection(context),

                    const SizedBox(height: 12,),


                    Container(  
                      padding: EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),


                      child: Column(  
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,

                        children: [

                          HeaderText(
                            'Edit User Info',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),

                          const SizedBox(height: 12,),


                          ClickableMenuItem(
                            title: 'Deactivate or activate user account', 
                            subtitle: 'Deactiving user\'s account prevents them  from accessing the application',
                            icon: Icons.power_settings_new_outlined,
                            iconBackgroundColor: widget.user.isActive ? Colors.red.shade400 : Colors.blue.shade600,
                            trailing: Switch(  
                              value: isUserActive,
                              activeTrackColor: Colors.green.shade400,
                              onChanged: handleActiveStatusChange,
                            )
                          ),


                          const SizedBox(height: 8,),


                          ClickableMenuItem(
                            title: 'Change Role', 
                            icon: CupertinoIcons.refresh,
                            iconBackgroundColor: Colors.deepPurple.shade400,
                            subtitle: 'Change the role to give some special permissions to the user',
                            onPressed: () => showCustomModalBottomSheet(
                              context: context, 
                              child: ChangeUserRoleSheet(user: widget.user)
                            ),
                          )

                        ],
                      ),
                    ),




                    const SizedBox(height: 12,),



                    Container(  
                      padding: EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),


                      child: Column(  
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,

                        children: [

                          HeaderText(
                            'User Account Recovery',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),

                          const SizedBox(height: 8,),


                          ClickableMenuItem(
                            title: 'Reset user password', 
                            icon: CupertinoIcons.lock,
                            subtitle: 'Clicking on this button resets a user\'s account password to a default general password',
                            onPressed: (){},
                          )

                        ],
                      ),
                    ),


                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  Container builderUserDetailSection(BuildContext context) {
    return Container(  
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12)
      ),

      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,

        children: [

          CircleAvatar( 
            backgroundColor: Colors.green.shade300, 
            radius: 80,
            child: Icon(CupertinoIcons.person, size: 80, color: Colors.white,),
          ),

          const SizedBox(height: 16,),


          DetailContainer(title: 'Name', detail: '${widget.user.firstName} ${widget.user.lastName}'),

          const SizedBox(height: 8,),

          DetailContainer(title: 'Email', detail: widget.user.email!),

          const SizedBox(height: 8,),

          DetailContainer(title: 'Username', detail: widget.user.username!),

          const SizedBox(height: 8,),
          
          DetailContainer(title: 'Role', detail: widget.user.isSuperuser ? 'Superuser' : 'Admin'),

          const SizedBox(height: 12,),

          DetailContainer(title: 'Status', detail: widget.user.isActive ? 'Active' : 'Deactivated')

        ],
      ),
    );
  }





  void handleActiveStatusChange(bool? newValue) async {

    if(newValue == null) return;


    if(newValue){
      showCustomAlertDialog(
        context, 
        title: 'Enable User?', 
        contentText: 'Do you want to activate this user\'s account? \nBy doing so, they will be able to access this application',
        addDefaultButton: true,
        defaultButtonText: 'No, Cancel',
        controls: [
          TextButton(  
            child: CustomText('Yes, activate', textColor: Colors.blue.shade400, fontWeight: FontWeight.w600,),
            onPressed: () {
              Navigator.pop(context); //closes the dialog box.
              updateUserStatus(newValue);
            },
          )
        ]
      );


      return;
    }





    if(!newValue){
      showCustomAlertDialog(
        context, 
        title: 'Disable User?', 
        contentText: 'Do you want to deactivate this user\'s account? \nBy doing so, they will not be able to access this application.',
        addDefaultButton: true,
        defaultButtonText: 'No, Cancel',
        controls: [
          TextButton(  
            child: CustomText('Yes, Deactivate', textColor: Colors.red.shade400, fontWeight: FontWeight.w600,),
            onPressed: () {
              Navigator.pop(context); //closes the alert dialog box
              updateUserStatus(newValue);
            },
          )
        ]
      );
    }

  }



  void updateUserStatus(bool active) async {

    showDialog(context: context, builder: (_) => LoadingDialog());


    try{
      await Provider.of<SelcProvider>(context, listen:false).suUpdateUserAccount(
        updateMap: {'username': widget.user.username!, 'is_active': active}
      );
      Navigator.pop(context); //closes the loading dialog.
      setState(() {
        isUserActive = active;
        widget.user.isActive = active;
      });

    }on Error{
      Navigator.pop(context); //closes the current alert dialog
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred.');

    }on SocketException{
      Navigator.pop(context); //closes the current alert dialog
      showNoConnectionAlertDialog(context);
    }

  }



  void handleChangePassword(){

  }
}





class ChangeUserRoleSheet extends StatefulWidget {

  final User user;
  const ChangeUserRoleSheet({super.key, required this.user});

  

  @override
  State<ChangeUserRoleSheet> createState() => _ChangeUserRoleSheetState();
}

class _ChangeUserRoleSheetState extends State<ChangeUserRoleSheet> {


  final roleController = DropdownController<String>();
  String oldRoleValue = '';

  bool disableButton = true;

  @override
  void initState() {
    super.initState();

    oldRoleValue = widget.user.isSuperuser ? "Superuser" : 'Admin';
    
    roleController.value = widget.user.isSuperuser ? "Superuser" : 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 470,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16, right: 16),

      decoration: BoxDecoration(  
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12)
      ),


      child: Column(  
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              HeaderText('Change Role'),
              Spacer(),

              IconButton(
                onPressed: () => Navigator.pop(context), 
                icon: Icon(CupertinoIcons.xmark, color: Colors.red.shade400, size: 20,)
              )
            ],
          ), 

          const SizedBox(height: 12,),

          CustomText('Roles grant a user some level privileges to perform some functions in the application.'),

          const SizedBox(height: 8),



          CustomDropdownButton(
            controller: roleController, 
            items: ['Superuser', 'Admin'], 
            onChanged: (newValue) => setState(() => disableButton = newValue == oldRoleValue)
          ),


          const SizedBox(height: 12,),


          CustomButton.withText(
            'Update', 
            disable: disableButton,
            width: double.infinity,
            onPressed: handleUpdateUserRole
          )
        ],
      ),
    );
  }




  void handleUpdateUserRole() async {

  }
}

