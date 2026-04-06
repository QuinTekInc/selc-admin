

//this part aids in pulling data from the I.T directorate of UENR
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';

class DirectorateInterfacePage extends StatefulWidget {
  const DirectorateInterfacePage({super.key});

  @override
  State<DirectorateInterfacePage> createState() => _DirectorateInterfacePageState();
}

class _DirectorateInterfacePageState extends State<DirectorateInterfacePage> {

  @override
  Widget build(BuildContext context) {

    final List<Widget> cards = [

      ProgressCard(
        icon: CupertinoIcons.person,
        title: "Lecturer's Data",
        details: "Retrieves lecturers' data from the main university server",
      ),

      ProgressCard(
        icon: CupertinoIcons.book,
        title: "Class Courses",
        details: "Retrieves lecturers' course assignments data for the "
            "current academic year and semester from the university server",
        backgroundColor: Colors.red.shade400,
      ),

      ProgressCard(
        icon: Icons.school_outlined,
        title: "Students Data",
        details: "Retrieves active students' data from the university server",
        backgroundColor: Colors.blue.shade400,
      ),

      ProgressCard(
        icon: CupertinoIcons.bookmark,
        title: "Course Registrations",
        details: "Retrieves the list of approved student course registrations from "
          "the university server",
        backgroundColor: Colors.purple.shade400,
      )
    ];

    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [

          HeaderText(
            'External Data Collector',
            fontSize: 25,
          ),


          CustomText(
            'Retrieves required data from the university server.',
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // GridView.builder(
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                //     maxCrossAxisExtent: 400,
                //     mainAxisExtent: 150,
                //     crossAxisSpacing: 12,
                //     mainAxisSpacing: 12
                //   ),
                //   itemCount: buttonCards.length,
                //   itemBuilder: (_, index) => buttonCards[index]
                // ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: cards,
                ),


                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: LinearProgressIndicator(
                            value: 0,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green.shade400,
                            backgroundColor: Colors.green.shade100,
                          ),
                        ),

                        CustomButton.withText(
                          'Retrieve Data',
                          onPressed: (){}
                        )
                      ],
                    ),
                  )
                )
              ],
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


class ProgressCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final String? details;
  final Color? backgroundColor;
  final bool isActive;

  const ProgressCard({
    super.key,
    this.icon = Icons.download,
    required this.title,
    this.details,
    this.backgroundColor,
    this.isActive = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 200,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.green.shade400,
        borderRadius: BorderRadius.circular(12)
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [

          CircleAvatar(
            radius: 35,
            backgroundColor: Color.lerp(backgroundColor ?? Colors.green.shade400, Colors.white, 0.3),
            child: Icon(icon, color: Colors.white, size: 30,),
          ),


          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [

                CustomText(
                  title,
                  textColor: Colors.white,
                  fontWeight: FontWeight.w600,
                ),


                if(details != null)CustomText(
                  details!,
                  softwrap: true,
                  textColor: Colors.white,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}



