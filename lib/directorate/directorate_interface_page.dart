

//this part aids in pulling data from the I.T directorate of UENR
import 'package:flutter/material.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/server_connector.dart';
import 'package:selc_admin/components/text.dart';

class DirectorateInterfacePage extends StatefulWidget {
  const DirectorateInterfacePage({super.key});

  @override
  State<DirectorateInterfacePage> createState() => _DirectorateInterfacePageState();
}

class _DirectorateInterfacePageState extends State<DirectorateInterfacePage> {

  final WebSocketService websocketService = WebSocketService(consumerEndpoint: ''); //the endpoint will be determined later.

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          HeaderText('External Data Collector'),

          NavigationTextButtons(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  CustomText(
                    'This part of the application aids in getting the current '
                    'data on various schools, departments, lecturers, course assignments, '
                    'students, and students course registrations'
                  ),

                  //todo: everything else will come here.
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}


//connect to the backend via the OAuth Credentials
//obtain the data
//store in a file (either excel or json)
//send the file to the backend
//save the data to the backend.

