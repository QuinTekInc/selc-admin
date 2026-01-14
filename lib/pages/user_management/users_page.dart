


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
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
  final roleFilterController = RoleFilterController();

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

              Expanded(  
                flex: 1,
                child: CustomTextField(  
                  controller: searchController,
                  hintText: 'Search Users',
                  leadingIcon: Icons.search,
                  onChanged: (newValue) => handleFilter()
                ),
              ),


              Expanded(
                flex: 2,
                child: UserFilterSection(  
                  controller: roleFilterController,
                  onChanged: (filters){
                    setState((){

                      if(filters.isEmpty) return;

                      if(searchController.text.isEmpty){
                        filteredUsers = Provider.of<SelcProvider>(context, listen: false).users.where(
                          (user) => filters.contains(user.userRole)).toList();
                      }else{
                        filteredUsers = filteredUsers.where((user) => filters.contains(user.userRole)).toList();
                      }
                    });
                  },
                )
              ),



              CustomButton.withIcon(
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

      if(roleFilterController.filters.isEmpty){
        setState(() => filteredUsers = Provider.of<SelcProvider>(context, listen: false).users);
      }else{
        filteredUsers = Provider.of<SelcProvider>(context, listen: false).users.where(
          (user) => roleFilterController.filters.contains(user.userRole)
        ).toList();
      }

      
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
                      backgroundColor: roleColor(widget.user.userRole),
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
                  widget.user.userRole.roleString,
                  textColor: roleColor(widget.user.userRole),
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



  Color roleColor(UserRole userRole){
    switch(userRole){
      case UserRole.SUPERUSER:
        return Colors.green.shade400;

      case UserRole.ADMIN:
        return Colors.blue.shade400;


      case UserRole.LECTURER:
        return Colors.cyan;


      case UserRole.STUDENT:
      default:
        return Colors.amber.shade400;
    }
  }
}










class UserFilterSection extends StatefulWidget {

  final RoleFilterController controller;
  final void Function(List<UserRole>) onChanged;

  const UserFilterSection({super.key, required this.controller, required this.onChanged});

  @override
  State<UserFilterSection> createState() => _UserFilterSectionState();
}

class _UserFilterSectionState extends State<UserFilterSection> {

  final userRoles = UserRole.values;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration( 
        borderRadius: BorderRadius.circular(12),
        color: PreferencesProvider.getColor(context, 'alt-primary-color')
      ),
      child: Row(  
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
    
          Icon(  
            CupertinoIcons.color_filter,
            size: 35,
            color: Colors.green.shade400
          ),
    
          CustomText(  
            'Filter By: ',
            fontWeight: FontWeight.w600,
          ),

          for(UserRole userRole in userRoles) buildRoleChip(userRole)
    
        ]
      )
    );
  }



  Widget buildRoleChip(UserRole userRole){

    bool containsRole = widget.controller.contains(userRole);

    return GestureDetector(
      onTap: (){ 

        if(!containsRole) {
          widget.controller.add(userRole);
          containsRole = true;
        } else {
          widget.controller.remove(userRole);
          containsRole = false;
        }

        widget.onChanged(widget.controller.filters);

        setState((){});
      },
      child: Container(

        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,

        decoration: BoxDecoration( 
          color: containsRole ? Colors.green : PreferencesProvider.getColor(context, 'alt-primary-color-2'),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 0.5, 
            color: containsRole ? Colors.white : PreferencesProvider.getColor(context, 'placeholder-text-color'),
          )
        ),

        child: CustomText(
          formatRoleString(userRole.roleString),
          textColor: containsRole ? Colors.white : null,
          fontSize: 12,
        ),
      ),
      
    );
  }


  String formatRoleString(String roleString){
    final firstLetter = roleString[0].toUpperCase();
    return '$firstLetter${roleString.substring(1)}';
  }
}



class RoleFilterController{

  final List<UserRole> filters = [];

  bool contains(UserRole userRole) => filters.contains(userRole);

  void add(UserRole userRole) {

    if(filters.contains(userRole)) return;

    filters.add(userRole);
  }

  void remove(UserRole userRole) => filters.remove(userRole);

  void clear(){
    filters.clear();
  }
}

