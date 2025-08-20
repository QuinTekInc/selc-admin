


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/user.dart';
import 'package:selc_admin/pages/user_management/add_user_page.dart';
import 'package:selc_admin/pages/user_management/user_profile_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {


  bool isLoading = false;

  List<User> users = [];


  @override
  void initState() {
    super.initState();

    loadUsersData();
    
  }


  void loadUsersData() async {

    setState(() => isLoading = true);


    try{
      await Provider.of<SelcProvider>(context, listen:false).getUsers();
      users = Provider.of<SelcProvider>(context, listen: false).users;
    }on SocketException catch(_){
      showNoConnectionAlertDialog(context);
    }on Error catch(_){
      showCustomAlertDialog(context, title: 'Error', contentText: 'An unexpected error occurred.');
    }


    setState(() => isLoading = false);

  }


  @override
  Widget build(BuildContext context) {
    return Padding(  
      padding: const EdgeInsets.all(16),

      child: Column(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          HeaderText(
            'Users',
            fontSize: 25
          ),

          const SizedBox(height: 8),

          Row(  
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              SizedBox(  
                width: MediaQuery.of(context).size.width * 0.45,
                child: CustomTextField(  
                  controller: TextEditingController(),
                  hintText: 'Search Users',
                  leadingIcon: Icons.search
                ),
              ),


              Spacer(),



             if(Provider.of<SelcProvider>(context).user.isSuperuser) CustomButton.withIcon(
                'Add User', 
                icon: Icons.add, 
                forceIconLeading: true, 
                onPressed: () => Provider.of<PageProvider>(context, listen:false).pushPage(AddUserScreen(), "Add User"),
              ),

            ]
          ),


          const SizedBox(height: 8,),


          Expanded(
            child: Container(  
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(  
                borderRadius: BorderRadius.circular(12),
                color: Colors.white
              ),


              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //todo: the table header.
                  buildTableHeader(),


                  if(isLoading) Expanded(  
                    child: Center(  
                      child: CircularProgressIndicator(),
                    ),
                  )
                  else if(!isLoading && users.isEmpty) Expanded(  
                    child: CollectionPlaceholder( title: 'No Data!', detail: 'All Administrative users appear here.'),
                  )
                  else Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, index) => buildUserTableRow(user: users[index]),
                    )
                  )

                ],
              ),
            ),
          )

        ],
      ),
    );
  }



  Widget buildTableHeader(){
    return Container(  
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(  
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300
      ),

      child: Row( 
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [

          Expanded(
            child: CustomText('Username')
          ),

          Expanded(
            child: CustomText('First Name')
          ),

          Expanded(
            flex: 2,
            child: CustomText('Last Names')
          ),

          Expanded(
            child: CustomText('Email')
          ),

          Expanded(
            child: CustomText('Role', textAlignment: TextAlign.center)
          ),

        ],
      ),
    );
  }



  Widget buildUserTableRow({required User user}){

    bool isCurrentUser = user == Provider.of<SelcProvider>(context, listen: false).user;

    return GestureDetector(

      onTap: isCurrentUser ? null : () => Provider.of<PageProvider>(context, listen:false).pushPage(UserProfilePage(user: user), 'User Profile'),

      child: Container( 
      
        padding: const EdgeInsets.all(8),
      
        decoration: BoxDecoration(  
          
        ),
      
        child: Row(  
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, 
      
          children: [
      
            //todo: uername of the user
            Expanded(  
              child: !isCurrentUser ?  CustomText(  
                user.username!
              ) : Row(  
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
      
                children: [
      
                  CircleAvatar(  
                    backgroundColor: roleColor(user.isSuperuser),
                    radius: 5,
                  ),
      
                  const SizedBox(width: 8),
      
                  CustomText( 
                    user.username!
                  )
                ],
              ),
            ),
      
      
            //todo: first name of the user
            Expanded(  
              child: CustomText(  
                user.firstName!
              ),
            ),
      
      
            //todo: last name of the user
            Expanded(  
              flex: 2,
              child: CustomText(  
                user.lastName!
              ),
            ),
      
      
      
            //todo: email of the user.
            Expanded(  
              child: CustomText(  
                user.email!
              ),
            ),
      
      
      
            //todo: role of the user in the system.
            Expanded(  
              child: CustomText(  
                user.isSuperuser ? 'Super User' : 'Admin/Staff',
                textColor: roleColor(user.isSuperuser),
                fontWeight: FontWeight.w600,
                textAlignment: TextAlign.center,
              ),
            )
          
          ],
        ),
      ),
    );
  }



  Color roleColor(bool isSuperUser){
    return isSuperUser ? Colors.green.shade400 : Colors.blue.shade400;
  }




  // Widget buildRoleIndicator(String role){
  //   return Container(  
  //     //padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //     width: 70,
  //     height: 50,
  //     alignment: Alignment.center,

  //     constraints: BoxConstraints(maxWidth: 70),

  //     decoration: BoxDecoration(  
  //       color: Colors.green.shade200,
  //       borderRadius: BorderRadius.circular(12)
  //     ),

  //     child: CustomText(
  //       role,
  //       textColor: Colors.green,
  //       fontWeight: FontWeight.bold,
  //       fontSize: 15
  //     ),
  //   );
  // }
}







