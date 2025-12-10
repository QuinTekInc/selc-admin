
import 'package:flutter/material.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';


class ReportWizard extends StatefulWidget {

  const ReportWizard({super.key,});

  @override
  State<ReportWizard> createState() => _ReportWizardState();

}

class _ReportWizardState extends State<ReportWizard> {

  @override
  void initState() {
    // TODO: implement initState
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

          HeaderText('Report Wizard'),

          NavigationTextButtons(),

          const Expanded(
            child: SingleChildScrollView(
              child: Column(

                children: [
                  
                ],
              ),
            )
          )


        ]
      ),
    );
  }


}
