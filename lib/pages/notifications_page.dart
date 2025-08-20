
import 'package:flutter/material.dart';
import 'package:selc_admin/components/button.dart';
import 'package:selc_admin/components/text.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        
          children: [
            //todo: the heading text.
            HeaderText(
              'Notifications',
              fontSize: 25,
            ),
        
            //todo: navigation text buttons
            NavigationTextButtons()
        
          ],
        
        ),
      ),
    );
  }
}