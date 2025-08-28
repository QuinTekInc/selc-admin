


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selc_admin/components/alert_dialog.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';
import 'package:selc_admin/model/models.dart';
import 'package:selc_admin/pages/user_management/add_user_page.dart';
import 'package:selc_admin/pages/user_management/user_profile_page.dart';
import 'package:selc_admin/providers/page_provider.dart';
import 'package:selc_admin/providers/pref_provider.dart';
import 'package:selc_admin/providers/selc_provider.dart';


class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  final searchController = TextEditingController();
  List<User> filteredUsers = [];

  bool isLoading = false;


  @override
  void initState() {
    super.initState();

    loadUsersData();
    
  }


  void loadUsersData() async {

    setState(() => isLoading = true);

    try{
      await Provider.of<SelcProvider>(context, listen:false).getUsers();
      filteredUsers = Provider.of<SelcProvider>(context, listen: false).users;
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
                  controller: searchController,
                  hintText: 'Search Users',
                  leadingIcon: Icons.search,
                  onChanged: (newValue) => handleFilter()
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


          const SizedBox(height: 12,),


          Expanded(
            child: Container(  
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(8),


              decoration: BoxDecoration(
                color: PreferencesProvider.getColor(context, 'table-background-color'),
                borderRadius: BorderRadius.circular(12),
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
                  else if(!isLoading && filteredUsers.isEmpty) Expanded(  
                    child: CollectionPlaceholder( title: 'No Data!', detail: 'All Administrative users appear here.'),
                  )
                  else Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (_, index) => UserManagementRow(user: filteredUsers[index]),
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
        color: PreferencesProvider.getColor(context, 'alt-primary-color'),
        borderRadius: BorderRadius.circular(12),
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


  void handleFilter(){

    if(searchController.text.isEmpty){
      setState(() => filteredUsers = Provider.of<SelcProvider>(context, listen: false).users);

      return;
    }


    String searchText = searchController.text.toLowerCase();

    filteredUsers = filteredUsers.where((user) =>
        user.username!.toLowerCase().contains(searchText) || '${user.firstName} ${user.lastName}'.toLowerCase().contains(searchText))
        .toList();

    setState((){});

  }
}







class UserManagementRow extends StatefulWidget {

  final User user;
  const UserManagementRow({super.key, required this.user});

  @override
  State<UserManagementRow> createState() => _UserManagementRowState();
}

class _UserManagementRowState extends State<UserManagementRow> {

  Color backgroundColor = Colors.transparent;


  bool isCurrentUser = false;

  @override
  void initState() {
    // TODO: implement initState

    isCurrentUser = widget.user == Provider.of<SelcProvider>(context, listen: false).user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(

      onHover: (mouseEvent) => setState(() => backgroundColor = Theme.of(context).brightness == Brightness.dark ? Colors.green.shade300 :  Colors.green.shade100),
      onExit: (mouseEvent) => setState(() => backgroundColor = Colors.transparent),

      child: GestureDetector(

        onTap: () => isCurrentUser ? null : Provider.of<PageProvider>(context, listen:false).pushPage(UserProfilePage(user: widget.user), 'User Profile'),

        child: Container(

          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),

          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12)
          ),

          child:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              //todo: uername of the user
              Expanded(
                child: !isCurrentUser ?  CustomText(
                    widget.user.username!
                ) : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [

                    CircleAvatar(
                      backgroundColor: roleColor(widget.user.isSuperuser),
                      radius: 5,
                    ),

                    const SizedBox(width: 8),

                    CustomText(
                        widget.user.username!
                    )
                  ],
                ),
              ),


              //todo: first name of the user
              Expanded(
                child: CustomText(
                    widget.user.firstName!
                ),
              ),


              //todo: last name of the user
              Expanded(
                flex: 2,
                child: CustomText(
                    widget.user.lastName!
                ),
              ),



              //todo: email of the user.
              Expanded(
                child: CustomText(
                    widget.user.email!
                ),
              ),



              //todo: role of the user in the system.
              Expanded(
                child: CustomText(
                  widget.user.isSuperuser ? 'Super User' : 'Admin/Staff',
                  textColor: roleColor(widget.user.isSuperuser),
                  fontWeight: FontWeight.w600,
                  textAlignment: TextAlign.center,
                ),
              )

            ],
          ),
        )
      )
    );
  }



  Color roleColor(bool isSuperUser){
    return isSuperUser ? Colors.green.shade400 : Colors.blue.shade400;
  }
}








